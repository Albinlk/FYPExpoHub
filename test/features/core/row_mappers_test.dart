import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/domain/models/announcement.dart';
import 'package:fyp_expo_hub/core/domain/models/award.dart';
import 'package:fyp_expo_hub/core/domain/models/booth.dart';
import 'package:fyp_expo_hub/core/domain/models/event.dart';
import 'package:fyp_expo_hub/core/domain/models/feedback_entry.dart';
import 'package:fyp_expo_hub/core/domain/models/import_models.dart';
import 'package:fyp_expo_hub/core/domain/models/project.dart';
import 'package:fyp_expo_hub/core/domain/models/schedule_item.dart';
import 'package:fyp_expo_hub/core/supabase/row_mappers.dart';

const _id = '00000000-0000-4000-8000-000000000001';
const _eventId = '00000000-0000-4000-8000-00000000e001';
final _t = DateTime.utc(2026, 7, 1);

/// Column name -> required? for a table's `Insert` type in the generated
/// supabase/types.ts — the schema the live database actually has.
Map<String, bool> _insertColumns(String table) {
  final lines = File('supabase/types.ts').readAsLinesSync();
  final start = lines.indexWhere((l) => l == '      $table: {');
  expect(start, isNot(-1), reason: 'table $table not in types.ts');
  final insert = lines.indexWhere((l) => l.trim() == 'Insert: {', start);
  final cols = <String, bool>{};
  for (var i = insert + 1; !lines[i].startsWith('        }'); i++) {
    final m = RegExp(r'^\s*(\w+)(\??):').firstMatch(lines[i]);
    if (m != null) cols[m.group(1)!] = m.group(2)!.isEmpty;
  }
  return cols;
}

void _expectMatchesSchema(String table, Map<String, dynamic> row) {
  final cols = _insertColumns(table);
  final unknown = row.keys.where((k) => !cols.containsKey(k)).toList();
  expect(unknown, isEmpty,
      reason: '$table has no column(s) $unknown — PostgREST rejects the whole write');
  final missing = cols.entries
      .where((e) => e.value && !row.containsKey(e.key))
      .map((e) => e.key)
      .toList();
  expect(missing, isEmpty, reason: '$table requires $missing');
}

Project _project() => Project(
      id: _id,
      eventId: 'fskm-fyp-2026',
      slug: 'p',
      title: 'P',
      programmeCode: 'CS230',
      programmeName: 'CS',
      shortDescription: 'd',
      category: 'AI',
      technologyTags: const ['Flutter'],
      coverImageUrl: '',
      teamDisplayNames: const ['Ali', 'Abu'],
      supervisorDisplayName: 'Dr. A',
      featured: false,
      publicationStatus: 'published',
      createdAt: _t,
      updatedAt: _t,
    );

