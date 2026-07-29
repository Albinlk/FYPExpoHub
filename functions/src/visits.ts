import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

// -----------------------------------------------------------------
// markStudentProjectVisited
// -----------------------------------------------------------------
export const markStudentProjectVisited = functions.https.onCall(async (data, context) => {
  const uid = context.auth?.uid;
  if (!uid) {
    throw new functions.https.HttpsError('unauthenticated', 'Lecturer must be signed in.');
  }

  const { assignmentId, eventId, projectId, visitRole, visitNote } = data;

  if (!assignmentId || !eventId || !projectId || !visitRole) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing required fields: assignmentId, eventId, projectId, visitRole.');
  }

  if (!['supervisor', 'examiner'].includes(visitRole)) {
    throw new functions.https.HttpsError('invalid-argument', 'visitRole must be "supervisor" or "examiner".');
  }

  // Verify the assignment exists and belongs to this lecturer
  const assignmentSnap = await db.collection('projectLecturerAssignments').doc(assignmentId).get();
  if (!assignmentSnap.exists) {
    throw new functions.https.HttpsError('not-found', 'Assignment not found.');
  }

  const assignment = assignmentSnap.data()!;
  if (assignment.lecturerId !== uid) {
    throw new functions.https.HttpsError('permission-denied', 'You are not the assigned lecturer for this project.');
  }

  if (assignment.status !== 'active') {
    throw new functions.https.HttpsError('failed-precondition', 'This assignment is no longer active.');
  }

  if (assignment.eventId !== eventId || assignment.projectId !== projectId || assignment.role !== visitRole) {
    throw new functions.https.HttpsError('invalid-argument', 'Assignment details do not match the request.');
  }

  // Check for duplicate active visit
  const duplicateQuery = await db.collection('studentProjectVisits')
    .where('eventId', '==', eventId)
    .where('projectId', '==', projectId)
    .where('lecturerId', '==', uid)
    .where('visitRole', '==', visitRole)
    .where('status', '==', 'completed')
    .limit(1)
    .get();

  if (!duplicateQuery.empty) {
    throw new functions.https.HttpsError('already-exists', 'You have already marked this visit as completed.');
  }

  const now = admin.firestore.FieldValue.serverTimestamp();

  // Create visit record
  const visitRef = db.collection('studentProjectVisits').doc();
  const visitId = visitRef.id;

  // Batch visit + audit log atomically
  const batch = db.batch();
  batch.set(visitRef, {
    id: visitId,
    eventId,
    projectId,
    assignmentId,
    lecturerId: uid,
    visitRole,
    boothNumberSnapshot: assignment.boothNumberSnapshot || null,
    boothZoneSnapshot: assignment.boothZoneSnapshot || null,
    visitedAt: now,
    visitNote: visitNote || null,
    status: 'completed',
    createdAt: now,
    updatedAt: now,
    source: 'lecturer',
  });

  batch.set(db.collection('auditLogs').doc(), {
    actorUid: uid,
    action: 'visit_marked',
    targetType: 'studentProjectVisits',
    targetId: visitId,
    eventId,
    metadataSafe: {
      projectId,
      assignmentId,
      visitRole,
    },
    createdAt: now,
  });

  await batch.commit();

  return { visitId, status: 'completed' };
});

// -----------------------------------------------------------------
// undoStudentProjectVisit
// -----------------------------------------------------------------
export const undoStudentProjectVisit = functions.https.onCall(async (data, context) => {
  const uid = context.auth?.uid;
  if (!uid) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be signed in.');
  }

  const { visitId, reason } = data;

  if (!visitId) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing required field: visitId.');
  }

  if (!reason || typeof reason !== 'string' || reason.trim().length === 0) {
    throw new functions.https.HttpsError('invalid-argument', 'A reason is required to undo a visit.');
  }

  const visitSnap = await db.collection('studentProjectVisits').doc(visitId).get();
  if (!visitSnap.exists) {
    throw new functions.https.HttpsError('not-found', 'Visit record not found.');
  }

  const visit = visitSnap.data()!;

  if (visit.status !== 'completed') {
    throw new functions.https.HttpsError('failed-precondition', 'This visit has already been voided.');
  }

  // Check if caller is the lecturer or an admin
  const isLecturer = visit.lecturerId === uid;

  // Admin check
  let isAdmin = false;
  try {
    const tokenResult = await context.auth?.token;
    isAdmin = tokenResult?.admin === true;
  } catch {
    // not admin
  }

  if (!isLecturer && !isAdmin) {
    throw new functions.https.HttpsError('permission-denied', 'You can only undo your own visits.');
  }

  // Lecturer 30-minute window check
  if (isLecturer && !isAdmin) {
    const visitedAt = visit.visitedAt?.toDate?.() ?? new Date(visit.visitedAt);
    const now = new Date();
    const diffMs = now.getTime() - visitedAt.getTime();
    const thirtyMinutesMs = 30 * 60 * 1000;
    if (diffMs > thirtyMinutesMs) {
      throw new functions.https.HttpsError('failed-precondition', 'The 30-minute window to undo this visit has passed.');
    }
  }

  const now = admin.firestore.FieldValue.serverTimestamp();

  // Batch visit update + audit log atomically
  const batch = db.batch();
  batch.update(visitSnap.ref, {
    status: 'voided',
    voidedAt: now,
    voidedBy: uid,
    voidReason: reason.trim(),
    updatedAt: now,
  });

  batch.set(db.collection('auditLogs').doc(), {
    actorUid: uid,
    action: 'visit_voided',
    targetType: 'studentProjectVisits',
    targetId: visitId,
    eventId: visit.eventId || '',
    metadataSafe: {
      projectId: visit.projectId || '',
      reason: reason.trim(),
      voidedByRole: isAdmin ? 'admin' : 'lecturer',
    },
    createdAt: now,
  });

  await batch.commit();

  return { visitId, status: 'voided' };
});
