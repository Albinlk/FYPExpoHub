import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fyp_expo_hub/core/domain/models/project.dart';
import 'package:fyp_expo_hub/core/domain/models/project_lecturer_assignment.dart';
import 'package:fyp_expo_hub/core/domain/models/student_visit.dart';
import 'package:fyp_expo_hub/core/state/state_providers.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_client_provider.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_rpc_service.dart';
import 'package:fyp_expo_hub/features/lecturer_visits/presentation/pages/lecturer_visit_detail_page.dart';

Project _project() => Project(
      id: 'proj-1',
      eventId: 'fskm-fyp-2026',
      slug: 'ai-health-assistant',
      title: 'AI Health Assistant',
      matricId: '2026123456',
      programmeCode: 'CS266',
      programmeName: 'Bachelor of Computer Science (Hons)',
      shortDescription: 'An AI-powered health assistant.',
      category: 'Software Engineering',
      technologyTags: const ['Flutter', 'Supabase'],
      boothNumber: 'B12',
      boothZone: 'Zone A',
      coverImageUrl: 'https://placehold.co/400x250',
      teamDisplayNames: const ['Ali Bin Abu'],
      supervisorDisplayName: 'Dr. Aminah',
      examinerDisplayName: 'Dr. Rahman',
      featured: false,
      calonIndustri: true,
      publicationStatus: 'published',
      createdAt: DateTime(2026, 7, 1),
      updatedAt: DateTime(2026, 7, 1),
      publishedAt: DateTime(2026, 7, 1),
    );

ProjectLecturerAssignment _svAssignment() => ProjectLecturerAssignment(
      id: 'asg-sv',
      eventId: 'fskm-fyp-2026',
      projectId: 'proj-1',
      lecturerDisplayName: 'Dr. Aminah',
      lecturerId: 'lecturer-uid-1',
      role: 'supervisor',
      status: 'active',
      assignedAt: DateTime(2026, 7, 1),
      updatedAt: DateTime(2026, 7, 1),
    );

ProjectLecturerAssignment _exAssignment() => ProjectLecturerAssignment(
      id: 'asg-ex',
      eventId: 'fskm-fyp-2026',
      projectId: 'proj-1',
      lecturerDisplayName: 'Dr. Rahman',
      lecturerId: 'lecturer-uid-1',
      role: 'examiner',
      status: 'active',
      assignedAt: DateTime(2026, 7, 1),
      updatedAt: DateTime(2026, 7, 1),
    );

StudentVisit _completedVisit(String role) => StudentVisit(
      id: 'visit-${role == 'supervisor' ? 'sv' : 'ex'}',
      eventId: 'fskm-fyp-2026',
      projectId: 'proj-1',
      assignmentId: role == 'supervisor' ? 'asg-sv' : 'asg-ex',
      lecturerId: 'lecturer-uid-1',
      visitRole: role,
      visitedAt: DateTime(2026, 8, 6, 10, 30),
      visitNote: 'Great demo.',
      status: 'completed',
      createdAt: DateTime(2026, 8, 6, 10, 30),
      updatedAt: DateTime(2026, 8, 6, 10, 30),
    );

/// Captures markStudentProjectVisited / voidStudentProjectVisit calls so the
/// page under test never touches the network.
class _RecordingRpcService extends SupabaseRpcService {
  _RecordingRpcService()
      : super(SupabaseClient(
          'https://placeholder-project.supabase.co',
          'placeholder-anon-key',
          authOptions: const AuthClientOptions(autoRefreshToken: false),
        ));

  final List<Map<String, String>> markCalls = [];
  final List<Map<String, String>> voidCalls = [];
  Object? markError;

  @override
  Future<Map<String, dynamic>> markStudentProjectVisited({
    required String assignmentId,
    String? visitNote,
  }) async {
    if (markError != null) throw markError!;
    markCalls.add({
      'assignmentId': assignmentId,
      'visitNote': visitNote ?? '',
    });
    return {'id': 'new-visit', 'status': 'completed'};
  }

  @override
  Future<Map<String, dynamic>> voidStudentProjectVisit({
    required String visitId,
    required String reason,
  }) async {
    voidCalls.add({'visitId': visitId, 'reason': reason});
    return {'id': visitId, 'status': 'voided'};
  }
}

Widget _app({
  required _RecordingRpcService rpc,
  List<ProjectLecturerAssignment> assignments = const [],
  List<StudentVisit> visits = const [],
  User? user,
}) {
  return ProviderScope(
    overrides: [
      supabaseRpcServiceProvider.overrideWithValue(rpc),
      publicProjectsProvider.overrideWith(() => _ProjectsNotifierStub([_project()])),
      lecturerAssignmentsProvider.overrideWith((ref) => assignments),
      lecturerVisitsProvider.overrideWith((ref) => visits),
      currentAuthUserProvider.overrideWith((ref) => user),
    ],
    child: MaterialApp(
      home: LecturerVisitDetailPage(projectId: 'proj-1'),
    ),
  );
}

/// Notifier stub that returns a fixed project list without hitting Supabase.
class _ProjectsNotifierStub extends ProjectsNotifier {
  _ProjectsNotifierStub(this._projects);

