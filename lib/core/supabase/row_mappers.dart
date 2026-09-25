import '../domain/models/announcement.dart';
import '../domain/models/award.dart';
import '../domain/models/booth.dart';
import '../domain/models/event.dart';
import '../domain/models/feedback_entry.dart';
import '../domain/models/import_models.dart';
import '../domain/models/project.dart';
import '../domain/models/schedule_item.dart';
import '../utils/fypms_key_normalizer.dart' show normalizeKeys;

/// Converts between Expo Hub models and the actual Supabase row shapes.
///
/// The freezed models serialize to camelCase keys that match none of the
/// snake_case columns, and several model fields don't exist as columns at
/// all (or exist under a different name — `ScheduleItem.visibility` is
/// `access_type`, `PublishedAwardWinner.projectTitle` is `title`). Sending
/// `toJson()` straight to PostgREST rejects the whole write, so every write
/// goes through a `*ToRow` mapper here. The column sets are pinned against
/// `supabase/types.ts` by test/core/supabase/row_mappers_test.dart.

final _uuidPattern = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
  caseSensitive: false,
);

bool isUuid(String? value) => value != null && _uuidPattern.hasMatch(value);

/// Thrown instead of sending a write the database is guaranteed to reject —
/// e.g. a row that came from the bundled offline fallback (ids like
/// `proj-cs230-001`), which has no matching database row to update.
class NotPersistableException implements Exception {
  NotPersistableException(this.message);
  final String message;

  @override
  String toString() => message;
}

void _requireUuid(String id, String what) {
  if (!isUuid(id)) {
    throw NotPersistableException(
      'This $what comes from bundled offline data and has no database row '
      'to save to. Reload the page once the live database is reachable, '
      'then try again.',
    );
  }
}

String? _uuidOrNull(String? value) => isUuid(value) ? value : null;

String _ts(DateTime d) => d.toUtc().toIso8601String();

String _str(Object? v, [String fallback = '']) =>
    v == null ? fallback : v.toString();

// ─────────────────────────────── Time of day ──────────────────────────────

/// Minutes since midnight for "09:00", "9:00", "09:00 AM", "1:30 pm" or a
/// full ISO timestamp (read in Malaysia time, UTC+8). Null if unparseable.
int? clockMinutes(String? raw) {
  if (raw == null) return null;
  final s = raw.trim();
  if (s.isEmpty) return null;
  if (s.contains('T')) {
    final dt = DateTime.tryParse(s);
    if (dt == null) return null;
    final myt = dt.toUtc().add(const Duration(hours: 8));
    return myt.hour * 60 + myt.minute;
  }
  final m = RegExp(r'^(\d{1,2})[:.](\d{2})(?::\d{2})?\s*([AaPp][Mm])?$')
      .firstMatch(s);
  if (m == null) return null;
  var hour = int.parse(m.group(1)!);
  final minute = int.parse(m.group(2)!);
  final meridiem = m.group(3)?.toUpperCase();
  if (meridiem != null) {
    if (hour < 1 || hour > 12) return null;
    if (meridiem == 'AM' && hour == 12) hour = 0;
    if (meridiem == 'PM' && hour != 12) hour += 12;
  }
  if (hour > 23 || minute > 59) return null;
  return hour * 60 + minute;
}

String _hhmm(int minutes) =>
    '${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}';

