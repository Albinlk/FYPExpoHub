const https = require('https');
const API_KEY = 'AIzaSyAaoWvZr70guv06Ab_f3NcThxawfCEChus';
function req(url, method, body, headers = {}) {
  return new Promise((resolve, reject) => {
    const u = new URL(url);
    const opts = { hostname: u.hostname, path: u.pathname + u.search, method, headers: { 'Content-Type': 'application/json', ...headers } };
    const r = https.request(opts, (res) => { let d = ''; res.on('data', (c) => (d += c)); res.on('end', () => { try { resolve({ status: res.statusCode, body: JSON.parse(d) }); } catch { resolve({ status: res.statusCode, body: d }); } }); });
    r.on('error', reject); if (body) r.write(JSON.stringify(body)); r.end();
  });
}
async function main() {
  const signInRes = await req(`https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${API_KEY}`, 'POST', { email: 'albin1841@uitm.edu.my', password: '***REMOVED***', returnSecureToken: true });
  const token = signInRes.body.idToken;
  const auth = { Authorization: `Bearer ${token}` };
  const BASE = `https://firestore.googleapis.com/v1/projects/fyp-expo-hub/databases/(default)/documents`;
  const res = await req(`${BASE}/projectLecturerAssignments?pageSize=500`, 'GET', null, auth);
  const docs = res.body.documents || [];
  // Find assignments for ALBIN
  for (const doc of docs) {
    const f = doc.fields || {};
    const name = f.lecturerDisplayName?.stringValue || '';
    if (name.toLowerCase().includes('albin')) {
      const pid = f.projectId?.stringValue || '';
      const role = f.role?.stringValue || '';
      console.log(`${doc.name.split('/').pop()}: project=${pid}, role=${role}, name="${name}"`);
    }
  }
}
main().catch(console.error);
