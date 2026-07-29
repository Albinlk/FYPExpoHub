const { httpsRequest, getAccessToken, authHeader, fetchAllDocs, parseDocFields, FIRESTORE_BASE } = require('./lib/firebase_api');

async function main() {
  const token = await getAccessToken();
  const auth = authHeader(token);

  // Update matricId from 2023414614 to 2028414614
  const docId = 'proj-cs255-276';
  const patchBody = { fields: { matricId: { stringValue: '2028414614' }, calonIndustri: { booleanValue: true } } };
  const url = `${FIRESTORE_BASE}/publicProjects/${docId}?updateMask.fieldPaths=matricId&updateMask.fieldPaths=calonIndustri`;
  const res = await httpsRequest(url, 'PATCH', patchBody, auth);
  if (res.status === 200) {
    console.log(`✅ Updated ${docId}: matricId 2023414614 -> 2028414614, calonIndustri -> true`);
  } else {
    console.error('❌ Failed:', res.body?.error?.message || JSON.stringify(res.body).slice(0, 300));
  }

  // Check 202490531 - find closest match in DB
  console.log('\nSearching for 202490531...');
  const docs = await fetchAllDocs('publicProjects', token);
  for (const doc of docs) {
    const parsed = parseDocFields(doc);
    const m = parsed.matricId || '';
    if (m.includes('490531') || m.includes('490532')) {
      const name = Array.isArray(parsed.teamDisplayNames) ? parsed.teamDisplayNames[0] || '' : '';
      console.log(`  ${doc.name.split('/').pop()}: matricId=${m}, name=${name}`);
    }
  }
}

main().catch(console.error);
