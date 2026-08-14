import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/import_models.dart';
import '../../../../core/supabase/supabase_client_provider.dart';
import '../../../../core/state/state_providers.dart';

class AdminImportsPage extends ConsumerStatefulWidget {
  const AdminImportsPage({super.key});

  @override
  ConsumerState<AdminImportsPage> createState() => _AdminImportsPageState();
}

class _AdminImportsPageState extends ConsumerState<AdminImportsPage> {
  bool _isProcessing = false;
  String? _statusMessage;

  Future<void> _pickAndParseExcel() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not read file bytes.')),
        );
      }
      return;
    }

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Parsing Excel sheets in browser memory...';
    });

    try {
      final user = ref.read(currentAuthUserProvider);
      final importId = const Uuid().v4();
      final now = DateTime.now();

      final excel = Excel.decodeBytes(bytes);

      final scheduleCandidates = <Map<String, dynamic>>[];
      final awardCandidates = <Map<String, dynamic>>[];
      final validationIssues = <Map<String, dynamic>>[];
      final privacySkips = <Map<String, dynamic>>[];

      // 1. Process worksheets
      for (final table in excel.tables.keys) {
        final sheet = excel.tables[table]!;
        final sheetNameUpper = table.toUpperCase();

        if (sheetNameUpper.contains('TENTATIF') || sheetNameUpper.contains('SCHEDULE')) {
          // Parse Schedule Rows
          for (int r = 1; r < sheet.rows.length; r++) {
            final row = sheet.rows[r];
            if (row.isEmpty) continue;

            final dayLabel = row.isNotEmpty && row[0] != null ? row[0]!.value.toString().trim() : 'Day 1';
            final timeStr = row.length > 1 && row[1] != null ? row[1]!.value.toString().trim() : '';
            final title = row.length > 2 && row[2] != null ? row[2]!.value.toString().trim() : '';
            final venue = row.length > 3 && row[3] != null ? row[3]!.value.toString().trim() : 'FSKM Complex';
            final audience = row.length > 4 && row[4] != null ? row[4]!.value.toString().trim() : 'General';

            if (title.isEmpty) continue;

            scheduleCandidates.add({
              'id': const Uuid().v4(),
              'import_id': importId,
              'row_number': r + 1,
              'day_label': dayLabel,
              'event_date': now.toIso8601String().split('T').first,
              'time_raw': timeStr,
              'start_at': now.toIso8601String(),
              'end_at': now.add(const Duration(hours: 1)).toIso8601String(),
              'title': title,
              'description': 'Imported from Master File ($table)',
              'venue': venue,
              'audience': audience,
              'status': 'pending_review',
              'created_at': now.toIso8601String(),
            });
          }
        } else if (sheetNameUpper.contains('ANUGERAH') || sheetNameUpper.contains('AWARD')) {
          // Parse Award Rows
          for (int r = 1; r < sheet.rows.length; r++) {
            final row = sheet.rows[r];
            if (row.isEmpty) continue;

            final cat = row.isNotEmpty && row[0] != null ? row[0]!.value.toString().trim() : 'Best Project';
            final team = row.length > 1 && row[1] != null ? row[1]!.value.toString().trim() : '';
            final sv = row.length > 2 && row[2] != null ? row[2]!.value.toString().trim() : '';
            final prog = row.length > 3 && row[3] != null ? row[3]!.value.toString().trim() : 'CS230';

            if (team.isEmpty) continue;

            awardCandidates.add({
              'id': const Uuid().v4(),
              'import_id': importId,
              'row_number': r + 1,
              'award_category': cat,
              'team_display_name': team,
              'supervisor_display_name': sv,
              'programme_code': prog,
              'status': 'pending_review',
              'created_at': now.toIso8601String(),
            });
          }
        } else if (sheetNameUpper.contains('MARKAH') || sheetNameUpper.contains('EVALUATION') || sheetNameUpper.contains('STUDENT_PRIVATE')) {
          // Detect and skip private/restricted sheets
          privacySkips.add({
            'id': const Uuid().v4(),
            'import_id': importId,
            'sheet_name': table,
            'row_number': 0,
            'column_name': 'Entire Sheet',
            'reason': 'Confidential evaluation / marks sheet skipped from public import pipeline.',
            'created_at': now.toIso8601String(),
          });
        }
      }

      // Check for empty extraction
      if (scheduleCandidates.isEmpty && awardCandidates.isEmpty) {
        validationIssues.add({
          'id': const Uuid().v4(),
          'import_id': importId,
          'sheet_name': 'Master File',
          'row_number': 0,
          'issue_type': 'warning',
          'message': 'No schedule or award rows matched expected sheets (TENTATIF, PEMENANG ANUGERAH).',
          'created_at': now.toIso8601String(),
        });
      }

      final importRecord = ImportRecord(
        id: importId,
        eventId: 'fskm-fyp-2026',
        sourceFilePath: file.name,
        sourceFileName: file.name,
        sourceFileHash: importId,
        uploadedBy: user?.email ?? 'admin',
        uploadedAt: now,
        parserVersion: '2.0.0-supabase',
        status: 'staged',
        summary: {
          'schedule': scheduleCandidates.length,
          'winners': awardCandidates.length,
        },
        warningCounts: {
          'skips': privacySkips.length,
          'issues': validationIssues.length,
        },
      );

      final db = ref.read(supabaseDbServiceProvider);
      await db.setImport(importId, importRecord.toJson());
      await db.insertScheduleCandidates(scheduleCandidates);
      await db.insertAwardCandidates(awardCandidates);
      await db.insertValidationIssues(validationIssues);
      await db.insertPrivacySkips(privacySkips);

      ref.read(importsProvider.notifier).addImport(importRecord);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Excel parsed and staged successfully!'), backgroundColor: Colors.green),
        );
        context.go('/admin/imports/$importId');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error parsing Excel: $e'), backgroundColor: DesignSystem.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _statusMessage = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final imports = ref.watch(importsProvider);
    // ignore: unused_local_variable
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignSystem.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: DesignSystem.spaceLg,
              runSpacing: DesignSystem.spaceMd,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Import Master File', style: DesignSystem.h2Mobile.copyWith(color: DesignSystem.primary)),
                    const SizedBox(height: 4),
                    Text('In-browser XLSX parsing with candidate staging and zero-storage cost.', style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _pickAndParseExcel,
                  icon: _isProcessing
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.upload_file),
                  label: Text(_isProcessing ? 'Processing...' : 'Upload & Parse .xlsx'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignSystem.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusLg),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignSystem.spaceXl),

            if (_isProcessing && _statusMessage != null) ...[
              Card(
                color: DesignSystem.secondaryContainer.withOpacity(0.3),
                child: Padding(
                  padding: const EdgeInsets.all(DesignSystem.spaceMd),
                  child: Row(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(width: 16),
                      Expanded(child: Text(_statusMessage!, style: DesignSystem.bodyMd)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: DesignSystem.spaceLg),
            ],

            Card(
              child: Padding(
                padding: const EdgeInsets.all(DesignSystem.spaceLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Staged Imports History', style: DesignSystem.h3Mobile.copyWith(color: DesignSystem.primary)),
                    const Divider(height: 32),

                    if (imports.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text('No previous imports found. Upload a Master File (.xlsx) to begin.', style: DesignSystem.bodyMd),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: imports.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final imp = imports[index];
                          return ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: DesignSystem.primaryContainer,
                                borderRadius: DesignSystem.radiusLg,
                              ),
                              child: const Icon(Icons.table_view, color: DesignSystem.primary),
                            ),
                            title: Text(imp.sourceFileName, style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.bold)),
                            subtitle: Text(
                              '${imp.summary["schedule"] ?? 0} Schedule candidates • ${imp.summary["winners"] ?? 0} Award candidates • Status: ${imp.status}',
                              style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
                            ),
                            trailing: ElevatedButton(
                              onPressed: () => context.go('/admin/imports/${imp.id}'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: DesignSystem.primary,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Review & Publish'),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
