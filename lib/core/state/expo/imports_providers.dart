import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/import_models.dart';
import '../../utils/fypms_key_normalizer.dart' show normalizeKeys;
import '../../utils/logger.dart';
import 'service_providers.dart';

// ==========================================
// EXCEL IMPORTS & STAGING WORKFLOW STATE
// ==========================================
class ImportsNotifier extends Notifier<List<ImportRecord>> {
  @override
  List<ImportRecord> build() {
    _loadImports();
    return [];
  }

  void _loadImports() async {
    try {
      final db = ref.read(supabaseDbServiceProvider);
      final data = await db.getImportsOnce();
      state = data.map((m) => ImportRecord.fromJson(normalizeKeys(m))).toList();
    } catch (e) {
      logDebug('Imports load warning: $e');
    }
  }

  void addImport(ImportRecord r) {
    state = [r, ...state];
    ref.read(supabaseDbServiceProvider).setImport(r.id, r.toJson());
  }

  void updateImport(ImportRecord updated) {
    state = [
      for (final r in state)
        if (r.id == updated.id) updated else r,
    ];
    ref.read(supabaseDbServiceProvider).setImport(updated.id, updated.toJson());
  }
}

final importsProvider = NotifierProvider<ImportsNotifier, List<ImportRecord>>(
  () => ImportsNotifier(),
);

final scheduleCandidatesProvider =
    FutureProvider.family<List<ScheduleCandidate>, String>((ref, importId) async {
      final db = ref.read(supabaseDbServiceProvider);
      final list = await db.getScheduleCandidates(importId);
      return list.map((m) => ScheduleCandidate.fromJson(normalizeKeys(m))).toList();
    });

final awardCandidatesProvider =
    FutureProvider.family<List<AwardCandidate>, String>((ref, importId) async {
      final db = ref.read(supabaseDbServiceProvider);
      final list = await db.getAwardCandidates(importId);
      return list.map((m) => AwardCandidate.fromJson(normalizeKeys(m))).toList();
    });

final privacySkipsProvider =
    FutureProvider.family<List<PrivacySkip>, String>((ref, importId) async {
      final db = ref.read(supabaseDbServiceProvider);
      final list = await db.getPrivacySkips(importId);
      return list.map((m) => PrivacySkip.fromJson(normalizeKeys(m))).toList();
    });

final validationIssuesProvider =
    FutureProvider.family<List<ValidationIssue>, String>((ref, importId) async {
      final db = ref.read(supabaseDbServiceProvider);
      final list = await db.getValidationIssues(importId);
      return list.map((m) => ValidationIssue.fromJson(normalizeKeys(m))).toList();
    });
