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
  let allDocs = [], next = null;
  do {
    let url = `${BASE}/publicProjects?pageSize=500`;
    if (next) url += `&pageToken=${encodeURIComponent(next)}`;
    const res = await req(url, 'GET', null, auth);
    allDocs.push(...(res.body.documents || []));
    next = res.body.nextPageToken || null;
  } while (next);

  let calonCount = 0;
  const programmes = {};
  for (const doc of allDocs) {
    const f = doc.fields || {};
    if (f.calonIndustri?.booleanValue === true) {
      calonCount++;
      const prog = f.programmeCode?.stringValue || 'unknown';
      programmes[prog] = (programmes[prog] || 0) + 1;
    }
  }
  console.log(`Total projects with calonIndustri = true: ${calonCount}`);
  console.log('By programme:');
  for (const [prog, count] of Object.entries(programmes).sort()) {
    console.log(`  ${prog}: ${count}`);
  }
}
main().catch(console.error);
