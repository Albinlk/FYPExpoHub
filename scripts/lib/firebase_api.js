/**
 * Shared Firebase REST API helpers for all scripts.
 */
const https = require('https');
const http = require('http');
const { API_KEY, FIREBASE_PROJECT, ADMIN_EMAIL, ADMIN_PASSWORD } = require('./config');

const FIRESTORE_BASE = `https://firestore.googleapis.com/v1/projects/${FIREBASE_PROJECT}/databases/(default)/documents`;

function httpsRequest(url, method, body, headers = {}) {
  return new Promise((resolve, reject) => {
    const urlObj = new URL(url);
    const mod = urlObj.protocol === 'https:' ? https : http;
    const req = mod.request(url, {
      method,
      headers: { 'Content-Type': 'application/json', ...headers },
    }, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try { resolve({ status: res.statusCode, body: JSON.parse(data) }); }
        catch { resolve({ status: res.statusCode, body: data }); }
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
  if (resp.body.error) throw new Error(`Auth failed: ${resp.body.error.message}`);
  console.log(`Authenticated as ${resp.body.email}`);
  return resp.body.idToken;
}

function authHeader(token) {
  return { Authorization: `Bearer ${token}` };
}

async function fetchAllDocs(collection, token, pageSize = 500) {
  let all = [];
  let pageToken = null;
  do {
    let url = `${FIRESTORE_BASE}/${collection}?pageSize=${pageSize}`;
    if (pageToken) url += `&pageToken=${encodeURIComponent(pageToken)}`;
    const res = await httpsRequest(url, 'GET', null, authHeader(token));
    all.push(...(res.body.documents || []));
    pageToken = res.body.nextPageToken || null;
  } while (pageToken);
  return all;
}

function parseDocFields(doc) {
  const f = doc.fields || {};
  const result = {};
  for (const [k, v] of Object.entries(f)) {
    if (v.stringValue !== undefined) result[k] = v.stringValue;
    else if (v.integerValue !== undefined) result[k] = Number(v.integerValue);
    else if (v.doubleValue !== undefined) result[k] = v.doubleValue;
    else if (v.booleanValue !== undefined) result[k] = v.booleanValue;
    else if (v.timestampValue !== undefined) result[k] = v.timestampValue;
    else if (v.arrayValue !== undefined) result[k] = (v.arrayValue.values || []).map(i => i.stringValue || i);
    else if (v.mapValue !== undefined) result[k] = parseDocFields({ fields: v.mapValue.fields });
    else result[k] = v;
  }
  return result;
}

function mapToFields(obj) {
  const fields = {};
  for (const [k, v] of Object.entries(obj)) {
    if (v === null || v === undefined) continue;
    if (typeof v === 'string') fields[k] = { stringValue: v };
    else if (typeof v === 'number') fields[k] = Number.isInteger(v) ? { integerValue: v } : { doubleValue: v };
    else if (typeof v === 'boolean') fields[k] = { booleanValue: v };
    else if (v instanceof Date) fields[k] = { timestampValue: v.toISOString() };
    else if (Array.isArray(v)) fields[k] = { arrayValue: { values: v.map(i => typeof i === 'string' ? { stringValue: i } : i) } };
    else if (typeof v === 'object') fields[k] = { mapValue: { fields: mapToFields(v) } };
  }
  return fields;
}

async function setDoc(collection, docId, data, token) {
  const url = `${FIRESTORE_BASE}/${collection}/${docId}`;
  return httpsRequest(url, 'PATCH', { fields: mapToFields(data) }, authHeader(token));
}

module.exports = { httpsRequest, getAccessToken, authHeader, fetchAllDocs, parseDocFields, mapToFields, setDoc, FIRESTORE_BASE };
