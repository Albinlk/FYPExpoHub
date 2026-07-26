const https = require('https');
const http = require('http');

const API_KEY = 'AIzaSyAaoWvZr70guv06Ab_f3NcThxawfCEChus';
const FIREBASE_PROJECT = 'fyp-expo-hub';
const ADMIN_EMAIL = 'albin1841@uitm.edu.my';
const ADMIN_PASSWORD = '***REMOVED***';

const CALON_MATRICS = new Set([
  '2023444376','2024699546','2024963653','2023885286',
  '2023443658','2023214052','2024425838','2023277304',
  '2023405938','2023217236',
  '2023298712','2023851666','2023867346','2023884362',
  '2023601134','2023600384','2023479866','2024857584',
  '2023899266','2023217904',
  '2024350455','2024963455','2024556797','2023414808',
  '2024905321','2023116081','2023261412','2023436416',
  '2024905819','2023415054',
  '2023414614','2023260244','2023240232','2023436724',
  '2023240168','2023239276','2023820446','2023699244',
  '2023674486','2023260928',
  '2023472522','2022622854','2023218022','2024235476',
  '2024692246','2023899996','2023239802','2023660422',
  '2023436396','2023410826',
]);

function req(url, method, body, headers = {}) {
  return new Promise((resolve, reject) => {
    const u = new URL(url);
    const mod = u.protocol === 'https:' ? https : http;
    const opts = { hostname: u.hostname, path: u.pathname + u.search, method, headers: { 'Content-Type': 'application/json', ...headers } };
    const r = mod.request(opts, (res) => { let d = ''; res.on('data', (c) => (d += c)); res.on('end', () => { try { resolve({ status: res.statusCode, body: JSON.parse(d) }); } catch { resolve({ status: res.statusCode, body: d }); } }); });
    r.on('error', reject); if (body) r.write(JSON.stringify(body)); r.end();
  });
}

async function main() {
  const signInRes = await req(`https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${API_KEY}`, 'POST', { email: ADMIN_EMAIL, password: ADMIN_PASSWORD, returnSecureToken: true });
  if (signInRes.status !== 200) { console.error('Sign-in failed'); process.exit(1); }
  const token = signInRes.body.idToken;
  const auth = { Authorization: `Bearer ${token}` };
  const BASE = `https://firestore.googleapis.com/v1/projects/${FIREBASE_PROJECT}/databases/(default)/documents`;

  let allDocs = [];
  let nextToken = null;
  do {
    let url = `${BASE}/publicProjects?pageSize=500`;
    if (nextToken) url += `&pageToken=${encodeURIComponent(nextToken)}`;
    const res = await req(url, 'GET', null, auth);
    const docs = res.body.documents || [];
    allDocs.push(...docs);
    nextToken = res.body.nextPageToken || null;
  } while (nextToken);

  const dbMatrics = new Map();
  for (const doc of allDocs) {
    const fields = doc.fields || {};
    const matricId = fields.matricId?.stringValue || fields.matric_id?.stringValue || '';
    const name = fields.teamDisplayNames?.arrayValue?.values?.[0]?.stringValue || '';
    dbMatrics.set(matricId, { id: doc.name.split('/').pop(), name });
  }

  console.log('=== Calon Matrics NOT found in database ===');
  let found = 0, notFound = 0;
  for (const m of [...CALON_MATRICS].sort()) {
    if (dbMatrics.has(m)) {
      found++;
    } else {
      notFound++;
      console.log(`  ${m} - no matching project in database`);
    }
  }
  console.log(`\nMatched: ${found}, Not found: ${notFound}`);

  // Also show calon matrics that WERE found
  console.log('\n=== Calon Matrics FOUND ===');
  for (const m of [...CALON_MATRICS].sort()) {
    if (dbMatrics.has(m)) {
      const info = dbMatrics.get(m);
      console.log(`  ${m} -> ${info.id} (${info.name})`);
    }
  }

  // Check if old 2023414614 still exists
  console.log('\n=== Database has 2023414614 (old CS255)? ===');
  if (dbMatrics.has('2023414614')) {
    const info = dbMatrics.get('2023414614');
    console.log(`  YES: ${info.id} (${info.name})`);
    console.log('  Should be 2028414614 - needs matricId update');
  } else {
    console.log('  NO - already corrected');
  }
}

main().catch(console.error);
