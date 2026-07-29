const { getAccessToken, authHeader, fetchAllDocs, parseDocFields } = require('./lib/firebase_api');

async function main() {
  const token = await getAccessToken();
  const docs = await fetchAllDocs('studentProjectVisits', token);
  for (const doc of docs) {
    const id = doc.name.split('/').pop();
    const parsed = parseDocFields(doc);
    console.log(`\n=== ${id} ===`);
    for (const [k, v] of Object.entries(parsed)) {
      console.log(`  ${k}: ${JSON.stringify(v)}`);
    }
  }
}
main().catch(console.error);
