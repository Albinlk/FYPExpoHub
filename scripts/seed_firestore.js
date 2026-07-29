/**
 * seed_firestore.js
 * Seeds Firestore with project, booth, and schedule data from the Excel file.
 * Signs in with admin credentials and uses Firestore REST API.
 *
 * Usage: node scripts/seed_firestore.js
 */

const fs = require('fs');
const path = require('path');
const XLSX = require('xlsx');
const { API_KEY, FIREBASE_PROJECT, EVENT_ID, ADMIN_EMAIL, ADMIN_PASSWORD, CALON_MATRICS } = require('./lib/config');
const { httpsRequest, getAccessToken, authHeader, FIRESTORE_BASE } = require('./lib/firebase_api');

const EXCEL_PATH = 'D:\\Downloads\\(LATEST) CSP650-DewanSeminar-ListName-Layout (7).xlsx';

const COURSE_CATEGORY = {
  CS230: { category: 'Computer Science', progPrefix: 'CS230' },
  CS253: { category: 'Cybersecurity', progPrefix: 'CS253' },
  CS251: { category: 'Networking & Communication', progPrefix: 'CS251' },
  CS255: { category: 'Network Security & Infrastructure', progPrefix: 'CS255' },
  CS266: { category: 'Software Engineering & Applications', progPrefix: 'CS266' },
};

const SHEET_COURSE_MAP = [
  ['CS230 - List Name', 'CS230'],
  ['CS251 - List Name', 'CS251'],
  ['CS253 - List Name', 'CS253'],
  ['CS255 - List Name', 'CS255'],
  ['CS266 - List Name', 'CS266'],
];

// ── Excel Parsing (same logic as parse_excel_v5.py) ──────────────────
function cleanMatric(val) {
  if (val === undefined || val === null) return '';
  let s = String(val).replace(/\.0+$/, '').trim();
  if (/[eE]/.test(s)) {
    try { s = String(Math.round(Number(val))); } catch {}
  }
  return s;
}

function sanitize(val) {
  if (!val) return '';
  return String(val).replace(/[\n\r]+/g, ' ').replace(/\s+/g, ' ').trim();
}

function slugify(title) {
  return title.toLowerCase().replace(/[^a-z0-9\s-]/g, '').replace(/[\s-]+/g, '-').replace(/^-|-$/g, '').slice(0, 80);
}

function parseSheet(ws, courseCode) {
  const info = COURSE_CATEGORY[courseCode];
  const projects = [];
  const booths = new Set();

  const rows = XLSX.utils.sheet_to_json(ws, { header: 1, defval: '' });
  for (let i = 3; i < rows.length; i++) {
    const row = rows[i];
    if (!row || row.length < 8) continue;
    const no = row[0];
    const boothRaw = String(row[1]).trim();
    const group = sanitize(row[2]);
    const matricRaw = row[3];
    const studentName = sanitize(row[4]);
    let title = sanitize(row[5]);
    const supervisor = sanitize(row[6]);
    const examiner = sanitize(row[7]);

    if (!title) title = 'TBD (Project Title Pending)';
    if (!studentName) continue;

    const noInt = parseInt(no, 10);
    if (isNaN(noInt)) continue;

    const boothNumber = boothRaw || '';
    const zone = boothNumber.includes('-') ? boothNumber.split('-')[0] : '';

    if (boothNumber) booths.add(boothNumber);

    projects.push({
      no: noInt,
      booth_number: boothNumber,
      zone,
      group,
      matric_id: cleanMatric(matricRaw),
      student_name: studentName,
      title,
      supervisor,
      examiner,
      course_code: courseCode,
      category: info.category,
      prog_prefix: info.progPrefix,
    });
  }
  return { projects, booths: [...booths].sort() };
}

let globalCounter = 0;
function generateProjectId(courseCode) {
  globalCounter++;
  return `proj-${courseCode.toLowerCase()}-${String(globalCounter).padStart(3, '0')}`;
}

