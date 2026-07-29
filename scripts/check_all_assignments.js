const { getAccessToken, authHeader, fetchAllDocs, parseDocFields } = require('./lib/firebase_api');

async function main() {
  const token = await getAccessToken();
  const all = await fetchAllDocs('projectLecturerAssignments', token);
  console.log(`Total: ${all.length}`);
  let bad = 0;
  for (const doc of all) {
    const parsed = parseDocFields(doc);
    const id = doc.name.split('/').pop();
    const missing = [];
    if (!parsed.id) missing.push('id');
    if (!parsed.eventId) missing.push('eventId');
    if (!parsed.projectId) missing.push('projectId');
    if (!parsed.lecturerDisplayName) missing.push('lecturerDisplayName');
    if (!parsed.role) missing.push('role');
    if (!parsed.assignedAt) missing.push('assignedAt');
    if (missing.length > 0) { bad++; console.log(`  ${id}: MISSING ${missing.join(', ')}`); }
  }
  if (bad === 0) console.log('All assignments OK');
}
main().catch(console.error);
