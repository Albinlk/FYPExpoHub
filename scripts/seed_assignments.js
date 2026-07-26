/**
 * seed_assignments.js
 * Creates projectLecturerAssignments from existing publicProjects data.
 * Each project generates 1-2 assignments (supervisor + examiner).
 *
 * Usage: node scripts/seed_assignments.js
 */

const https = require('https');
const http = require('http');

const API_KEY = 'AIzaSyAaoWvZr70guv06Ab_f3NcThxawfCEChus';
const FIREBASE_PROJECT = 'fyp-expo-hub';
const EVENT_ID = 'fskm-fyp-2026';
const ADMIN_EMAIL = 'albin1841@uitm.edu.my';
const ADMIN_PASSWORD = '***REMOVED***';

function httpsRequest(url, method, body, headers = {}) {
  return new Promise((resolve, reject) => {
    const urlObj = new URL(url);
    const mod = urlObj.protocol === 'https:' ? https : http;
    const req = mod.request(url, {
      method,
      headers: {
        'Content-Type': 'application/json',
        ...headers,
      },
    }, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try { resolve(JSON.parse(data)); }
        catch { resolve(data); }
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
    { email: ADMIN_EMAIL, password: ADMIN_PASSWORD, returnSecureToken: true }
  );
  if (resp.error) throw new Error(`Auth failed: ${resp.error.message}`);
  console.log(`Authenticated as ${resp.email}`);
  return resp.idToken;
}

async function fetchAllProjects(token) {
  let allDocs = [];
  let pageToken = '';
  do {
    let url = `https://firestore.googleapis.com/v1/projects/${FIREBASE_PROJECT}/databases/(default)/documents/publicProjects?pageSize=300`;
    if (pageToken) url += `&pageToken=${pageToken}`;
    const resp = await httpsRequest(url, 'GET', null, { Authorization: `Bearer ${token}` });
    if (resp.documents) {
      allDocs = allDocs.concat(resp.documents);
    }
    pageToken = resp.nextPageToken || '';
  } while (pageToken);

  console.log(`Fetched ${allDocs.length} projects`);
  return allDocs;
}

function extractValue(fields, key) {
  if (!fields || !fields[key]) return null;
  const val = fields[key];
  return val.stringValue ?? val.integerValue ?? val.booleanValue ?? null;
}

async function setDoc(token, collection, docId, data) {
  const url = `https://firestore.googleapis.com/v1/projects/${FIREBASE_PROJECT}/databases/(default)/documents/${collection}?documentId=${docId}`;
  const resp = await httpsRequest(url, 'POST', {
    fields: mapToFields(data),
  }, { Authorization: `Bearer ${token}` });
  if (resp.error) {
    console.error(`  FAILED ${collection}/${docId}: ${resp.error.message}`);
    return false;
  }
  return true;
}

function mapToFields(data) {
  const fields = {};
  for (const [key, value] of Object.entries(data)) {
    if (value === null || value === undefined) continue;
    if (typeof value === 'string') fields[key] = { stringValue: value };
    else if (typeof value === 'boolean') fields[key] = { booleanValue: value };
    else if (typeof value === 'number') fields[key] = { integerValue: String(value) };
    else if (value instanceof Date) fields[key] = { timestampValue: value.toISOString() };
    else if (Array.isArray(value)) fields[key] = { arrayValue: { values: value.map(v => ({ stringValue: String(v) })) } };
    else if (typeof value === 'object') fields[key] = { mapValue: { fields: mapToFields(value) } };
  }
  return fields;
}

function cleanName(name) {
  return name?.trim().replace(/\s+/g, ' ') || '';
}

async function main() {
  console.log('=== Seed Project Lecturer Assignments ===\n');

  const token = await getAccessToken();
  const projects = await fetchAllProjects(token);

  let created = 0;
  let skipped = 0;

  for (const doc of projects) {
    const fields = doc.fields || {};
    const projectId = doc.name.split('/').pop();
    const supervisor = cleanName(extractValue(fields, 'supervisorDisplayName'));
    const examiner = cleanName(extractValue(fields, 'examinerDisplayName'));
    const status = extractValue(fields, 'publicationStatus');

    if (status !== 'published') {
      skipped++;
      continue;
    }

    const now = new Date().toISOString();

    // Create supervisor assignment
    if (supervisor) {
      const svId = `sv_${projectId}`;
      const svData = {
        id: svId,
        eventId: EVENT_ID,
        projectId,
        lecturerDisplayName: supervisor,
        role: 'supervisor',
        status: 'active',
        assignedAt: now,
        updatedAt: now,
      };
      const ok = await setDoc(token, 'projectLecturerAssignments', svId, svData);
      if (ok) created++;
    }

    // Create examiner assignment
    if (examiner) {
      const exId = `ex_${projectId}`;
      const exData = {
        id: exId,
        eventId: EVENT_ID,
        projectId,
        lecturerDisplayName: examiner,
        role: 'examiner',
        status: 'active',
        assignedAt: now,
        updatedAt: now,
      };
      const ok = await setDoc(token, 'projectLecturerAssignments', exId, exData);
      if (ok) created++;
    }
  }

  console.log(`\nDone. Created ${created} assignments, skipped ${skipped} non-published projects.`);
}

main().catch(console.error);
