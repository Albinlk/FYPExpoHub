const { getAccessToken, authHeader, fetchAllDocs, parseDocFields } = require('./lib/firebase_api');

async function main() {
  const token = await getAccessToken();
  const docs = await fetchAllDocs('studentProjectVisits', token);
  console.log(`Total visits: ${docs.length}`);
  for (const doc of docs) {
    const parsed = parseDocFields(doc);
    const id = doc.name.split('/').pop();
    const missing = [];
    if (!parsed.id) missing.push('id'); if (!parsed.eventId) missing.push('eventId');
    if (!parsed.projectId) missing.push('projectId'); if (!parsed.lecturerId) missing.push('lecturerId');
    if (!parsed.visitRole) missing.push('visitRole'); if (!parsed.visitedAt) missing.push('visitedAt');
    if (!parsed.status) missing.push('status');
    if (missing.length > 0) console.log(`  ${id}: MISSING ${missing.join(', ')}`);
    else console.log(`  ${id}: OK (${parsed.visitRole})`);
  }
}
main().catch(console.error);
