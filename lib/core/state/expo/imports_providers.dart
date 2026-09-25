import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/import_models.dart';
import '../../supabase/row_mappers.dart';
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
      final out = <ImportRecord>[];
      for (final m in data) {
        try {
          out.add(importFromRow(m));
        } catch (e) {
          logDebug('Skipping unparseable import row ${m['id']}: $e');
        }
      }
      state = out;
    } catch (e) {
      logDebug('Imports load warning: $e');
    }
  }

  /// Adds an import that has ALREADY been written (atomically, via
  /// SupabaseDatabaseService.stageImport) to the local list. Deliberately
  /// doesn't write again — that used to upsert the same record twice.
  void recordStagedImport(ImportRecord r) {
    state = [r, ...state];
  }
}

final importsProvider = NotifierProvider<ImportsNotifier, List<ImportRecord>>(
  () => ImportsNotifier(),
);

// The staging tables' columns don't match the freezed models' camelCase
// shape (e.g. `worksheet_name`, `raw_start_str`), so each goes through its
// row mapper rather than fromJson.
final scheduleCandidatesProvider =
    FutureProvider.family<List<ScheduleCandidate>, String>((ref, importId) async {
      final db = ref.read(supabaseDbServiceProvider);
      final list = await db.getScheduleCandidates(importId);
      return list.map(scheduleCandidateFromRow).toList();
    });

final awardCandidatesProvider =
    FutureProvider.family<List<AwardCandidate>, String>((ref, importId) async {
      final db = ref.read(supabaseDbServiceProvider);
      final list = await db.getAwardCandidates(importId);
      return list.map(awardCandidateFromRow).toList();
    });

final privacySkipsProvider =
    FutureProvider.family<List<PrivacySkip>, String>((ref, importId) async {
      final db = ref.read(supabaseDbServiceProvider);
      final list = await db.getPrivacySkips(importId);
      return list.map(privacySkipFromRow).toList();
    });

final validationIssuesProvider =
    FutureProvider.family<List<ValidationIssue>, String>((ref, importId) async {
      final db = ref.read(supabaseDbServiceProvider);
      final list = await db.getValidationIssues(importId);
      return list.map(validationIssueFromRow).toList();
    });
