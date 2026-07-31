const { getAccessToken, authHeader, fetchAllDocs, parseDocFields, FIRESTORE_BASE } = require('./lib/firebase_api');
const { httpsRequest } = require('./lib/firebase_api');

async function main() {
  const token = await getAccessToken();
  const auth = authHeader(token);
  const docs = await fetchAllDocs('projectLecturerAssignments', token, 1000);
  console.log(`Total assignments: ${docs.length}`);
  for (const doc of docs) {
    const f = doc.fields || {};
    const id = doc.name.split('/').pop();
    const missing = [];
    if (!f.id) missing.push('id');
    if (!f.eventId) missing.push('eventId');
    if (!f.projectId) missing.push('projectId');
    if (!f.lecturerDisplayName) missing.push('lecturerDisplayName');
    if (!f.role) missing.push('role');
    if (!f.status) missing.push('status');
    if (!f.assignedAt) missing.push('assignedAt');
    if (!f.updatedAt) missing.push('updatedAt');
    if (missing.length > 0) {
      console.log(`  ${id}: MISSING ${missing.join(', ')}`);
    }
  }
  console.log('Done.');
}
main().catch(console.error);
