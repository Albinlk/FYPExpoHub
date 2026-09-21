import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/state/fypms_state_providers.dart';

/// Covers the role-derived boolean providers and the feature-flag-gated
/// form-codes provider in `lib/core/state/fypms/roles_providers.dart`
/// (exported via the `fypms_state_providers.dart` barrel). These are pure
/// derivations over an overridden role list / feature flag, so no Supabase
/// mocking is needed.
ProviderContainer _containerWithRoles(List<String> roles) {
  final container = ProviderContainer(
    overrides: [
      fypmsCurrentRolesProvider.overrideWith((ref) async => roles),
    ],
  );
  return container;
}

void main() {
  group('FYPMS role-derived providers', () {
    test('isFypCoordinatorProvider is true for coordinator or admin', () async {
      final coordinator = _containerWithRoles(['fyp_coordinator']);
      addTearDown(coordinator.dispose);
      await coordinator.read(fypmsCurrentRolesProvider.future);
      expect(coordinator.read(isFypCoordinatorProvider), isTrue);

      final admin = _containerWithRoles(['admin']);
      addTearDown(admin.dispose);
      await admin.read(fypmsCurrentRolesProvider.future);
      expect(admin.read(isFypCoordinatorProvider), isTrue);

      final student = _containerWithRoles(['student']);
      addTearDown(student.dispose);
      await student.read(fypmsCurrentRolesProvider.future);
      expect(student.read(isFypCoordinatorProvider), isFalse);
    });

    test('isFypAdminProvider is true only for admin', () async {
      final admin = _containerWithRoles(['admin']);
      addTearDown(admin.dispose);
      await admin.read(fypmsCurrentRolesProvider.future);
      expect(admin.read(isFypAdminProvider), isTrue);

      final coordinator = _containerWithRoles(['fyp_coordinator']);
      addTearDown(coordinator.dispose);
      await coordinator.read(fypmsCurrentRolesProvider.future);
      expect(coordinator.read(isFypAdminProvider), isFalse);
    });

    test('isFypSupervisorProvider is true for supervisor or co_supervisor', () async {
      final supervisor = _containerWithRoles(['supervisor']);
      addTearDown(supervisor.dispose);
      await supervisor.read(fypmsCurrentRolesProvider.future);
      expect(supervisor.read(isFypSupervisorProvider), isTrue);

      final coSupervisor = _containerWithRoles(['co_supervisor']);
      addTearDown(coSupervisor.dispose);
      await coSupervisor.read(fypmsCurrentRolesProvider.future);
      expect(coSupervisor.read(isFypSupervisorProvider), isTrue);

      final student = _containerWithRoles(['student']);
      addTearDown(student.dispose);
      await student.read(fypmsCurrentRolesProvider.future);
      expect(student.read(isFypSupervisorProvider), isFalse);
    });

    test('isFypStudentProvider and isFypExaminerProvider match their role codes',
        () async {
      final student = _containerWithRoles(['student']);
      addTearDown(student.dispose);
      await student.read(fypmsCurrentRolesProvider.future);
      expect(student.read(isFypStudentProvider), isTrue);
      expect(student.read(isFypExaminerProvider), isFalse);

      final examiner = _containerWithRoles(['examiner']);
      addTearDown(examiner.dispose);
      await examiner.read(fypmsCurrentRolesProvider.future);
      expect(examiner.read(isFypExaminerProvider), isTrue);
      expect(examiner.read(isFypStudentProvider), isFalse);
    });

    test('isCspLecturerProvider is true for csp600 or csp650 lecturer', () async {
      final csp600 = _containerWithRoles(['csp600_lecturer']);
      addTearDown(csp600.dispose);
      await csp600.read(fypmsCurrentRolesProvider.future);
      expect(csp600.read(isCspLecturerProvider), isTrue);

      final csp650 = _containerWithRoles(['csp650_lecturer']);
      addTearDown(csp650.dispose);
      await csp650.read(fypmsCurrentRolesProvider.future);
      expect(csp650.read(isCspLecturerProvider), isTrue);

      final none = _containerWithRoles([]);
      addTearDown(none.dispose);
      await none.read(fypmsCurrentRolesProvider.future);
      expect(none.read(isCspLecturerProvider), isFalse);
    });
  });

  group('fypmsAvailableFormCodesProvider', () {
    test('excludes F14-F16 when special evaluation is disabled', () async {
      final container = ProviderContainer(
        overrides: [
          fypmsFeaturesProvider.overrideWith(
            (ref) async => const FypmsFeatures(specialEvaluationEnabled: false),
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(fypmsFeaturesProvider.future);

      final codes = container.read(fypmsAvailableFormCodesProvider);
      expect(codes, containsAll(fypmsAlwaysEnabledFormCodes));
      expect(codes, isNot(contains('F14')));
      expect(codes, isNot(contains('F15')));
      expect(codes, isNot(contains('F16')));
    });

    test('includes F14-F16 when special evaluation is enabled', () async {
      final container = ProviderContainer(
        overrides: [
          fypmsFeaturesProvider.overrideWith(
            (ref) async => const FypmsFeatures(specialEvaluationEnabled: true),
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(fypmsFeaturesProvider.future);

      final codes = container.read(fypmsAvailableFormCodesProvider);
      expect(codes, containsAll(fypmsAlwaysEnabledFormCodes));
      expect(codes, containsAll(fypmsSpecialEvaluationFormCodes));
    });
  });
}
