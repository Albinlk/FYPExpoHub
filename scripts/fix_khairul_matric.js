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

  // Fix proj-cs253-224: matric 2024905321 -> 202490531, calonIndustri true
  const docId = 'proj-cs253-224';
  const patchBody = {
    fields: {
      matricId: { stringValue: '202490531' },
      calonIndustri: { booleanValue: true },
    },
  };
  const url = `${BASE}/publicProjects/${docId}?updateMask.fieldPaths=matricId&updateMask.fieldPaths=calonIndustri`;
  const res = await req(url, 'PATCH', patchBody, auth);
  if (res.status === 200) {
    console.log(`✅ Updated ${docId}: matric 2024905321 -> 202490531, calonIndustri -> true`);
  } else {
    console.error('❌ Failed:', res.body?.error?.message || JSON.stringify(res.body).slice(0, 300));
  }
}

main().catch(console.error);