String _yyyyMmDd(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// A calendar date plus a wall-clock time in Malaysia time, as the
/// timestamptz string the `schedule_items.start_at`/`end_at` columns need.
String _mytTimestamp(DateTime date, String clock) {
  final minutes = clockMinutes(clock);
  if (minutes == null) {
    throw NotPersistableException(
      'Unrecognised time "$clock". Use a format like 09:00 or 09:00 AM.',
    );
  }
  return '${_yyyyMmDd(date)}T${_hhmm(minutes)}:00+08:00';
}

/// "2026-08-06" — the `date` column format.
String scheduleDateString(DateTime d) => _yyyyMmDd(d);

/// [date] + a wall-clock time in Malaysia time as a timestamptz string.
String mytTimestamp(DateTime date, String clock) => _mytTimestamp(date, clock);

/// (start, end) as "HH:mm" from spreadsheet text like "9:00 AM - 10:30 AM",
/// "1:00 - 2:30 PM", "0900-1030" or "09.00 hingga 10.30". Null if either end
/// can't be read or the range runs backwards.
(String, String)? importTimeRange(String raw) {
  final parts = raw
      .trim()
      .split(RegExp(r'\s+(?:to|hingga|sehingga)\s+|\s*[-–—]\s*', caseSensitive: false));
  if (parts.length != 2) return null;
  var first = parts[0].trim();
  final second = parts[1].trim();
  // "1:00 - 2:30 PM": the meridiem written once applies to both ends.
  final trailing = RegExp(r'([AaPp][Mm])$').firstMatch(second);
  if (trailing != null && !RegExp(r'[AaPp][Mm]$').hasMatch(first)) {
    first = '$first ${trailing.group(1)}';
  }
  int? parse(String s) {
    final compact = RegExp(r'^(\d{2})(\d{2})$').firstMatch(s);
    return clockMinutes(compact == null ? s : '${compact.group(1)}:${compact.group(2)}');
  }

  final a = parse(first);
  final b = parse(second);
  if (a == null || b == null || b <= a) return null;
  return (_hhmm(a), _hhmm(b));
}

/// The calendar date for a spreadsheet day label: an actual date
/// ("2026-08-06") or "Day 2" / "Hari 2" counted from the event's first day
/// (Malaysia time). Null when it's neither, so the row is flagged for review.
DateTime? importDayDate(String label, DateTime eventStart) {
  final t = label.trim();
  final parsed = DateTime.tryParse(t);
  if (parsed != null) return DateTime(parsed.year, parsed.month, parsed.day);
  final n = RegExp(r'(\d+)').firstMatch(t);
  if (n == null || !RegExp(r'day|hari', caseSensitive: false).hasMatch(t)) {
    return null;
  }
  final start = eventStart.toUtc().add(const Duration(hours: 8));
  return DateTime(start.year, start.month, start.day + int.parse(n.group(1)!) - 1);
}

// ───────────────────────────────── Projects ───────────────────────────────

Map<String, dynamic> projectToRow(Project p, {required String eventId}) {
  _requireUuid(p.id, 'project');
  return {
    'id': p.id,
    'event_id': eventId,
    'slug': p.slug,
    'title': p.title,
    'matric_id': p.matricId,
    'programme_code': p.programmeCode,
    'programme_name': p.programmeName,
    'short_description': p.shortDescription,
    'category': p.category,
    'tech_tags': p.technologyTags,
    'booth_id': _uuidOrNull(p.boothId),
    'booth_number': p.boothNumber,
    'booth_zone': p.boothZone,
    'presentation_day': p.presentationDay,
    'cover_image_url': p.coverImageUrl,
    'student_team': p.teamDisplayNames,
    'team_display_name': p.teamDisplayNames.join(', '),
    'supervisor_display_name': p.supervisorDisplayName,
    'examiner_display_name': p.examinerDisplayName,
    'demo_url': p.demoUrl,
    'video_url': p.videoUrl,
    'repository_url': p.repositoryUrl,
    'featured': p.featured,
    'industry_candidate': p.calonIndustri,
    'publication_status': p.publicationStatus,
    'updated_at': _ts(p.updatedAt),
  };
}

/// Accepts a live snake_case row or an already-camelCase map. Nullable
/// columns that the model requires get neutral defaults, so one row with a
/// null `category` or `cover_image_url` can't fail the whole list.
Project projectFromRow(Map<String, dynamic> row) {
  final m = normalizeKeys(row);
  final now = DateTime.now().toIso8601String();
  return Project.fromJson({
    ...m,
    'eventId': _str(m['eventId']),
    'programmeCode': _str(m['programmeCode']),
    'programmeName': _str(m['programmeName']),
    'shortDescription': _str(m['shortDescription'] ?? m['abstract']),
    'category': _str(m['category']),
    'technologyTags': (m['technologyTags'] as List?)?.map((e) => e.toString()).toList() ?? const <String>[],
    'coverImageUrl': _str(m['coverImageUrl']),
    'supervisorDisplayName': _str(m['supervisorDisplayName']),
    'featured': m['featured'] ?? false,
    'calonIndustri': m['calonIndustri'] ?? false,
    'publicationStatus': _str(m['publicationStatus'], 'draft'),
    'createdAt': m['createdAt'] ?? now,
    'updatedAt': m['updatedAt'] ?? m['createdAt'] ?? now,
  });
}

// ─────────────────────────────── Schedule items ───────────────────────────

Map<String, dynamic> scheduleItemToRow(ScheduleItem s,
    {required String eventId}) {
  _requireUuid(s.id, 'schedule item');
  final startAt = _mytTimestamp(s.date, s.startAt);
  final endAt = _mytTimestamp(s.date, s.endAt);
  if (clockMinutes(s.endAt)! <= clockMinutes(s.startAt)!) {
    throw NotPersistableException('The end time must be after the start time.');
  }
  return {
    'id': s.id,
    'event_id': eventId,
    'event_date': _yyyyMmDd(s.date),
    'start_at': startAt,
    'end_at': endAt,
    'title': s.title,
    'venue': s.venue,
    'audience': s.audience,
    'description': s.description,
    'access_type': s.visibility,
    'publication_status': s.publicationStatus,
    'updated_at': _ts(s.updatedAt),
  };
}

/// Handles both the live table (`event_date`, timestamptz `start_at`,
/// `access_type`) and the bundled fallback (`date`, "09:00", `visibility`).
ScheduleItem scheduleItemFromRow(Map<String, dynamic> row) {
  final m = normalizeKeys(row);
  final now = DateTime.now().toIso8601String();
  String clock(Object? v) {
    final minutes = clockMinutes(v?.toString());
    return minutes == null ? _str(v) : _hhmm(minutes);
  }

  return ScheduleItem.fromJson({
    ...m,
    'eventId': _str(m['eventId']),
    'date': m['date'] ?? m['eventDate'],
    'startAt': clock(m['startAt']),
    'endAt': clock(m['endAt']),
    'venue': _str(m['venue']),
    'audience': _str(m['audience']),
    'visibility': _str(m['visibility'] ?? m['access_type'], 'public'),
    'publicationStatus': _str(m['publicationStatus'], 'draft'),
    'createdAt': m['createdAt'] ?? now,
    'updatedAt': m['updatedAt'] ?? m['createdAt'] ?? now,
  });
}

// ─────────────────────────────────── Booths ───────────────────────────────

Map<String, dynamic> boothToRow(Booth b, {required String eventId}) {
  _requireUuid(b.id, 'booth');
  return {
    'id': b.id,
    'event_id': eventId,
    'booth_number': b.boothNumber,
    'zone': b.zone,
    'location_note': b.locationNote,
    'presentation_day': b.presentationDay,
    'floor_plan_url': b.staticFloorPlanUrl,
    'linked_project_id': _uuidOrNull(b.projectId),
    'publication_status': b.publicationStatus,
    'updated_at': _ts(b.updatedAt),
  };
}

Booth boothFromRow(Map<String, dynamic> row) {
  final m = normalizeKeys(row);
  final now = DateTime.now().toIso8601String();
  return Booth.fromJson({
    ...m,
    'eventId': _str(m['eventId']),
    'zone': _str(m['zone'] ?? m['boothZone']),
    'locationNote': _str(m['locationNote']),
    'publicationStatus': _str(m['publicationStatus'], 'draft'),
    'createdAt': m['createdAt'] ?? now,
    'updatedAt': m['updatedAt'] ?? m['createdAt'] ?? now,
  });
}

// ─────────────────────────────── Announcements ────────────────────────────

Map<String, dynamic> announcementToRow(Announcement a,
    {required String eventId}) {
  _requireUuid(a.id, 'announcement');
  return {
    'id': a.id,
    'event_id': eventId,
    'title': a.title,
    'body': a.body,
    'category': a.category,
    'is_pinned': a.pinned,
    'publication_status': a.publicationStatus,
    'published_at': _ts(a.publishedAt),
    'updated_at': _ts(a.updatedAt),
  };
}

Announcement announcementFromRow(Map<String, dynamic> row) {
  final m = normalizeKeys(row);
  final now = DateTime.now().toIso8601String();
  final created = m['createdAt'] ?? now;
  return Announcement.fromJson({
    ...m,
    'eventId': _str(m['eventId']),
    'category': _str(m['category'], 'general'),
    'pinned': m['pinned'] ?? false,
    'publicationStatus': _str(m['publicationStatus'], 'draft'),
    'publishedAt': m['publishedAt'] ?? created,
    'createdAt': created,
    'updatedAt': m['updatedAt'] ?? created,
  });
}

// ─────────────────────────────── Award winners ────────────────────────────

Map<String, dynamic> awardWinnerToRow(PublishedAwardWinner w,
    {required String eventId}) {
  _requireUuid(w.id, 'award winner');
  return {
    'id': w.id,
    'event_id': eventId,
    'category_id': _uuidOrNull(w.awardCategoryId),
    'project_id': _uuidOrNull(w.projectId),
    'title': w.projectTitle,
    'programme_code': w.programmeCode,
    'team_display_name': w.teamDisplayName,
    'supervisor_display_name': w.supervisorDisplayName,
    'sponsor': w.sponsor,
    'description': w.description,
    'publication_status': w.publicationStatus,
    'updated_at': _ts(w.updatedAt),
  };
}

PublishedAwardWinner awardWinnerFromRow(Map<String, dynamic> row) {
  final m = normalizeKeys(row);
  final now = DateTime.now().toIso8601String();
  // normalizeKeys folds team_display_name into teamDisplayNames (a list,
  // for projects); award winners keep it as a single string.
  final team = row['team_display_name'] ?? m['teamDisplayName'];
  return PublishedAwardWinner.fromJson({
    ...m,
    'eventId': _str(m['eventId']),
    'awardCategoryId': _str(m['awardCategoryId']),
    'projectTitle': _str(m['projectTitle'] ?? m['title']),
    'teamDisplayName': team?.toString(),
    'publicationStatus': _str(m['publicationStatus'], 'draft'),
    'createdAt': m['createdAt'] ?? now,
    'updatedAt': m['updatedAt'] ?? m['createdAt'] ?? now,
  });
}

// ─────────────────────────────────── Events ───────────────────────────────

/// Payload for the `update_event_configuration` RPC, which reads snake_case
/// keys (see 20260814000003_rpc_functions.sql).
Map<String, dynamic> eventToRow(Event e) => {
      'title': e.title,
      'session_label': e.sessionLabel,
      'start_at': _ts(e.startAt),
      'end_at': _ts(e.endAt),
      'daily_hours': e.dailyHours,
      'venue': e.venue,
      'location_details': e.locationDetails,
      'map_url': e.mapUrl,
      'description': e.description,
      'objectives': e.objectives,
      'status': e.status,
      'publication_status': e.publicationStatus,
      'hero_image_url': e.heroImageUrl,
      'poster_url': e.posterUrl,
      'public_contact_email': e.publicContactEmail,
      'faq_items': [
        for (final f in e.faqItems) {'question': f.question, 'answer': f.answer},
      ],
    };

Event eventFromRow(Map<String, dynamic> row) {
  final m = normalizeKeys(row);
  final now = DateTime.now().toIso8601String();
  return Event.fromJson({
    ...m,
    'sessionLabel': _str(m['sessionLabel']),
    'dailyHours': _str(m['dailyHours']),
    'venue': _str(m['venue']),
    'locationDetails': _str(m['locationDetails']),
    'description': _str(m['description']),
    'objectives': (m['objectives'] as List?)?.map((e) => e.toString()).toList() ?? const <String>[],
    'status': _str(m['status'], 'active'),
    'heroImageUrl': _str(m['heroImageUrl']),
    'posterUrl': _str(m['posterUrl']),
    'publicContactEmail': _str(m['publicContactEmail']),
    'faqItems': (m['faqItems'] as List?) ?? const <Object>[],
    'publicationStatus': _str(m['publicationStatus'], 'published'),
    'updatedAt': m['updatedAt'] ?? now,
  });
}

// ──────────────────────────────── Feedback ────────────────────────────────

/// Admin-side write (status / note changes). Visitor submissions use
/// [feedbackSubmissionRow], which can't set moderation fields.
Map<String, dynamic> feedbackToRow(FeedbackEntry f, {String? eventId}) {
  _requireUuid(f.id, 'feedback entry');
  return {
    'id': f.id,
    'event_id': eventId,
    'subject': f.subject,
    'message': f.message,
    'rating': f.rating,
    'status': f.status,
    'admin_note': f.adminNote,
    'submitted_by': _uuidOrNull(f.userId),
    'user_agent': f.userAgent,
    'updated_at': _ts(f.updatedAt),
  };
}

/// Only the columns the anonymous-insert RLS policy allows a visitor to set.
Map<String, dynamic> feedbackSubmissionRow(FeedbackEntry f,
        {String? eventId}) =>
    {
      'id': f.id,
      'event_id': eventId,
      'subject': f.subject,
      'message': f.message,
      'rating': f.rating,
      'submitted_by': _uuidOrNull(f.userId),
      'user_agent': f.userAgent,
    };

FeedbackEntry feedbackFromRow(Map<String, dynamic> row) {
  final m = normalizeKeys(row);
  final now = DateTime.now().toIso8601String();
  return FeedbackEntry.fromJson({
    ...m,
    'userId': m['userId'] ?? m['submittedBy'],
    'eventId': _str(m['eventId']),
    'status': _str(m['status'], 'new'),
    'createdAt': m['createdAt'] ?? now,
    'updatedAt': m['updatedAt'] ?? m['createdAt'] ?? now,
  });
}

// ──────────────────────────────── Imports ─────────────────────────────────

/// `imports.status` check constraint values (initial_schema.sql).
const importStatuses = {
  'processing',
  'pending_review',
  'partially_published',
  'published',
  'completed_with_warnings',
  'failed',
};

Map<String, dynamic> importToRow(
  ImportRecord r, {
  required String? eventId,
  required String uploadedBy,
  int fileSizeBytes = 0,
}) {
  _requireUuid(r.id, 'import');
  if (!isUuid(uploadedBy)) {
    throw NotPersistableException('Sign in again before importing a file.');
  }
  final status = importStatuses.contains(r.status) ? r.status : 'pending_review';
  return {
    'id': r.id,
    'event_id': eventId,
    'file_name': r.sourceFileName,
    'file_size_bytes': fileSizeBytes,
    'uploaded_by': uploadedBy,
    'status': status,
    'summary': {
      ...r.summary,
      'warnings': r.warningCounts,
      'file_hash': r.sourceFileHash,
      'parser_version': r.parserVersion,
    },
    'warnings_count': r.warningCounts.values.fold<int>(0, (a, b) => a + b),
    'candidates_count': r.summary.values.fold<int>(0, (a, b) => a + b),
    'completed_at': r.completedAt == null ? null : _ts(r.completedAt!),
  };
}

// ─────────────────────────── Import staging tables ────────────────────────

ScheduleCandidate scheduleCandidateFromRow(Map<String, dynamic> row) {
  final start = row['start_at']?.toString();
  final end = row['end_at']?.toString();
  String clock(String? ts, Object? raw) {
    final minutes = clockMinutes(ts);
    return minutes == null ? _str(raw) : _hhmm(minutes);
  }

  final internal = row['access_type'] == 'internal';
  return ScheduleCandidate(
    id: _str(row['id']),
    date: DateTime.tryParse(_str(row['event_date'])) ??
        DateTime.tryParse(_str(row['created_at'])) ??
        DateTime.now(),
    startAt: clock(start, row['raw_start_str']),
    endAt: clock(end, row['raw_end_str']),
    title: _str(row['title']),
    venue: _str(row['venue']),
    audience: _str(row['audience']),
    // Not a column: derived so the review UI can flag rows whose times
    // couldn't be parsed out of the spreadsheet.
    classification: internal
        ? 'internal'
        : (start == null ? 'needsReview' : 'publicCandidate'),
    comparisonStatus: _str(row['comparison_status'], 'new'),
    isDuplicate: row['is_duplicate'] == true,
    isOverlapping: row['is_overlapping'] == true,
  );
}

AwardCandidate awardCandidateFromRow(Map<String, dynamic> row) => AwardCandidate(
      id: _str(row['id']),
      awardCategory: _str(row['award_category']),
      projectTitle: _str(row['project_title']),
      teamDisplayName: row['team_display_name']?.toString(),
      supervisorDisplayName: row['supervisor_display_name']?.toString(),
      programmeCode: row['programme_code']?.toString(),
      isSkip: row['is_skip'] == true,
    );

ValidationIssue validationIssueFromRow(Map<String, dynamic> row) => ValidationIssue(
      id: _str(row['id']),
      issueType: _str(row['issue_type']),
      severity: _str(row['severity'], 'warning'),
      message: _str(row['message']),
      worksheetName: _str(row['worksheet_name']),
      rowNumber: (row['row_number'] as num?)?.toInt(),
    );

PrivacySkip privacySkipFromRow(Map<String, dynamic> row) => PrivacySkip(
      id: _str(row['id']),
      skipType: _str(row['category']),
      count: 1,
      reason: _str(row['reason']),
      worksheetName: _str(row['sheet_name']),
      timestamp: DateTime.tryParse(_str(row['created_at'])) ?? DateTime.now(),
    );

ImportRecord importFromRow(Map<String, dynamic> row) {
  final summaryRaw = (row['summary'] as Map?)?.cast<String, dynamic>() ?? const {};
  Map<String, int> ints(Map<String, dynamic> src) => {
        for (final e in src.entries)
          if (e.value is num) e.key: (e.value as num).toInt(),
      };
  final warnings = (summaryRaw['warnings'] as Map?)?.cast<String, dynamic>() ?? const {};
  final fileName = _str(row['file_name'] ?? row['sourceFileName']);
  final created = row['created_at'] ?? row['uploadedAt'];
  final completed = row['completed_at'] ?? row['completedAt'];
  return ImportRecord(
    id: _str(row['id']),
    eventId: row['event_id']?.toString() ?? row['eventId']?.toString(),
    sourceFilePath: fileName,
    sourceFileName: fileName,
    sourceFileHash: _str(summaryRaw['file_hash'], _str(row['id'])),
    uploadedBy: _str(row['uploaded_by'] ?? row['uploadedBy']),
    uploadedAt: DateTime.tryParse(_str(created)) ?? DateTime.now(),
    parserVersion: _str(summaryRaw['parser_version']),
    status: _str(row['status'], 'pending_review'),
    summary: ints(summaryRaw),
    warningCounts: ints(warnings),
    completedAt: completed == null ? null : DateTime.tryParse(completed.toString()),
  );
}
