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

  // Revert AINA ASYURA: matricId 2028414614 -> 2023414614, calonIndustri -> true
  const r1 = await req(
    `${BASE}/publicProjects/proj-cs255-276?updateMask.fieldPaths=matricId&updateMask.fieldPaths=calonIndustri`,
    'PATCH',
    { fields: { matricId: { stringValue: '2023414614' }, calonIndustri: { booleanValue: true } } },
    auth
  );
  console.log(`proj-cs255-276 (AINA ASYURA): ${r1.status === 200 ? '✅ reverted' : '❌ ' + (r1.body?.error?.message || JSON.stringify(r1.body).slice(0,200))}`);

  // Revert KHAIRUL NAJMI: matricId 202490531 -> 2024905321, calonIndustri -> true
  const r2 = await req(
    `${BASE}/publicProjects/proj-cs253-224?updateMask.fieldPaths=matricId&updateMask.fieldPaths=calonIndustri`,
    'PATCH',
    { fields: { matricId: { stringValue: '2024905321' }, calonIndustri: { booleanValue: true } } },
    auth
  );
  console.log(`proj-cs253-224 (KHAIRUL NAJMI): ${r2.status === 200 ? '✅ reverted' : '❌ ' + (r2.body?.error?.message || JSON.stringify(r2.body).slice(0,200))}`);
}

main().catch(console.error);