void main() {
  group('write mappers only use real columns (pinned to supabase/types.ts)', () {
    test('projects', () {
      final row = projectToRow(_project(), eventId: _eventId);
      _expectMatchesSchema('projects', row);
      expect(row['student_team'], ['Ali', 'Abu']);
      expect(row['tech_tags'], ['Flutter']);
    });

    test('schedule_items (date + clock -> event_date + MYT timestamptz)', () {
      final row = scheduleItemToRow(
        ScheduleItem(
          id: _id,
          eventId: 'fskm-fyp-2026',
          date: DateTime(2026, 8, 6),
          startAt: '01:30 PM',
          endAt: '15:00',
          title: 'T',
          venue: 'V',
          audience: 'A',
          visibility: 'internal',
          publicationStatus: 'published',
          createdAt: _t,
          updatedAt: _t,
        ),
        eventId: _eventId,
      );
      _expectMatchesSchema('schedule_items', row);
      expect(row['event_date'], '2026-08-06');
      expect(row['start_at'], '2026-08-06T13:30:00+08:00');
      expect(row['end_at'], '2026-08-06T15:00:00+08:00');
      expect(row['access_type'], 'internal');
    });

    test('booths', () {
      _expectMatchesSchema(
        'booths',
        boothToRow(
          Booth(
            id: _id,
            eventId: 'x',
            boothNumber: 'B1',
            zone: 'A',
            locationNote: '',
            projectId: 'not-a-uuid',
            publicationStatus: 'published',
            createdAt: _t,
            updatedAt: _t,
          ),
          eventId: _eventId,
        ),
      );
    });

    test('announcements', () {
      _expectMatchesSchema(
        'announcements',
        announcementToRow(
          Announcement(
            id: _id,
            eventId: 'x',
            title: 'T',
            body: 'B',
            category: 'general',
            pinned: true,
            publicationStatus: 'published',
            publishedAt: _t,
            createdAt: _t,
            updatedAt: _t,
          ),
          eventId: _eventId,
        ),
      );
    });

    test('award_winners (projectTitle -> title, non-uuid refs -> null)', () {
      final row = awardWinnerToRow(
        PublishedAwardWinner(
          id: _id,
          eventId: 'x',
          awardCategoryId: 'cat-manual',
          projectId: 'none',
          projectTitle: 'Gold',
          publicationStatus: 'published',
          createdAt: _t,
          updatedAt: _t,
        ),
        eventId: _eventId,
      );
      _expectMatchesSchema('award_winners', row);
      expect(row['title'], 'Gold');
      expect(row['category_id'], isNull);
      expect(row['project_id'], isNull);
    });

    test('feedback_entries (admin write and visitor submission)', () {
      final f = FeedbackEntry(
        id: _id,
        eventId: 'x',
        subject: 'S',
        message: 'M',
        createdAt: _t,
        updatedAt: _t,
      );
      _expectMatchesSchema('feedback_entries', feedbackToRow(f, eventId: _eventId));
      final submission = feedbackSubmissionRow(f, eventId: _eventId);
      _expectMatchesSchema('feedback_entries', submission);
      // Visitors can't set moderation fields.
      expect(submission.keys, isNot(contains('status')));
      expect(submission.keys, isNot(contains('admin_note')));
    });

    test('imports', () {
      final row = importToRow(
        ImportRecord(
          id: _id,
          sourceFilePath: 'f.xlsx',
          sourceFileName: 'f.xlsx',
          sourceFileHash: 'abc',
          uploadedBy: _id,
          uploadedAt: _t,
          parserVersion: '2',
          status: 'staged',
          summary: const {'schedule': 2, 'winners': 1},
          warningCounts: const {'issues': 1},
        ),
        eventId: _eventId,
        uploadedBy: _id,
      );
      _expectMatchesSchema('imports', row);
      // 'staged' isn't allowed by the status check constraint.
      expect(row['status'], 'pending_review');
      expect(row['candidates_count'], 3);
    });

    test('event RPC payload uses snake_case keys', () {
      final payload = eventToRow(Event(
        id: _eventId,
        title: 'T',
        sessionLabel: 'S',
        startAt: _t,
        endAt: _t.add(const Duration(days: 1)),
        dailyHours: 'h',
        venue: 'v',
        locationDetails: 'l',
        description: 'd',
        objectives: const [],
        status: 'active',
        heroImageUrl: '',
        posterUrl: '',
        publicContactEmail: '',
        faqItems: const [FaqItem(question: 'q', answer: 'a')],
        publicationStatus: 'published',
        updatedAt: _t,
      ));
      final cols = _insertColumns('events');
      expect(payload.keys.where((k) => !cols.containsKey(k)), isEmpty);
      expect(payload['faq_items'], [
        {'question': 'q', 'answer': 'a'},
      ]);
    });
  });

  group('read mappers accept live rows', () {
    test('project row with nulls in nullable columns still parses', () {
      final p = projectFromRow({
        'id': _id,
        'event_id': _eventId,
        'slug': 's',
        'title': 'T',
        'category': null,
        'cover_image_url': null,
        'programme_code': null,
        'tech_tags': null,
        'student_team': ['Ali'],
        'publication_status': 'published',
        'created_at': '2026-07-01T00:00:00Z',
        'updated_at': '2026-07-01T00:00:00Z',
      });
      expect(p.category, '');
      expect(p.coverImageUrl, '');
      expect(p.teamDisplayNames, ['Ali']);
    });

    test('schedule row: event_date + timestamptz + access_type', () {
      final s = scheduleItemFromRow({
        'id': _id,
        'event_id': _eventId,
        'event_date': '2026-08-06',
        'start_at': '2026-08-06T01:30:00+00:00', // 09:30 MYT
        'end_at': '2026-08-06T03:00:00+00:00',
        'title': 'T',
        'venue': null,
        'audience': null,
        'access_type': 'internal',
        'publication_status': 'published',
        'created_at': '2026-07-01T00:00:00Z',
        'updated_at': '2026-07-01T00:00:00Z',
      });
      expect(s.date, DateTime(2026, 8, 6));
      expect(s.startAt, '09:30');
      expect(s.endAt, '11:00');
      expect(s.visibility, 'internal');
    });

    test('schedule row: bundled fallback shape still works', () {
      final s = scheduleItemFromRow({
        'id': 'sch-slot-1',
        'event_id': 'fskm-fyp-2026',
        'date': '2026-08-06T00:00:00',
        'start_at': '09:00',
        'end_at': '10:30',
        'title': 'T',
        'venue': 'V',
        'audience': 'A',
        'visibility': 'public',
        'publication_status': 'published',
        'created_at': '2026-07-01T00:00:00',
        'updated_at': '2026-07-01T00:00:00',
      });
      expect(s.startAt, '09:00');
      expect(s.visibility, 'public');
    });

    test('award row: title -> projectTitle, single team string kept', () {
      final w = awardWinnerFromRow({
        'id': _id,
        'event_id': _eventId,
        'title': 'Gold',
        'team_display_name': 'Ali, Abu',
        'publication_status': 'published',
        'created_at': '2026-07-01T00:00:00Z',
        'updated_at': '2026-07-01T00:00:00Z',
      });
      expect(w.projectTitle, 'Gold');
      expect(w.teamDisplayName, 'Ali, Abu');
    });

    test('announcement row with null published_at falls back to created_at', () {
      final a = announcementFromRow({
        'id': _id,
        'event_id': _eventId,
        'title': 'T',
        'body': 'B',
        'is_pinned': true,
        'published_at': null,
        'publication_status': 'draft',
        'created_at': '2026-07-01T00:00:00Z',
        'updated_at': '2026-07-01T00:00:00Z',
      });
      expect(a.pinned, isTrue);
      expect(a.publishedAt, DateTime.parse('2026-07-01T00:00:00Z'));
    });
  });

  group('time parsing', () {
    test('clockMinutes handles 24h, 12h and edge hours', () {
      expect(clockMinutes('09:00'), 540);
      expect(clockMinutes('9:00 AM'), 540);
      expect(clockMinutes('12:00 AM'), 0);
      expect(clockMinutes('12:30 PM'), 750);
      expect(clockMinutes('01:00 PM'), 780);
      expect(clockMinutes('25:00'), isNull);
      expect(clockMinutes('noon'), isNull);
    });

    test('importTimeRange reads common spreadsheet formats', () {
      expect(importTimeRange('9:00 AM - 10:30 AM'), ('09:00', '10:30'));
      expect(importTimeRange('1:00 - 2:30 PM'), ('13:00', '14:30'));
      expect(importTimeRange('0900-1030'), ('09:00', '10:30'));
      expect(importTimeRange('09.00 hingga 10.30'), ('09:00', '10:30'));
      expect(importTimeRange('10:00 - 09:00'), isNull);
      expect(importTimeRange('TBA'), isNull);
    });

    test('importDayDate counts from the event start (Malaysia time)', () {
      // 01:00 UTC on 6 Aug is 09:00 MYT on 6 Aug.
      final start = DateTime.utc(2026, 8, 6, 1);
      expect(importDayDate('Day 1', start), DateTime(2026, 8, 6));
      expect(importDayDate('Hari 2', start), DateTime(2026, 8, 7));
      expect(importDayDate('2026-08-09', start), DateTime(2026, 8, 9));
      expect(importDayDate('Opening', start), isNull);
    });
  });
}