  final List<Project> _projects;

  @override
  List<Project> build() => _projects;
}

User _fakeUser() => User(
      id: 'lecturer-uid-1',
      email: 'dr.aminah@uitm.edu.my',
      aud: 'authenticated',
      appMetadata: const {},
      userMetadata: const {},
      createdAt: DateTime(2026, 7, 1).toIso8601String(),
    );

void main() {
  testWidgets('shows project header, both role sections and Mark as Visited buttons when no visits exist',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final rpc = _RecordingRpcService();
    await tester.pumpWidget(_app(
      rpc: rpc,
      assignments: [_svAssignment(), _exAssignment()],
    ));
    await tester.pumpAndSettle();

    expect(find.text('AI Health Assistant'), findsWidgets);
    expect(find.text('Supervisor (SV)'), findsOneWidget);
    expect(find.text('Examiner (EX)'), findsOneWidget);
    expect(find.text('Industry Candidate'), findsOneWidget);
    expect(find.text('Booth B12'), findsOneWidget);
    expect(find.text('Mark as Visited'), findsNWidgets(2));
    expect(find.text('Not Visited'), findsNWidgets(2));
  });

  testWidgets('mark as visited opens dialog and forwards assignmentId + note to the RPC',
      (tester) async {
    final rpc = _RecordingRpcService();
    await tester.pumpWidget(_app(
      rpc: rpc,
      assignments: [_svAssignment(), _exAssignment()],
      user: _fakeUser(),
    ));
    await tester.pumpAndSettle();

    // Open the supervisor's mark-visited dialog (first of the two buttons).
    await tester.tap(find.text('Mark as Visited').first);
    await tester.pumpAndSettle();

    expect(find.text('Mark as Visited'), findsWidgets); // dialog title
    expect(find.text('Role: Supervisor (SV)'), findsOneWidget);

    await tester.enterText(
      find.descendant(
        of: find.byType(TextField),
        matching: find.byType(EditableText),
      ),
      'Excellent progress',
    );
    await tester.tap(find.text('Confirm Visit'));
    await tester.pump(); // dialog pops, RPC starts
    await tester.pumpAndSettle();

    expect(rpc.markCalls, [
      {'assignmentId': 'asg-sv', 'visitNote': 'Excellent progress'},
    ]);
    expect(find.text('Student has been marked as visited.'), findsOneWidget);
  });

  testWidgets('completed visit shows visit details and Cancel Visit action',
      (tester) async {
    final rpc = _RecordingRpcService();
    await tester.pumpWidget(_app(
      rpc: rpc,
      assignments: [_svAssignment(), _exAssignment()],
      visits: [_completedVisit('supervisor')],
    ));
    await tester.pumpAndSettle();

    expect(find.text('Visited'), findsOneWidget); // SV section chip
    expect(find.text('Not Visited'), findsOneWidget); // EX section still unvisited
    expect(find.text('Visit Time'), findsOneWidget);
    expect(find.text('Note'), findsOneWidget);
    expect(find.text('Great demo.'), findsOneWidget);
    expect(find.text('Cancel Visit'), findsOneWidget);
    expect(find.text('Mark as Visited'), findsOneWidget); // EX only
  });

  testWidgets('cancel visit requires and forwards the typed reason',
      (tester) async {
    final rpc = _RecordingRpcService();
    await tester.pumpWidget(_app(
      rpc: rpc,
      assignments: [_svAssignment(), _exAssignment()],
      visits: [_completedVisit('supervisor')],
      user: _fakeUser(),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel Visit'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.enterText(
      find.descendant(
        of: find.byType(TextField),
        matching: find.byType(EditableText),
      ),
      'Student not at booth',
    );
    // Dialog button is the ElevatedButton (the TextButton is "Close").
    await tester.tap(find.descendant(
      of: find.byType(ElevatedButton),
      matching: find.text('Cancel Visit'),
    ));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(rpc.voidCalls, [
      {'visitId': 'visit-sv', 'reason': 'Student not at booth'},
    ]);
    expect(find.text('Visit has been cancelled. Student can be revisited.'),
        findsOneWidget);
  });

  testWidgets('permission-denied RPC error surfaces a friendly message',
      (tester) async {
    final rpc = _RecordingRpcService()
      ..markError = Exception('permission-denied: not your assignment');
    await tester.pumpWidget(_app(
      rpc: rpc,
      assignments: [_svAssignment(), _exAssignment()],
      user: _fakeUser(),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mark as Visited').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm Visit'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('You are not allowed to mark this visit.'), findsOneWidget);
  });

  testWidgets('project not found renders the fallback scaffold', (tester) async {
    final rpc = _RecordingRpcService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseRpcServiceProvider.overrideWithValue(rpc),
          publicProjectsProvider.overrideWith(() => _ProjectsNotifierStub([])),
          lecturerAssignmentsProvider.overrideWith((ref) => []),
          lecturerVisitsProvider.overrideWith((ref) => []),
          currentAuthUserProvider.overrideWith((ref) => null),
        ],
        child: MaterialApp(
          home: LecturerVisitDetailPage(projectId: 'missing'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Project not found.'), findsOneWidget);
  });
}
