/**
 * patch_assignments_lecturer_id.js
 * Adds lecturerId to existing projectLecturerAssignments
 * where lecturerDisplayName matches a known lecturer.
 *
 * Usage: node scripts/patch_assignments_lecturer_id.js
 */
const https = require('https');
const http = require('http');

const API_KEY = 'AIzaSyAaoWvZr70guv06Ab_f3NcThxawfCEChus';
const FIREBASE_PROJECT = 'fyp-expo-hub';

const LECTURER_CONFIG = {
  'ALBIN LEMUEL KUSHAN': { uid: 'k5jMiAjtmBbbJ1dYAaMIg3DzTn22', email: 'albin1841@uitm.edu.my' },
};

function httpsRequest(url, method, body, headers = {}) {
  return new Promise((resolve, reject) => {
    const urlObj = new URL(url);
    const mod = urlObj.protocol === 'https:' ? https : http;
    const req = mod.request(url, { method, headers: { 'Content-Type': 'application/json', ...headers } }, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try { resolve(JSON.parse(data)); } catch { resolve(data); }
      });
    });
    req.on('error', reject);
    if (body) req.write(JSON.stringify(body));
    req.end();
  });
}

async function getAccessToken() {
  const resp = await httpsRequest(
    `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${API_KEY}`,
    'POST',
    { email: 'albin1841@uitm.edu.my', password: '***REMOVED***', returnSecureToken: true }
  );
  if (resp.error) throw new Error(`Auth failed: ${resp.error.message}`);
  return resp.idToken;
}

async function fetchAllAssignments(token) {
  let allDocs = [];
  let pageToken = '';
  do {
    let url = `https://firestore.googleapis.com/v1/projects/${FIREBASE_PROJECT}/databases/(default)/documents/projectLecturerAssignments?pageSize=300`;
    if (pageToken) url += `&pageToken=${pageToken}`;
    const resp = await httpsRequest(url, 'GET', null, { Authorization: `Bearer ${token}` });
    if (resp.documents) allDocs = allDocs.concat(resp.documents);
    pageToken = resp.nextPageToken || '';
  } while (pageToken);
  return allDocs;
}

function extractValue(fields, key) {
  if (!fields || !fields[key]) return null;
  const val = fields[key];
  return val.stringValue ?? val.integerValue ?? val.booleanValue ?? null;
}

function mapToFields(data) {
  const fields = {};
  for (const [key, value] of Object.entries(data)) {
    if (value === null || value === undefined) continue;
    if (typeof value === 'string') fields[key] = { stringValue: value };
    else if (typeof value === 'boolean') fields[key] = { booleanValue: value };
    else if (typeof value === 'number') fields[key] = { integerValue: String(value) };
  }
  return fields;
}

async function updateDoc(token, collection, docId, data) {
  const url = `https://firestore.googleapis.com/v1/projects/${FIREBASE_PROJECT}/databases/(default)/documents/${collection}/${docId}?updateMask.fieldPaths=lecturerId&updateMask.fieldPaths=lecturerEmail`;
  const resp = await httpsRequest(url, 'PATCH', { fields: mapToFields(data) }, { Authorization: `Bearer ${token}` });
  if (resp.error) {
    console.error(`  FAILED ${collection}/${docId}: ${resp.error.message}`);
    return false;
  }
  return true;
}

async function main() {
  console.log('=== Patch Assignments with lecturerId ===\n');
  const token = await getAccessToken();
  const docs = await fetchAllAssignments(token);
  console.log(`Fetched ${docs.length} assignments`);

  let patched = 0;
  let skipped = 0;

  for (const doc of docs) {
    const fields = doc.fields || {};
    const displayName = extractValue(fields, 'lecturerDisplayName');
    const existingLecturerId = extractValue(fields, 'lecturerId');

    if (!displayName) { skipped++; continue; }
    if (existingLecturerId) { skipped++; continue; }

    const config = LECTURER_CONFIG[displayName];
    if (!config) { skipped++; continue; }

    const docId = doc.name.split('/').pop();
    const ok = await updateDoc(token, 'projectLecturerAssignments', docId, {
      lecturerId: config.uid,
      lecturerEmail: config.email,
    });
    if (ok) {
      patched++;
      console.log(`  Patched ${docId}: ${displayName} -> ${config.email}`);
    }
  }

  console.log(`\nDone. Patched ${patched} assignments, skipped ${skipped}.`);
}

main().catch(console.error);
