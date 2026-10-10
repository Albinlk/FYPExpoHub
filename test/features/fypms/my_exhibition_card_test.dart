import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_expo_publication.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_record.dart';
import 'package:fyp_expo_hub/core/domain/models/project.dart';
import 'package:fyp_expo_hub/core/state/fypms_state_providers.dart';
import 'package:fyp_expo_hub/core/state/state_providers.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/widgets/my_exhibition_card.dart';

/// P8: a CSP650 student sees whether their exhibition entry is published and,
/// once it is, where and when.
FypRecord _rec(String course) => FypRecord(
      id: 'rec-1',
      academicSemesterId: 's26',
      studentId: 'stu-1',
      currentCourseCode: course,
      programmeCode: 'CS266',
      workflowStatus: 'project_registered',
      createdAt: DateTime(2026, 3, 1),
      updatedAt: DateTime(2026, 3, 1),
    );

FypExpoPublication _pub(String status, {String? project}) => FypExpoPublication(
      id: 'pub-1',
      fypRecordId: 'rec-1',
      eventId: 'ev-1',
      status: status,
      payload: const {},
      publishedProjectId: project,
      createdAt: DateTime(2026, 7, 1),
      updatedAt: DateTime(2026, 7, 1),
    );

Project _project() => Project(
      id: 'proj-1',
      eventId: 'ev-1',
      slug: 'smart-campus',
      title: 'Smart Campus',
      programmeCode: 'CS266',
      programmeName: 'Computer Science',
      shortDescription: '',
      category: 'Computer Science',
      technologyTags: const [],
      boothNumber: 'BK1-07',
      presentationDay: 'Day 2 - 07 Aug 2026',
      coverImageUrl: '',
      teamDisplayNames: const ['Ali'],
      supervisorDisplayName: 'Dr. A',
      featured: false,
      publicationStatus: 'published',
      createdAt: DateTime(2026, 7, 1),
      updatedAt: DateTime(2026, 7, 1),
    );

class _Projects extends ProjectsNotifier {
  _Projects(this._list);
  final List<Project> _list;

  @override
  List<Project> build() => _list;
}

Future<void> _pump(WidgetTester tester, FypRecord record, List<Override> overrides) async {
  await tester.pumpWidget(ProviderScope(
    overrides: [
      publicProjectsProvider.overrideWith(() => _Projects([_project()])),
      ...overrides,
    ],
    child: MaterialApp(home: Scaffold(body: SingleChildScrollView(child: MyExhibitionCard(record: record)))),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('hidden for a CSP600 record', (tester) async {
    await _pump(tester, _rec('CSP600'), [fypExpoPublicationsProvider.overrideWith((ref) async => [])]);
    expect(find.text('My Exhibition'), findsNothing);
  });

  testWidgets('not published yet', (tester) async {
    await _pump(tester, _rec('CSP650'), [fypExpoPublicationsProvider.overrideWith((ref) async => [])]);
    expect(find.text('Not published yet'), findsOneWidget);
    expect(find.textContaining('no presentation means an F'), findsOneWidget);
  });

  testWidgets('being prepared', (tester) async {
    await _pump(tester, _rec('CSP650'), [fypExpoPublicationsProvider.overrideWith((ref) async => [_pub('ready')])]);
    expect(find.text('Being prepared'), findsOneWidget);
  });

  testWidgets('published shows booth, day and the page link', (tester) async {
    await _pump(tester, _rec('CSP650'), [
      fypExpoPublicationsProvider.overrideWith((ref) async => [_pub('published', project: 'proj-1')]),
    ]);
    expect(find.text('Published'), findsOneWidget);
    expect(find.text('Booth BK1-07 · Day 2 - 07 Aug 2026'), findsOneWidget);
    expect(find.text('View My Exhibition Page'), findsOneWidget);
  });
}
