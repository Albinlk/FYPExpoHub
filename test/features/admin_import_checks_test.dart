import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/domain/models/award.dart';
import 'package:fyp_expo_hub/core/domain/models/import_models.dart';
import 'package:fyp_expo_hub/core/domain/models/schedule_item.dart';
import 'package:fyp_expo_hub/core/state/state_providers.dart';
import 'package:fyp_expo_hub/features/admin_imports/domain/import_checks.dart';
import 'package:fyp_expo_hub/features/admin_imports/presentation/pages/import_detail_page.dart';

ScheduleItem _live(String title, String start, String end, String venue) => ScheduleItem(
      id: title,
      eventId: 'ev',
      date: DateTime(2026, 9, 22),
      startAt: start,
      endAt: end,
      title: title,
      venue: venue,
      audience: 'General',
      visibility: 'public',
      publicationStatus: 'published',
      createdAt: DateTime(2026, 9, 1),
      updatedAt: DateTime(2026, 9, 1),
    );

Map<String, dynamic> _cand(int row, String title, String start, String end, String venue) => {
      'row_number': row,
      'event_date': '2026-09-22',
      'start_at': '2026-09-22T$start:00+08:00',
      'end_at': '2026-09-22T$end:00+08:00',
      'title': title,
      'venue': venue,
      'comparison_status': 'new',
      '_sheet': 'TENTATIF',
    };

PublishedAwardWinner _winner(String award, String team) => PublishedAwardWinner(
      id: 'w',
      eventId: 'ev',
      awardCategoryId: '',
      projectTitle: award,
      teamDisplayName: team,
      publicationStatus: 'published',
      createdAt: DateTime(2026, 9, 1),
      updatedAt: DateTime(2026, 9, 1),
    );

