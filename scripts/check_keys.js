const https = require('https');

const API_KEY = 'AIzaSyAaoWvZr70guv06Ab_f3NcThxawfCEChus';
const FIREBASE_PROJECT = 'fyp-expo-hub';
const ADMIN_EMAIL = 'albin1841@uitm.edu.my';
const ADMIN_PASSWORD = '***REMOVED***';

function req(url, method, body, headers = {}) {
  return new Promise((resolve, reject) => {
    const u = new URL(url);
    const opts = { hostname: u.hostname, path: u.pathname + u.search, method, headers: { 'Content-Type': 'application/json', ...headers } };
    const r = https.request(opts, (res) => { let d = ''; res.on('data', (c) => (d += c)); res.on('end', () => { try { resolve({ status: res.statusCode, body: JSON.parse(d) }); } catch { resolve({ status: res.statusCode, body: d }); } }); });
    r.on('error', reject); if (body) r.write(JSON.stringify(body)); r.end();
  });
}

async function main() {
  const signInRes = await req(`https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${API_KEY}`, 'POST', { email: ADMIN_EMAIL, password: ADMIN_PASSWORD, returnSecureToken: true });
  const token = signInRes.body.idToken;
  const auth = { Authorization: `Bearer ${token}` };
  const BASE = `https://firestore.googleapis.com/v1/projects/${FIREBASE_PROJECT}/databases/(default)/documents`;

  // Get one document
  const res = await req(`${BASE}/publicProjects/proj-cs230-001`, 'GET', null, auth);
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
