import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../supabase/supabase_client_provider.dart';
import '../../utils/logger.dart';
import '../expo/service_providers.dart';

// ==============================================================================
// CURRENT USER'S FYPMS ROLES
// ==============================================================================

/// Resolves the active FYPMS role codes for the current user, based on
/// `profile_academic_roles` (plus `profiles.role` for admin).
final fypmsCurrentRolesProvider = FutureProvider<List<String>>((ref) async {
  final user = ref.watch(currentAuthUserProvider);
  if (user == null) return const [];

  final client = ref.watch(supabaseClientProvider);
  try {
    final profile = await client
        .from('profiles')
        .select('role')
        .eq('id', user.id)
        .maybeSingle();
    final roles = <String>{};
    if (profile != null) {
      final profileRole = profile['role'] as String?;
      if (profileRole == 'admin') roles.add('admin');
    }

    final data = await client
        .from('profile_academic_roles')
        .select('role_code')
        .eq('profile_id', user.id)
        .eq('is_active', true);
    for (final row in data) {
      final code = row['role_code'] as String?;
      if (code != null && code.isNotEmpty) roles.add(code);
    }
    return roles.toList();
  } catch (e) {
    logDebug('fypmsCurrentRolesProvider error: $e');
    return const [];
  }
});

/// True when the current user holds the coordinator role (or admin).
final isFypCoordinatorProvider = Provider<bool>((ref) {
  final roles = ref.watch(fypmsCurrentRolesProvider);
  return roles.value?.contains('fyp_coordinator') == true ||
      roles.value?.contains('admin') == true;
});

/// True when the current user is an admin.
final isFypAdminProvider = Provider<bool>((ref) {
  final roles = ref.watch(fypmsCurrentRolesProvider);
  return roles.value?.contains('admin') == true;
});

/// True when the current user is a student.
final isFypStudentProvider = Provider<bool>((ref) {
  final roles = ref.watch(fypmsCurrentRolesProvider);
  return roles.value?.contains('student') == true;
});

/// True when the current user is a supervisor (main or co).
final isFypSupervisorProvider = Provider<bool>((ref) {
  final roles = ref.watch(fypmsCurrentRolesProvider);
  return roles.value?.contains('supervisor') == true ||
      roles.value?.contains('co_supervisor') == true;
});

/// True when the current user is an examiner.
final isFypExaminerProvider = Provider<bool>((ref) {
  final roles = ref.watch(fypmsCurrentRolesProvider);
  return roles.value?.contains('examiner') == true;
});

/// True when the current user is a CSP lecturer (CSP600 or CSP650).
final isCspLecturerProvider = Provider<bool>((ref) {
  final roles = ref.watch(fypmsCurrentRolesProvider);
  return roles.value?.contains('csp600_lecturer') == true ||
      roles.value?.contains('csp650_lecturer') == true;
});

// ==============================================================================
// FYPMS FEATURE FLAGS (from settings.fypms_features)
// ==============================================================================

class FypmsFeatures {
  final bool specialEvaluationEnabled;
  const FypmsFeatures({this.specialEvaluationEnabled = false});

  factory FypmsFeatures.fromJson(Map<String, dynamic> json) {
    return FypmsFeatures(
      specialEvaluationEnabled:
          (json['special_evaluation_enabled'] as bool?) ?? false,
    );
  }
}

final fypmsFeaturesProvider = FutureProvider<FypmsFeatures>((ref) async {
  final db = ref.watch(supabaseDbServiceProvider);
  final raw = await db.getSetting('fypms_features');
  if (raw == null) return const FypmsFeatures();
  return FypmsFeatures.fromJson(raw);
});

/// Form codes that are always available.
const List<String> fypmsAlwaysEnabledFormCodes = [
  'F1', 'F2', 'F3', 'F4', 'F6a', 'F7', 'F8', 'F9', 'F10', 'F11', 'F12', 'F13',
];

/// Form codes that are only available when `special_evaluation_enabled` is true.
const List<String> fypmsSpecialEvaluationFormCodes = ['F14', 'F15', 'F16'];

/// The full list of form codes the current user can submit/see, honouring the
/// `fypms_features.special_evaluation_enabled` flag (F14-F16 gate).
final fypmsAvailableFormCodesProvider = Provider<List<String>>((ref) {
  final features = ref.watch(fypmsFeaturesProvider);
  final specialEnabled = features.value?.specialEvaluationEnabled ?? false;
  return [
    ...fypmsAlwaysEnabledFormCodes,
    if (specialEnabled) ...fypmsSpecialEvaluationFormCodes,
  ];
});
