/**
 * seed_assignments.js
 * Creates projectLecturerAssignments from existing publicProjects data.
 * Each project generates 1-2 assignments (supervisor + examiner).
 *
 * Usage: node scripts/seed_assignments.js
 */

const { EVENT_ID } = require('./lib/config');
const { httpsRequest, getAccessToken, authHeader, fetchAllDocs, parseDocFields, mapToFields, setDoc, FIRESTORE_BASE } = require('./lib/firebase_api');

async function fetchAllProjects(token) {
  const docs = await fetchAllDocs('publicProjects', token);
  console.log(`Fetched ${docs.length} projects`);
  return docs;
}

function cleanName(name) {
  return name?.trim().replace(/\s+/g, ' ') || '';
}

function normaliseName(name) {
  return name.trim().replace(/\s+/g, ' ').toLowerCase();
}

async function main() {
  console.log('=== Seed Project Lecturer Assignments ===\n');

  const token = await getAccessToken();
  const projects = await fetchAllProjects(token);

  // Build lecturer lookup map from Firestore
  const lecturerDocs = await fetchAllDocs('lecturers', token);
  const lecturerMap = {};
  for (const doc of lecturerDocs) {
    const parsed = parseDocFields(doc);
    const displayName = cleanName(parsed.displayName);
    const email = parsed.email || '';
    const uid = doc.name.split('/').pop();
    if (displayName) {
      lecturerMap[normaliseName(displayName)] = { uid, email, displayName };
    }
  }
  console.log(`Loaded ${lecturerDocs.length} lecturers from Firestore`);

  let created = 0;
  let skipped = 0;
  let unmatched = [];

  for (const doc of projects) {
    const parsed = parseDocFields(doc);
    const projectId = doc.name.split('/').pop();
    const supervisor = cleanName(parsed.supervisorDisplayName);
    const examiner = cleanName(parsed.examinerDisplayName);
    const status = parsed.publicationStatus;

    if (status !== 'published') {
      skipped++;
      continue;
    }

    const now = new Date().toISOString();

    // Look up lecturer IDs
    const svKey = normaliseName(supervisor || '');
    const exKey = normaliseName(examiner || '');
    const svLecturer = lecturerMap[svKey];
    const exLecturer = lecturerMap[exKey];

    if (supervisor && !svLecturer) unmatched.push(`SV: ${supervisor}`);
    if (examiner && !exLecturer) unmatched.push(`EX: ${examiner}`);

    // Create supervisor assignment
    if (supervisor) {
      const svId = `sv_${projectId}`;
      const svData = {
        id: svId,
        eventId: EVENT_ID,
        projectId,
        lecturerDisplayName: supervisor,
        lecturerId: svLecturer ? svLecturer.uid : null,
        lecturerEmail: svLecturer ? svLecturer.email : null,
        role: 'supervisor',
        status: 'active',
        assignedAt: now,
        updatedAt: now,
      };
      const ok = await setDoc('projectLecturerAssignments', svId, svData, token);
      if (ok) created++;
    }

    // Create examiner assignment
    if (examiner) {
      const exId = `ex_${projectId}`;
      const exData = {
        id: exId,
        eventId: EVENT_ID,
        projectId,
        lecturerDisplayName: examiner,
        lecturerId: exLecturer ? exLecturer.uid : null,
        lecturerEmail: exLecturer ? exLecturer.email : null,
        role: 'examiner',
        status: 'active',
        assignedAt: now,
        updatedAt: now,
      };
      const ok = await setDoc('projectLecturerAssignments', exId, exData, token);
      if (ok) created++;
    }
  }

  console.log(`\nDone. Created ${created} assignments, skipped ${skipped} non-published projects.`);
  if (unmatched.length > 0) {
    console.log(`\nWarning: ${unmatched.length} lecturer names not found in Firestore:`);
    unmatched.forEach(n => console.log(`  - ${n}`));
    console.log('Run "Pengurusan Pensyarah" -> "Backfill Lecturer IDs" after adding these lecturers.');
  }
}

main().catch(console.error);