// ── Build Firestore Document ─────────────────────────────────────────
function buildFirestoreDoc(fields) {
  const f = {};
  for (const [k, v] of Object.entries(fields)) {
    if (v === null || v === undefined) {
      f[k] = { nullValue: null };
    } else if (typeof v === 'string') {
      f[k] = { stringValue: v };
    } else if (typeof v === 'boolean') {
      f[k] = { booleanValue: v };
    } else if (typeof v === 'number') {
      f[k] = { integerValue: String(v) };
    } else if (Array.isArray(v)) {
      f[k] = { arrayValue: { values: v.map((e) => ({ stringValue: String(e) })) } };
    } else if (v instanceof Date) {
      f[k] = { timestampValue: v.toISOString() };
    }
  }
  return { fields: f };
}

// ── Main ─────────────────────────────────────────────────────────────
async function main() {
  // 1. Parse Excel
  console.log('Reading Excel file...');
  const workbook = XLSX.readFile(EXCEL_PATH);

  const allProjects = [];
  const boothMap = new Map();

  for (const [sheetName, courseCode] of SHEET_COURSE_MAP) {
    if (!workbook.SheetNames.includes(sheetName)) {
      console.warn(`  ⚠ Sheet "${sheetName}" not found, skipping.`);
      continue;
    }
    const ws = workbook.Sheets[sheetName];
    const { projects, booths } = parseSheet(ws, courseCode);
    for (const b of booths) {
      const zone = b.includes('-') ? b.split('-')[0] : '';
      boothMap.set(b, { booth_number: b, zone });
    }
    for (const p of projects) {
      p.id = generateProjectId(courseCode);
      allProjects.push(p);
    }
    console.log(`  ${sheetName}: ${projects.length} projects, ${booths.length} booths`);
  }
  console.log(`\nTotal: ${allProjects.length} projects, ${boothMap.size} booths`);

  // 2. Sign in with admin credentials
  console.log('\nSigning in as admin...');
  const idToken = await getAccessToken();
  const AUTH = authHeader(idToken);

  // Helper to write/update a Firestore document
  async function writeDoc(collection, docId, data) {
    const url = `${FIRESTORE_BASE}/${collection}/${docId}`;
    const doc = buildFirestoreDoc(data);
    const res = await httpsRequest(url, 'PATCH', doc, AUTH);
    if (res.status === 200) {
      return true;
    } else {
      console.error(`  ❌ Failed to write ${collection}/${docId}:`, res.body?.error?.message || JSON.stringify(res.body).slice(0, 200));
      return false;
    }
  }

  // 3. Seed Projects
  console.log('\nSeeding projects...');
  let success = 0;
  let failed = 0;
  for (const p of allProjects) {
    const progName = `${p.course_code} (${p.category})`;
    const ok = await writeDoc('publicProjects', p.id, {
      id: p.id,
      eventId: EVENT_ID,
      slug: slugify(p.title),
      title: p.title,
      matricId: p.matric_id || null,
      programmeCode: p.group,
      programmeName: progName,
      shortDescription: `Final Year Project - ${p.category}`,
      category: p.category,
      technologyTags: ['FYP'],
      boothId: `booth-${p.booth_number}`,
      boothNumber: p.booth_number,
      boothZone: p.zone,
      coverImageUrl: 'assets/images/project_placeholder.jpg',
      posterUrl: null,
      teamDisplayNames: [p.student_name],
      supervisorDisplayName: p.supervisor,
      examinerDisplayName: p.examiner || null,
      demoUrl: null,
      videoUrl: null,
      repositoryUrl: null,
      featured: false,
      calonIndustri: CALON_MATRICS.has(p.matric_id),
      publicationStatus: 'published',
      createdAt: new Date(),
      updatedAt: new Date(),
      publishedAt: new Date(),
    });
    if (ok) success++; else failed++;
    if ((success + failed) % 100 === 0) console.log(`  ... ${success + failed}/${allProjects.length}`);
  }
  console.log(`  ✅ ${success} projects seeded, ${failed} failed`);

  // 4. Seed Booths
  console.log('\nSeeding booths...');
  let bSuccess = 0;
  let bFailed = 0;
  for (const [boothNum, bInfo] of boothMap) {
    const ok = await writeDoc('booths', `booth-${boothNum}`, {
      id: `booth-${boothNum}`,
      eventId: EVENT_ID,
      boothNumber: boothNum,
      zone: bInfo.zone,
      locationNote: `Zon ${bInfo.zone}`,
      publicationStatus: 'published',
      createdAt: new Date(),
      updatedAt: new Date(),
      publishedAt: new Date(),
    });
    if (ok) bSuccess++; else bFailed++;
  }
  console.log(`  ✅ ${bSuccess} booths seeded, ${bFailed} failed`);

  // 5. Seed Schedule
  console.log('\nSeeding schedule...');
  const scheduleItems = [
    { id: 'sch-slot-1', date: new Date(2026, 7, 6), startAt: '09:00', endAt: '10:30', title: 'Sesi Pembentangan 1', description: 'Sesi pembentangan pertama bagi semua kursus.', venue: 'Blok Kuliah, FSKM', audience: 'Juri & Peserta' },
    { id: 'sch-slot-2', date: new Date(2026, 7, 6), startAt: '10:45', endAt: '12:15', title: 'Sesi Pembentangan 2', description: 'Sesi pembentangan kedua.', venue: 'Blok Kuliah, FSKM', audience: 'Juri & Peserta' },
    { id: 'sch-slot-3', date: new Date(2026, 7, 6), startAt: '14:00', endAt: '15:30', title: 'Sesi Pembentangan 3', description: 'Sesi pembentangan petang.', venue: 'Blok Kuliah, FSKM', audience: 'Juri & Peserta' },
    { id: 'sch-slot-4', date: new Date(2026, 7, 7), startAt: '09:00', endAt: '10:30', title: 'Sesi Pembentangan 4', description: 'Sesi pembentangan hari kedua.', venue: 'Blok Kuliah, FSKM', audience: 'Juri & Peserta' },
    { id: 'sch-slot-5', date: new Date(2026, 7, 7), startAt: '10:45', endAt: '12:15', title: 'Sesi Pembentangan 5', description: 'Sesi pembentangan kedua hari kedua.', venue: 'Blok Kuliah, FSKM', audience: 'Juri & Peserta' },
    { id: 'sch-slot-6', date: new Date(2026, 7, 7), startAt: '14:00', endAt: '16:00', title: 'Majlis Penutup & Penyampaian Hadiah', description: 'Majlis penutup dan penyampaian hadiah.', venue: 'Blok Kuliah, FSKM', audience: 'Semua' },
    { id: 'sch-gen-1', date: new Date(2026, 7, 6), startAt: '08:30', endAt: '09:00', title: 'Pendaftaran Juri & Peserta', description: 'Sesi penyerahan kit pameran dan pendaftaran.', venue: 'Blok Kuliah, FSKM', audience: 'Juri & Peserta' },
    { id: 'sch-gen-2', date: new Date(2026, 7, 7), startAt: '09:00', endAt: '17:00', title: 'FYP Expo 2026 - Hari Terbuka', description: 'Sesi pembukaan untuk pelawat dan industri.', venue: 'Blok Kuliah, FSKM', audience: 'Awam' },
  ];

  let sSuccess = 0;
  let sFailed = 0;
  for (const s of scheduleItems) {
    const ok = await writeDoc('publicScheduleItems', s.id, {
      id: s.id,
      eventId: EVENT_ID,
      date: s.date,
      startAt: s.startAt,
      endAt: s.endAt,
      title: s.title,
      venue: s.venue,
      audience: s.audience,
      description: s.description || null,
      visibility: 'public',
      publicationStatus: 'published',
      createdAt: new Date(),
      updatedAt: new Date(),
      publishedAt: new Date(),
    });
    if (ok) sSuccess++; else sFailed++;
  }
  console.log(`  ✅ ${sSuccess} schedule items seeded, ${sFailed} failed`);

  console.log('\n🎉 Seeding complete!');
}

main().catch((err) => {
  console.error('\n❌ Error:', err.message || err);
  process.exit(1);
});
