const { httpsRequest, getAccessToken, authHeader, FIRESTORE_BASE } = require('./lib/firebase_api');

async function main() {
  const token = await getAccessToken();
  const auth = authHeader(token);

  // Get one document
  const res = await httpsRequest(`${FIRESTORE_BASE}/publicProjects/proj-cs230-001`, 'GET', null, auth);
  if (res.status === 200) {
    const fields = res.body.fields;
    console.log('=== Field names in Firestore ===');
    for (const [key, val] of Object.entries(fields)) {
      const type = Object.keys(val)[0];
      const preview = type === 'stringValue' ? val.stringValue?.slice(0, 50) :
                      type === 'booleanValue' ? String(val.booleanValue) :
                      type === 'arrayValue' ? `[${val.arrayValue?.values?.length} items]` :
                      type;
      console.log(`  ${key}: (${type}) ${preview}`);
    }
    console.log('\nHas calonIndustri:', 'calonIndustri' in fields);
    console.log('Has calon_industri:', 'calon_industri' in fields);
  } else {
    console.error('Failed:', res.body);
  }
}

main().catch(console.error);
