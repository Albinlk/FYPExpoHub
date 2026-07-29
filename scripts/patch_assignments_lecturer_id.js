/**
 * patch_assignments_lecturer_id.js
 * Adds lecturerId to existing projectLecturerAssignments
 * where lecturerDisplayName matches a known lecturer.
 *
 * Usage: node scripts/patch_assignments_lecturer_id.js
 */
const { httpsRequest, getAccessToken, authHeader, fetchAllDocs, parseDocFields, mapToFields, FIRESTORE_BASE } = require('./lib/firebase_api');

const LECTURER_CONFIG = {
  'ALBIN LEMUEL KUSHAN': { uid: 'k5jMiAjtmBbbJ1dYAaMIg3DzTn22', email: 'albin1841@uitm.edu.my' },
};

async function main() {
  console.log('=== Patch Assignments with lecturerId ===\n');
  const token = await getAccessToken();
  const docs = await fetchAllDocs('projectLecturerAssignments', token);
  console.log(`Fetched ${docs.length} assignments`);

  let patched = 0;
  let skipped = 0;

  for (const doc of docs) {
    const parsed = parseDocFields(doc);
    const displayName = parsed.lecturerDisplayName;
    const existingLecturerId = parsed.lecturerId;

    if (!displayName) { skipped++; continue; }
    if (existingLecturerId) { skipped++; continue; }

    const config = LECTURER_CONFIG[displayName];
    if (!config) { skipped++; continue; }

    const docId = doc.name.split('/').pop();
    const url = `${FIRESTORE_BASE}/projectLecturerAssignments/${docId}?updateMask.fieldPaths=lecturerId&updateMask.fieldPaths=lecturerEmail`;
    const resp = await httpsRequest(url, 'PATCH', { fields: mapToFields({ lecturerId: config.uid, lecturerEmail: config.email }) }, authHeader(token));
    if (!resp.body.error) {
      patched++;
      console.log(`  Patched ${docId}: ${displayName} -> ${config.email}`);
    }
  }

  console.log(`\nDone. Patched ${patched} assignments, skipped ${skipped}.`);
}

main().catch(console.error);
