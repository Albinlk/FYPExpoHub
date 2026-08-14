/**
 * FYP Expo Hub - Firebase to Supabase Data Migration & Reconciliation Tool
 *
 * Reads a Firestore JSON export (output of `firebase firestore:export` → JSON),
 * transforms documents to PostgreSQL row format, generates deterministic UUIDs
 * for document IDs, normalizes timestamps to ISO 8601 timestamptz, sanitizes
 * private fields, and outputs seed SQL + JSON summaries.
 *
 * Usage:
 *   node tools/firebase_to_supabase/migrate_data.js <firestore_export.json>
 *
 * Output files:
 *   - seed_data.sql          SQL INSERT statements for Supabase
 *   - migration_summary.json Record counts and metadata
 *   - migration_errors.csv   Validation errors per record
 *   - rollback_plan.md       Instructions to undo the migration
 *
 * Firestore → Supabase table mapping:
 *   publicProjects          -> public.projects
 *   booths                  -> public.booths
 * publicScheduleItems       -> public.schedule_items
 * announcements             -> public.announcements
 * awardCategories           -> public.award_categories
 * awardWinners              -> public.award_winners
 * events                    -> public.events
 * lecturerAssignments       -> public.lecturer_assignments
 * studentProjectVisits      -> public.student_project_visits
 * feedbackEntries           -> public.feedback_entries
 */

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

// Namespace UUID for deterministic UUID v5 generation (using the event slug)
const NAMESPACE = '6ba7b810-9dad-11d1-80b4-00c04fd430c8'; // DNS namespace
const EVENT_SLUG = 'fskm-fyp-2026';

// Deterministic UUID v5 (RFC 4122) — same input always yields same UUID
function toDeterministicUuid(inputId) {
  const hash = crypto.createHash('sha1')
    .update(
      Buffer.concat([
        Buffer.from(NAMESPACE.replace(/-/g, ''), 'hex'),
        Buffer.from(String(inputId), 'utf8')
      ])
    )
    .digest('hex');
  return [
    hash.substring(0, 8),
    hash.substring(8, 12),
    '5' + hash.substring(13, 16),
    'a' + hash.substring(17, 20),
    hash.substring(20, 32),
  ].join('-');
}

// Pre-computed event UUID (kept consistent with seed migration)
const EVENT_UUID = '1977e782-430c-5f3f-a6c7-359f74650691';

