const { httpsRequest, getAccessToken, authHeader, FIRESTORE_BASE } = require('./lib/firebase_api');

async function main() {
  const token = await getAccessToken();
  const auth = authHeader(token);

  // Revert AINA ASYURA: matricId 2028414614 -> 2023414614, calonIndustri -> true
  const r1 = await httpsRequest(
    `${FIRESTORE_BASE}/publicProjects/proj-cs255-276?updateMask.fieldPaths=matricId&updateMask.fieldPaths=calonIndustri`,
    'PATCH',
    { fields: { matricId: { stringValue: '2023414614' }, calonIndustri: { booleanValue: true } } },
    auth
  );
  console.log(`proj-cs255-276 (AINA ASYURA): ${r1.status === 200 ? '✅ reverted' : '❌ ' + (r1.body?.error?.message || JSON.stringify(r1.body).slice(0,200))}`);

  // Revert KHAIRUL NAJMI: matricId 202490531 -> 2024905321, calonIndustri -> true
  const r2 = await httpsRequest(
    `${FIRESTORE_BASE}/publicProjects/proj-cs253-224?updateMask.fieldPaths=matricId&updateMask.fieldPaths=calonIndustri`,
    'PATCH',
    { fields: { matricId: { stringValue: '2024905321' }, calonIndustri: { booleanValue: true } } },
    auth
  );
  console.log(`proj-cs253-224 (KHAIRUL NAJMI): ${r2.status === 200 ? '✅ reverted' : '❌ ' + (r2.body?.error?.message || JSON.stringify(r2.body).slice(0,200))}`);
}

main().catch(console.error);
