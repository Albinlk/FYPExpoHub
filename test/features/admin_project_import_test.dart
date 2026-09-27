import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/domain/models/project.dart';
import 'package:fyp_expo_hub/core/state/state_providers.dart';
import 'package:fyp_expo_hub/features/admin_projects/domain/project_import.dart';
import 'package:fyp_expo_hub/features/admin_projects/presentation/widgets/project_import_dialog.dart';

Project _project(String title, String booth) => Project(
      id: title,
      eventId: 'fskm-fyp-2026',
      slug: title.toLowerCase(),
      title: title,
      programmeCode: 'CS266',
      programmeName: 'Computer Science',
      shortDescription: '',
      category: 'Software Engineering',
      technologyTags: const [],
      boothNumber: booth,
      coverImageUrl: '',
      teamDisplayNames: const ['Ali'],
      supervisorDisplayName: 'Dr. Aminah',
      featured: false,
      calonIndustri: false,
      publicationStatus: 'published',
      createdAt: DateTime(2026, 7, 1),
      updatedAt: DateTime(2026, 7, 1),
    );

class _Projects extends ProjectsNotifier {
  _Projects(this.list);
  final List<Project> list;

  @override
  List<Project> build() => list;
}

const _csv = 'Tajuk,Nama Pelajar,Penyelia,No Gerai,Zon,Tags,Notes\n'
    '"Smart Parking, ESP32",Ali; Abu,Dr. Aminah,a-01,A,"IoT, MQTT",x\n'
    'Existing Project,Siti,Dr. B,A-02,A,,\n'
    'Chatbot,Chong,Dr. C,A-03,A,,\n'
    'Another,Mei,Dr. D,A-01,A,,\n'
    ',,,,,,\n'
    'smart parking,  esp32,Zul,Dr. E,,,,\n';

void main() {
  test('F5 CSV keeps quoted commas and maps Malay headers', () {
    final grid = parseCsvRows(_csv);
    expect(grid.first.first, 'Tajuk');
    expect(grid[1].first, 'Smart Parking, ESP32');

    final parse = parseProjectSheet(grid);
    expect(parse.error, isNull);
    expect(parse.unmatchedHeaders, ['Notes']);
    final first = parse.rows.first;
    expect(first.rowNumber, 2);
    expect(first.values['student_team'], ['Ali', 'Abu']);
    expect(first.values['tech_tags'], ['IoT', 'MQTT']);
    expect(first.boothNumber, 'a-01');
  });

  test('F5 checks flag existing titles, repeated booths and booths held by another project', () {
    final rows = parseProjectSheet(parseCsvRows(_csv)).rows;
    final problems = checkProjectImport(
      rows,
      existingTitles: ['existing  project'],
      existingBooths: {'A-03': 'Somebody Else'},
    );
    expect(rows[1].existing, isTrue);
    expect(rows[2].problem, 'Booth A-03 already belongs to another project.');
    expect(rows[3].problem, 'Booth A-01 is also on row 2.');
    expect(problems, 2);
  });

  test('F5 a sheet without a title column is refused', () {
    expect(parseProjectSheet([
      ['Name', 'Booth'],
      ['Ali', 'A1'],
    ]).error, contains('title'));
  });

  testWidgets('F5 dialog previews, skips existing rows and imports the rest', (tester) async {
    tester.view.physicalSize = const Size(1000, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final sent = <List<Map<String, Object>>>[];
    await tester.pumpWidget(ProviderScope(
      overrides: [
        projectsProvider.overrideWith(() => _Projects([_project('Existing Project', 'A-02')])),
        importEventProjectsProvider.overrideWithValue((rows, onDuplicate, publish) async {
          sent.add(rows);
          return {'inserted': rows.length, 'updated': 0, 'skipped': 0, 'booths_linked': 2, 'problems': <Object>[]};
        }),
      ],
      child: MaterialApp(
        home: Scaffold(body: ProjectImportDialog(initialGrid: parseCsvRows(_csv), initialFileName: 'master.csv')),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('master.csv'), findsOneWidget);
    expect(find.byKey(const Key('import-summary')), findsOneWidget);

    // Smart Parking, Chatbot and "smart parking,  esp32"... the last row
    // has a shifted title ("smart parking"), so it is new too.
    await tester.tap(find.widgetWithText(FilledButton, 'Import 3'));
    await tester.pumpAndSettle();
    expect(sent.single.map((r) => r['title']), ['Smart Parking, ESP32', 'Chatbot', 'smart parking']);
    expect(find.byKey(const Key('import-result')), findsOneWidget);
  });
}