// camelCase → snake_case field mapping per Firestore collection
const FIELD_MAPS = {
  publicProjects: {
    eventId: 'event_id',
    matricId: 'matric_id',
    teamDisplayName: 'team_display_name',
    programmeCode: 'programme_code',
    programmeName: 'programme_name',
    shortDescription: 'short_description',
    techTags: 'tech_tags',
    studentTeam: 'student_team',
    supervisorDisplayName: 'supervisor_display_name',
    examinerDisplayName: 'examiner_display_name',
    boothId: 'booth_id',
    boothNumber: 'booth_number',
    boothZone: 'booth_zone',
    presentationDay: 'presentation_day',
    demoUrl: 'demo_url',
    videoUrl: 'video_url',
    repositoryUrl: 'repository_url',
    coverImageUrl: 'cover_image_url',
    industryCandidate: 'industry_candidate',
    publicationStatus: 'publication_status',
    createdAt: 'created_at',
    updatedAt: 'updated_at',
    publishedAt: 'published_at',
  },
  booths: {
    eventId: 'event_id',
    boothNumber: 'booth_number',
    floorPlanUrl: 'floor_plan_url',
    linkedProjectId: 'linked_project_id',
    presentationDay: 'presentation_day',
    publicationStatus: 'publication_status',
    createdAt: 'created_at',
    updatedAt: 'updated_at',
  },
  publicScheduleItems: {
    eventId: 'event_id',
    dayLabel: 'day_label',
    eventDate: 'event_date',
    startAt: 'start_at',
    endAt: 'end_at',
    publicationStatus: 'publication_status',
    createdAt: 'created_at',
    updatedAt: 'updated_at',
    publishedAt: 'published_at',
  },
  announcements: {
    eventId: 'event_id',
    isPinned: 'is_pinned',
    publicationStatus: 'publication_status',
    publishedAt: 'published_at',
    createdAt: 'created_at',
    updatedAt: 'updated_at',
  },
  awardCategories: {
    eventId: 'event_id',
    sortOrder: 'sort_order',
    createdAt: 'created_at',
    updatedAt: 'updated_at',
  },
  awardWinners: {
    eventId: 'event_id',
    categoryId: 'category_id',
    projectId: 'project_id',
    supervisorDisplayName: 'supervisor_display_name',
    programmeCode: 'programme_code',
    publicationStatus: 'publication_status',
    createdAt: 'created_at',
    updatedAt: 'updated_at',
  },
  events: {
    slug: 'slug',
    sessionLabel: 'session_label',
    startAt: 'start_at',
    endAt: 'end_at',
    dailyHours: 'daily_hours',
    locationDetails: 'location_details',
    mapUrl: 'map_url',
    heroImageUrl: 'hero_image_url',
    posterUrl: 'poster_url',
    publicContactEmail: 'public_contact_email',
    faqItems: 'faq_items',
    objectives: 'objectives',
    publicationStatus: 'publication_status',
    createdAt: 'created_at',
    updatedAt: 'updated_at',
    publishedAt: 'published_at',
    updatedBy: 'updated_by',
  },
  lecturerAssignments: {
    eventId: 'event_id',
    projectId: 'project_id',
    lecturerId: 'lecturer_id',
    lecturerDisplayName: 'lecturer_display_name',
    lecturerEmail: 'lecturer_email',
    assignedAt: 'assigned_at',
    assignedBy: 'assigned_by',
    updatedAt: 'updated_at',
  },
  studentProjectVisits: {
    eventId: 'event_id',
    projectId: 'project_id',
    assignmentId: 'assignment_id',
    lecturerId: 'lecturer_id',
    visitRole: 'visit_role',
    visitedAt: 'visited_at',
    visitNote: 'visit_note',
    voidedAt: 'voided_at',
    voidedBy: 'voided_by',
    voidedByRole: 'voided_by_role',
    voidReason: 'void_reason',
    createdAt: 'created_at',
    updatedAt: 'updated_at',
  },
  feedbackEntries: {
    eventId: 'event_id',
    userAgent: 'user_agent',
    submittedBy: 'submitted_by',
    adminNote: 'admin_note',
    createdAt: 'created_at',
    updatedAt: 'updated_at',
  },
};

// Fields that are private / restricted — must NOT appear in public exports
const PRIVATE_FIELDS = new Set([
  'personalEmail', 'phoneNumber', 'confidentialNotes',
  'internalNotes', 'evaluationScores', 'marks',
  'adminNotes', 'privateComments'
]);

function isPrivateField(fieldName) {
  return PRIVATE_FIELDS.has(fieldName) ||
    PRIVATE_FIELDS.has(fieldName.replace(/([A-Z])/g, (m) => m));
}