void main() {
  test('schedule checks: unchanged, updated, duplicate in file, overlap', () {
    final cands = [
      _cand(2, 'Opening Ceremony', '09:00', '10:00', 'Main Hall'), // identical to live
      _cand(3, 'keynote  talk', '10:30', '11:30', 'Main Hall'), // same title, new time
      _cand(4, 'Poster Walk', '12:00', '13:00', 'Lobby'),
      _cand(5, 'Poster Walk', '12:00', '13:00', 'Lobby'), // repeats row 4
      _cand(6, 'Panel', '12:30', '13:30', 'Lobby'), // overlaps Poster Walk in Lobby
    ];
    final issues = checkScheduleCandidates(
      importId: 'imp',
      defaultSheet: 'X',
      candidates: cands,
      existing: [_live('Opening Ceremony', '09:00', '10:00', 'Main Hall'), _live('Keynote Talk', '10:00', '11:00', 'Main Hall')],
    );
    expect(cands[0]['comparison_status'], 'unchanged');
    expect(cands[1]['comparison_status'], 'updated');
    expect(cands[3]['is_duplicate'], isTrue);
    expect(cands[2]['is_duplicate'], isNull, reason: 'the first occurrence is fine');
    expect(cands[4]['is_overlapping'], isTrue);
    expect(cands[4]['overlap_details'], contains('Poster Walk'));
    expect({for (final i in issues) i['issue_type']}, {'duplicate', 'changed', 'overlap'});
    expect(issues.every((i) => i['worksheet_name'] == 'TENTATIF'), isTrue);
  });

  test('award checks: repeat in file and already published', () {
    final cands = [
      {'row_number': 2, 'award_category': 'Gold Award', 'team_display_name': 'Team A'},
      {'row_number': 3, 'award_category': 'gold award', 'team_display_name': 'team a'},
      {'row_number': 4, 'award_category': 'Silver Award', 'team_display_name': 'Team B'},
    ];
    final issues = checkAwardCandidates(
      importId: 'imp',
      defaultSheet: 'PEMENANG ANUGERAH',
      candidates: cands,
      existing: [_winner('Silver Award', 'Team B')],
    );
    expect(cands[1]['is_skip'], isTrue);
    expect(cands[2]['comparison_status'], 'unchanged');
    expect(cands[2]['is_skip'], isTrue, reason: 'an already-published award defaults to Skip');
    expect(cands[0]['is_skip'], isNull, reason: 'the first new award stays Publish');
    expect(issues, hasLength(2));
  });

  test('file size, mandatory sheets and default actions', () {
    expect(parseFileSize('10 MB'), 10 * 1024 * 1024);
    expect(parseFileSize('500kb'), 500 * 1024);
    expect(parseFileSize('2.5 MB'), (2.5 * 1024 * 1024).round());
    expect(parseFileSize('big'), isNull);
    expect(missingWorksheets('TENTATIF, PEMENANG ANUGERAH', ['Tentatif Hari 1', 'Markah']), ['PEMENANG ANUGERAH']);
    expect(missingWorksheets(null, ['x']), isEmpty);
    // The production setting uses English names; the file uses Malay ones.
    expect(missingWorksheets('SCHEDULE, AWARD WINNERS, COMMITTEE', ['TENTATIF', 'PEMENANG ANUGERAH']), ['COMMITTEE']);
    expect(defaultImportAction(comparisonStatus: 'unchanged', isDuplicate: true), 'skip');
    expect(defaultImportAction(comparisonStatus: 'updated', isDuplicate: false), 'replace_existing');
    expect(defaultImportAction(comparisonStatus: 'new', isDuplicate: true), 'skip');
    expect(defaultImportAction(comparisonStatus: 'new', isDuplicate: false), 'publish');
  });

  testWidgets('G-06 review page shows the checks and picks sensible defaults', (tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    ScheduleCandidate cand(String id, String status, {bool dup = false, bool overlap = false}) => ScheduleCandidate(
          id: id,
          date: DateTime(2026, 9, 22),
          startAt: '09:00',
          endAt: '10:00',
          title: 'Item $id',
          venue: 'Main Hall',
          audience: 'General',
          classification: 'publicCandidate',
          comparisonStatus: status,
          isDuplicate: dup,
          isOverlapping: overlap,
        );
    await tester.pumpWidget(ProviderScope(
      overrides: [
        scheduleCandidatesProvider.overrideWith((ref, id) async => [
              cand('a', 'unchanged', dup: true),
              cand('b', 'updated'),
              cand('c', 'new', overlap: true),
            ]),
        awardCandidatesProvider.overrideWith((ref, id) async => const []),
        privacySkipsProvider.overrideWith((ref, id) async => const []),
        validationIssuesProvider.overrideWith((ref, id) async => const [
              ValidationIssue(
                id: 'i1',
                issueType: 'overlap',
                severity: 'warning',
                message: '"Item c" 09:00–10:00 overlaps "Talk" in Main Hall.',
                worksheetName: 'TENTATIF',
                rowNumber: 4,
              ),
              ValidationIssue(
                id: 'i2',
                issueType: 'duplicate',
                severity: 'info',
                message: '"Item a" is already on the schedule.',
                worksheetName: 'TENTATIF',
                rowNumber: 2,
              ),
            ]),
      ],
      child: const MaterialApp(home: ImportDetailPage(importId: 'imp')),
    ));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('import-issues')), findsOneWidget);
    expect(find.text('Checks: 1 to review, 1 notes'), findsOneWidget);
    expect(find.textContaining('overlaps "Talk"'), findsOneWidget);
    expect(find.text('TENTATIF · row 4'), findsOneWidget);
    expect(find.text('Already live'), findsOneWidget);
    expect(find.text('Changes a live item'), findsOneWidget);
    expect(find.text('Overlaps another item'), findsOneWidget);

    final values = [
      for (final d in tester.widgetList<DropdownButton<String>>(find.byType(DropdownButton<String>))) d.value,
    ];
    expect(values, ['skip', 'replace_existing', 'publish']);
  });
}
