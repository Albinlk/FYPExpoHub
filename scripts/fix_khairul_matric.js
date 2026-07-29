const { httpsRequest, getAccessToken, authHeader, FIRESTORE_BASE } = require('./lib/firebase_api');

async function main() {
  const token = await getAccessToken();
  const auth = authHeader(token);

  // Fix proj-cs253-224: matric 2024905321 -> 202490531, calonIndustri true
  const docId = 'proj-cs253-224';
  const patchBody = {
    fields: {
      matricId: { stringValue: '202490531' },
      calonIndustri: { booleanValue: true },
    },
  };
  const url = `${FIRESTORE_BASE}/publicProjects/${docId}?updateMask.fieldPaths=matricId&updateMask.fieldPaths=calonIndustri`;
  const res = await httpsRequest(url, 'PATCH', patchBody, auth);
  if (res.status === 200) {
    console.log(`✅ Updated ${docId}: matric 2024905321 -> 202490531, calonIndustri -> true`);
  } else {
    console.error('❌ Failed:', res.body?.error?.message || JSON.stringify(res.body).slice(0, 300));
  }
}

main().catch(console.error);
