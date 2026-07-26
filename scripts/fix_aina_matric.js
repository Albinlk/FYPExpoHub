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
  if (signInRes.status !== 200) { console.error('Sign-in failed'); process.exit(1); }
  const token = signInRes.body.idToken;
  const auth = { Authorization: `Bearer ${token}` };
  const BASE = `https://firestore.googleapis.com/v1/projects/${FIREBASE_PROJECT}/databases/(default)/documents`;

  // Update matricId from 2023414614 to 2028414614
  const docId = 'proj-cs255-276';
  const patchBody = { fields: { matricId: { stringValue: '2028414614' }, calonIndustri: { booleanValue: true } } };
  const url = `${BASE}/publicProjects/${docId}?updateMask.fieldPaths=matricId&updateMask.fieldPaths=calonIndustri`;
  const res = await req(url, 'PATCH', patchBody, auth);
  if (res.status === 200) {
    console.log(`✅ Updated ${docId}: matricId 2023414614 -> 2028414614, calonIndustri -> true`);
  } else {
    console.error('❌ Failed:', res.body?.error?.message || JSON.stringify(res.body).slice(0, 300));
  }

  // Check 202490531 - find closest match in DB
  console.log('\nSearching for 202490531...');
  const searchRes = await req(`${BASE}/publicProjects?pageSize=500`, 'GET', null, auth);
  const docs = searchRes.body.documents || [];
  for (const doc of docs) {
    const f = doc.fields || {};
    const m = f.matricId?.stringValue || '';
    if (m.includes('490531') || m.includes('490532')) {
      const name = f.teamDisplayNames?.arrayValue?.values?.[0]?.stringValue || '';
      console.log(`  ${doc.name.split('/').pop()}: matricId=${m}, name=${name}`);
    }
  }
}

main().catch(console.error);
