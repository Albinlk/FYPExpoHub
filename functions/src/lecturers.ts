import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

function normaliseName(name: string): string {
  return name.trim().replace(/\s+/g, ' ').toLowerCase();
}

export const createLecturerAccount = functions.https.onCall(async (data, context) => {
  const uid = context.auth?.uid;
  if (!uid) {
    throw new functions.https.HttpsError('unauthenticated', 'Admin must be signed in.');
  }

  const isAdmin = context.auth?.token?.admin === true;
  if (!isAdmin) {
    throw new functions.https.HttpsError('permission-denied', 'Only admins can create lecturer accounts.');
  }

  const { email, displayName, password } = data;
  if (!email || !displayName || !password) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing required fields: email, displayName, password.');
  }

  if (password.length < 6) {
    throw new functions.https.HttpsError('invalid-argument', 'Password must be at least 6 characters.');
  }

  const normalizedEmail = email.toLowerCase().trim();

  try {
    const userRecord = await admin.auth().createUser({
      email: normalizedEmail,
      password,
      displayName,
    });

    const now = admin.firestore.FieldValue.serverTimestamp();

    const batch = db.batch();
    batch.set(db.collection('lecturers').doc(userRecord.uid), {
      id: userRecord.uid,
      uid: userRecord.uid,
      displayName,
      email: normalizedEmail,
      createdAt: now,
      updatedAt: now,
    });
    batch.set(db.collection('auditLogs').doc(), {
      actorUid: uid,
      action: 'lecturer_created',
      targetType: 'lecturers',
      targetId: userRecord.uid,
      metadataSafe: { email: normalizedEmail, displayName },
      createdAt: now,
    });
    await batch.commit();

    return {
      uid: userRecord.uid,
      email: normalizedEmail,
      displayName,
    };
  } catch (error: any) {
    if (error.code === 'auth/email-already-exists') {
      throw new functions.https.HttpsError('already-exists', 'A user with this email already exists.');
    }
    throw new functions.https.HttpsError('internal', error.message);
  }
});

export const deleteLecturerAccount = functions.https.onCall(async (data, context) => {
  const uid = context.auth?.uid;
  if (!uid) {
    throw new functions.https.HttpsError('unauthenticated', 'Admin must be signed in.');
  }

  const isAdmin = context.auth?.token?.admin === true;
  if (!isAdmin) {
    throw new functions.https.HttpsError('permission-denied', 'Only admins can delete lecturer accounts.');
  }

  const { lecturerUid } = data;
  if (!lecturerUid) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing required field: lecturerUid.');
  }

  try {
    const lecturerDoc = await db.collection('lecturers').doc(lecturerUid).get();
    const lecturerData = lecturerDoc.data();

    await admin.auth().deleteUser(lecturerUid);

    const now = admin.firestore.FieldValue.serverTimestamp();
    const batch = db.batch();
    batch.delete(db.collection('lecturers').doc(lecturerUid));
    batch.set(db.collection('auditLogs').doc(), {
      actorUid: uid,
      action: 'lecturer_deleted',
      targetType: 'lecturers',
      targetId: lecturerUid,
      metadataSafe: { email: lecturerData?.email, displayName: lecturerData?.displayName },
      createdAt: now,
    });
    await batch.commit();

    return { success: true };
  } catch (error: any) {
    if (error.code === 'auth/user-not-found') {
      await db.collection('lecturers').doc(lecturerUid).delete();
      return { success: true };
    }
    throw new functions.https.HttpsError('internal', error.message);
  }
});

export const backfillLecturerIds = functions.https.onCall(async (data, context) => {
  const uid = context.auth?.uid;
  if (!uid) {
    throw new functions.https.HttpsError('unauthenticated', 'Admin must be signed in.');
  }

  const isAdmin = context.auth?.token?.admin === true;
  if (!isAdmin) {
    throw new functions.https.HttpsError('permission-denied', 'Only admins can run backfill.');
  }

  try {
    const lecturersSnap = await db.collection('lecturers').get();
    const lecturerMap = new Map<string, { uid: string; email: string }>();
    for (const doc of lecturersSnap.docs) {
      const data = doc.data();
      const name = normaliseName(data.displayName || '');
      if (name) {
        lecturerMap.set(name, { uid: doc.id, email: data.email || '' });
      }
    }

    const assignmentsSnap = await db.collection('projectLecturerAssignments')
      .where('lecturerId', 'in', [null, ''])
      .get();

    const allDocs = assignmentsSnap.docs;
    let patched = 0;
    let skipped = 0;

    const now = admin.firestore.FieldValue.serverTimestamp();

    // Batch writes in chunks of 500 (Firestore batch limit)
    let batch = db.batch();
    let batchCount = 0;

    for (const doc of allDocs) {
      const data = doc.data();
      const displayName = normaliseName(data.lecturerDisplayName || '');
      if (!displayName) { skipped++; continue; }

      const match = lecturerMap.get(displayName);
      if (!match) {
        const fuzzyMatch = Array.from(lecturerMap.entries()).find(
          ([key]) => key.includes(displayName) || displayName.includes(key)
        );
        if (!fuzzyMatch) { skipped++; continue; }
        batch.update(doc.ref, {
          lecturerId: fuzzyMatch[1].uid,
          lecturerEmail: fuzzyMatch[1].email,
          updatedAt: now,
        });
        patched++;
      } else {
        batch.update(doc.ref, {
          lecturerId: match.uid,
          lecturerEmail: match.email,
          updatedAt: now,
        });
        patched++;
      }

      batchCount++;
      if (batchCount >= 500) {
        await batch.commit();
        batch = db.batch();
        batchCount = 0;
      }
    }

    if (batchCount > 0) {
      await batch.commit();
    }

    await db.collection('auditLogs').add({
      actorUid: uid,
      action: 'lecturer_ids_backfilled',
      targetType: 'projectLecturerAssignments',
      metadataSafe: { patched, skipped },
      createdAt: now,
    });

    return { patched, skipped };
  } catch (error: any) {
    throw new functions.https.HttpsError('internal', error.message);
  }
});
