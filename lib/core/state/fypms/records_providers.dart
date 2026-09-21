import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/fypms/fyp_record.dart';
import '../../supabase/fypms_database_service.dart';
import '../../supabase/supabase_client_provider.dart';
import '../../utils/fypms_key_normalizer.dart';
import '../expo/service_providers.dart';

// ==============================================================================
// FYP RECORDS (per current user)
// ==============================================================================

/// All FYP records the current user can see (RLS-scoped).
final fypRecordsProvider = FutureProvider<List<FypRecord>>((ref) async {
  final db = ref.watch(supabaseDbServiceProvider);
  final data = await db.getFypRecordsOnce();
  return data.map((m) => FypRecord.fromJson(normalizeFypmsKeys(m))).toList();
});

/// FYP records owned by the current student.
final myFypRecordsProvider = FutureProvider<List<FypRecord>>((ref) async {
  final user = ref.watch(currentAuthUserProvider);
  if (user == null) return const [];
  final db = ref.watch(supabaseDbServiceProvider);
  final data = await db.getMyFypRecordsOnce(user.id);
  return data.map((m) => FypRecord.fromJson(normalizeFypmsKeys(m))).toList();
});

/// FYP records assigned to the current lecturer (optionally by role).
/// Optimized: fetches only assigned ids via `inFilter`, not full table.
final assignedFypRecordsProvider =
    FutureProvider.family<List<FypRecord>, String?>((ref, role) async {
  final user = ref.watch(currentAuthUserProvider);
  if (user == null) return const [];
  final db = ref.watch(supabaseDbServiceProvider);
  final assignments = await db.getRecordsAssignedToLecturerOnce(user.id, role: role);
  final recordIds = assignments
      .map((m) => m['fyp_record_id'] as String?)
      .whereType<String>()
      .toSet();
  if (recordIds.isEmpty) return const [];
  final rows = await db.getFypRecordsByIdsOnce(recordIds);
  return rows.map((m) => FypRecord.fromJson(normalizeFypmsKeys(m))).toList();
});
