const { getAccessToken, authHeader, fetchAllDocs, parseDocFields } = require('./lib/firebase_api');

async function main() {
  const token = await getAccessToken();
  const docs = await fetchAllDocs('projectLecturerAssignments', token, 500);
  // Find assignments for ALBIN
  for (const doc of docs) {
    const parsed = parseDocFields(doc);
    const name = parsed.lecturerDisplayName || '';
    if (name.toLowerCase().includes('albin')) {
      const pid = parsed.projectId || '';
      const role = parsed.role || '';
      console.log(`${doc.name.split('/').pop()}: project=${pid}, role=${role}, name="${name}"`);
    }
  }
}
main().catch(console.error);