// Convert Firestore field value to Supabase SQL literal
function toSqlValue(value, fieldType = 'string') {
  if (value === null || value === undefined) return 'NULL';
  if (typeof value === 'boolean') return value ? 'true' : 'false';
  if (typeof value === 'number') {
    return Number.isInteger(value) ? String(value) : String(value);
  }
  if (typeof value === 'string') {
    // Check if it's a timestamp
    if (/^\d{4}-\d{2}-\d{2}T/.test(value)) {
      return `'${value.replace(/'/g, "''")}'::timestamptz`;
    }
    // Check if it's a date
    if (/^\d{4}-\d{2}-\d{2}$/.test(value)) {
      return `'${value}'::date`;
    }
    const escaped = value.replace(/'/g, "''");
    return `'${escaped}'`;
  }
  if (Array.isArray(value)) {
    const items = value.map(v => toSqlValue(v)).join(',');
    return `'[${items}...]'::jsonb`;
  }
  if (typeof value === 'object') {
    return `'${JSON.stringify(value).replace(/'/g, "''")}'::jsonb`;
  }
  return `'${String(value).replace(/'/g, "''")}'`;
}

// Convert Firestore timestamp to ISO 8601 timestamptz string
function normalizeTimestamp(timestamp) {
  if (!timestamp || typeof timestamp !== 'string') return null;
  try {
    const date = new Date(timestamp);
    if (isNaN(date.getTime())) return null;
    return date.toISOString();
  } catch {
    return null;
  }
}

// Parse Firestore document fields (handles Firestore REST API format)
function parseFirestoreFields(doc) {
  const f = doc.fields || {};
  const result = {};
  for (const [k, v] of Object.entries(f)) {
    if (v.stringValue !== undefined) result[k] = v.stringValue;
    else if (v.integerValue !== undefined) result[k] = Number(v.integerValue);
    else if (v.doubleValue !== undefined) result[k] = v.doubleValue;
    else if (v.booleanValue !== undefined) result[k] = v.booleanValue;
    else if (v.timestampValue !== undefined) result[k] = normalizeTimestamp(v.timestampValue);
    else if (v.arrayValue !== undefined) result[k] = (v.arrayValue.values || []).map(i => i.stringValue || i.integerValue || i);
    else if (v.mapValue !== undefined) result[k] = parseFirestoreFields({ fields: v.mapValue.fields });
    else if (v.nullValue !== undefined) result[k] = null;
    else result[k] = v;
  }
  return result;
}

// Parse a plain JSON document (non-Firestore format)
function parsePlainDoc(doc) {
  return doc;
}

// Main migration function
function runMigration(inputPath) {
  console.log('=== FYP Expo Hub — Firebase → Supabase Migration ===\n');

  const outputDir = path.join(__dirname);
  const sqlOutput = [];
  const summary = {
    migratedAt: new Date().toISOString(),
    eventCount: 0,
    projectsCount: 0,
    boothsCount: 0,
    scheduleCount: 0,
    announcementsCount: 0,
    awardCategoriesCount: 0,
    awardWinnersCount: 0,
    assignmentsCount: 0,
    visitsCount: 0,
    feedbackCount: 0,
    errorsCount: 0,
  };

  const errors = [];
  let recordIdCounter = 0;

  // Load Firestore export data (optional — allows generating empty templates)
  let firestoreData = {};
  if (inputPath) {
    if (!fs.existsSync(inputPath)) {
      console.error(`Input file not found: ${inputPath}`);
      process.exit(1);
    }
    const rawInput = JSON.parse(fs.readFileSync(inputPath, 'utf8'));
    firestoreData = rawInput.documents || rawInput;
    console.log(`Loaded Firestore export: ${inputPath}`);
  } else {
    console.log('No input file provided — generating empty migration templates.');
    console.log('Usage: node tools/firebase_to_supabase/migrate_data.js <firestore_export.json>\n');
  }

  // Collection → (Supabase table, ID field name, field map)
  const COLLECTION_MAP = [
    { col: 'events', table: 'events', idField: 'id' },
    { col: 'publicProjects', table: 'projects', idField: 'id' },
    { col: 'booths', table: 'booths', idField: 'id' },
    { col: 'publicScheduleItems', table: 'schedule_items', idField: 'id' },
    { col: 'announcements', table: 'announcements', idField: 'id' },
    { col: 'awardCategories', table: 'award_categories', idField: 'id' },
    { col: 'awardWinners', table: 'award_winners', idField: 'id' },
    { col: 'lecturerAssignments', table: 'lecturer_assignments', idField: 'id' },
    { col: 'studentProjectVisits', table: 'student_project_visits', idField: 'id' },
    { col: 'feedbackEntries', table: 'feedback_entries', idField: 'id' },
  ];

  // Ensure event exists
  sqlOutput.push(`INSERT INTO public.events (id, slug, title, session_label, start_at, end_at, daily_hours, venue, location_details, map_url, description, status, publication_status, created_at, updated_at) VALUES ('${EVENT_UUID}', '${EVENT_SLUG}', 'FSKM FYP Expo Hub 2026', 'Semester March - August 2026', '2026-08-06 09:00:00+08', '2026-08-07 17:00:00+08', '9:00 AM - 5:00 PM', 'Lecture Block, FSKM', NULL, NULL, NULL, 'active', 'published', NOW(), NOW()) ON CONFLICT (slug) DO NOTHING;`);
  summary.eventCount = 1;

  for (const { col, table, idField } of COLLECTION_MAP) {
    const docs = firestoreData[col] || [];
    const fieldMap = FIELD_MAPS[col];
    if (!fieldMap) {
      console.warn(`  No field map for collection "${col}", skipping.`);
      continue;
    }

    for (const doc of docs) {
      recordIdCounter++;
      const docId = doc.id || doc.name?.split('/').pop() || `doc-${recordIdCounter}`;
      const parsed = doc.fields ? parseFirestoreFields(doc) : parsePlainDoc(doc);
      const supabaseId = toDeterministicUuid(docId);

      // Convert field names to snake_case
      const supabaseRow = { id: supabaseId };
      for (const [field, value] of Object.entries(parsed)) {
        // Skip private fields
        if (isPrivateField(field)) {
          errors.push({
            timestamp: new Date().toISOString(),
            entity: table,
            record_id: docId,
            error_message: `Private field skipped: ${field}`,
          });
          continue;
        }

        const snakeField = fieldMap[field] || field.replace(/([A-Z])/g, '_$1').toLowerCase();
        supabaseRow[snakeField] = value;
      }

      // Auto-set event_id
      if (supabaseRow.event_id === undefined) {
        supabaseRow.event_id = EVENT_UUID;
      }

      // Build SQL INSERT
      const cols = Object.keys(supabaseRow);
      const vals = cols.map(c => {
        const v = supabaseRow[c];
        if (v === null || v === undefined) return 'NULL';
        if (c === 'id') return `'${v}'`;
        if (typeof v === 'boolean') return v ? 'true' : 'false';
        if (typeof v === 'number') return String(v);
        if (Array.isArray(v)) return `'${JSON.stringify(v).replace(/'/g, "''")}'::jsonb`;
        if (typeof v === 'object') return `'${JSON.stringify(v).replace(/'/g, "''")}'::jsonb`;
        const s = String(v).replace(/'/g, "''");
        if (/^\d{4}-\d{2}-\d{2}T/.test(s)) return `'${s}'::timestamptz`;
        return `'${s}'`;
      });

      const colList = cols.map(c => `"${c}"`).join(', ');
      const valList = vals.join(', ');
      sqlOutput.push(`INSERT INTO public.${table} (${colList}) VALUES (${valList}) ON CONFLICT (id) DO UPDATE SET ${cols.slice(1).map(c => `"${c}" = EXCLUDED."${c}"`).join(', ')};`);

      // Count
      const countKey = `${table}Count`;
      if (summary[countKey] !== undefined) summary[countKey]++;
    }
  }

  // Write seed SQL
  const sqlPath = path.join(outputDir, 'seed_data.sql');
  fs.writeFileSync(sqlPath, `-- Auto-generated Supabase Seed Migration from Firebase Data\n-- Generated on: ${new Date().toISOString()}\n-- Source: ${inputPath}\n\n${sqlOutput.join('\n')}\n`);

  // Write summary JSON
  fs.writeFileSync(path.join(outputDir, 'migration_summary.json'), JSON.stringify(summary, null, 2));

  // Write CSV errors log
  const csvLines = ['timestamp,entity,record_id,error_message'];
  for (const e of errors) {
    csvLines.push(`"${e.timestamp}","${e.entity}","${e.record_id}","${e.error_message}"`);
  }
  summary.errorsCount = errors.length;
  fs.writeFileSync(path.join(outputDir, 'migration_errors.csv'), csvLines.join('\n'));

  // Write rollback plan
  const rollbackSql = `-- Rollback Plan: Undo FYP Expo Hub Firebase to Supabase Migration\n-- Generated on: ${new Date().toISOString()}\n\n-- Re-run the original migration SQL to restore\n-- DELETE FROM public.events WHERE slug = '${EVENT_SLUG}';\n-- DROP TABLE IF EXISTS ... (list all dropped tables)\n\n-- To fully reset, run:\n-- supabase db reset --linked\n-- supabase db push\n`;
  fs.writeFileSync(path.join(outputDir, 'rollback_plan.md'), rollbackSql);

  console.log('Migration Summary:');
  console.table(summary);
  console.log(`\nFiles generated in ${outputDir}/`);
  console.log('  - seed_data.sql');
  console.log('  - migration_summary.json');
  console.log('  - migration_errors.csv');
  console.log('  - rollback_plan.md');
  console.log(`\nTotal records: ${Object.values(summary).reduce((a, v) => a + (typeof v === 'number' ? v : 0), 0)}`);
  console.log('Migration complete.');

  return summary;
}

if (require.main === module) {
  const inputPath = process.argv[2];
  runMigration(inputPath);
}

module.exports = { runMigration, toDeterministicUuid, FIELD_MAPS, PRIVATE_FIELDS };
