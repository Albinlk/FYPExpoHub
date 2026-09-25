import 'package:crypto/crypto.dart' show sha256;
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/import_models.dart';
import '../../../../core/supabase/row_mappers.dart';
import '../../../../core/supabase/supabase_client_provider.dart';
import '../../../../core/supabase/supabase_database_service.dart' show kEventSlug;
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
      if (user == null) {
        throw NotPersistableException('Sign in again before importing a file.');
      }
      final importId = const Uuid().v4();
      final event = ref.read(eventProvider);

      // Let the "Parsing…" status paint before the (synchronous, and on the
      // web single-threaded) decode blocks the frame.
      await Future<void>.delayed(const Duration(milliseconds: 16));
      final excel = Excel.decodeBytes(bytes);

      final scheduleCandidates = <Map<String, dynamic>>[];
      final awardCandidates = <Map<String, dynamic>>[];
      final validationIssues = <Map<String, dynamic>>[];
      final privacySkips = <Map<String, dynamic>>[];

      String cell(List<Data?> row, int i, [String fallback = '']) =>
          row.length > i && row[i] != null ? row[i]!.value.toString().trim() : fallback;

      // Row shapes below match the staging tables' real columns
      // (20260814000001_initial_schema.sql); the previous payload used
      // several column names that don't exist, so staging never succeeded.
      for (final table in excel.tables.keys) {
        final sheet = excel.tables[table]!;
        final sheetNameUpper = table.toUpperCase();

        if (sheetNameUpper.contains('TENTATIF') || sheetNameUpper.contains('SCHEDULE')) {
          for (int r = 1; r < sheet.rows.length; r++) {
            final row = sheet.rows[r];
            if (row.isEmpty) continue;

            final dayLabelRaw = cell(row, 0, 'Day 1');
            final timeStr = cell(row, 1);
            final title = cell(row, 2);
            final venue = cell(row, 3, 'FSKM Complex');
            final audience = cell(row, 4, 'General');
            if (title.isEmpty) continue;

            final date = importDayDate(dayLabelRaw, event.startAt);
            final times = importTimeRange(timeStr);
            if (date == null || times == null) {
              validationIssues.add({
                'id': const Uuid().v4(),
                'import_id': importId,
                'worksheet_name': table,
                'row_number': r + 1,
                'issue_type': date == null ? 'date_conflict' : 'invalid_time',
                'severity': 'warning',
                'message': date == null
                    ? 'Couldn\'t work out which day "$dayLabelRaw" is. Set it before publishing.'
                    : 'Couldn\'t read the time "$timeStr". Set it before publishing.',
              });
            }

            scheduleCandidates.add({
              'id': const Uuid().v4(),
              'import_id': importId,
              'row_number': r + 1,
              'day_label': dayLabelRaw,
              'event_date': date == null ? null : scheduleDateString(date),
              'start_at': date == null || times == null ? null : mytTimestamp(date, times.$1),
              'end_at': date == null || times == null ? null : mytTimestamp(date, times.$2),
              'raw_start_str': timeStr,
              'title': title,
              'description': 'Imported from Master File ($table)',
              'venue': venue,
              'audience': audience,
              'access_type': 'public',
              'comparison_status': 'new',
            });
          }
        } else if (sheetNameUpper.contains('ANUGERAH') || sheetNameUpper.contains('AWARD')) {
          for (int r = 1; r < sheet.rows.length; r++) {
            final row = sheet.rows[r];
            if (row.isEmpty) continue;

            final cat = cell(row, 0, 'Best Project');
            final team = cell(row, 1);
            final sv = cell(row, 2);
            final prog = cell(row, 3, 'CS230');
            if (team.isEmpty) continue;

            awardCandidates.add({
              'id': const Uuid().v4(),
              'import_id': importId,
              'row_number': r + 1,
              'award_category': cat,
              // The award sheet has no project-title column; the team name
              // is the best available label until an admin edits it.
              'project_title': cell(row, 4, team),
              'team_display_name': team,
              'supervisor_display_name': sv,
              'programme_code': prog,
              'comparison_status': 'new',
            });
          }
        } else if (sheetNameUpper.contains('MARKAH') || sheetNameUpper.contains('EVALUATION') || sheetNameUpper.contains('STUDENT_PRIVATE')) {
          privacySkips.add({
            'id': const Uuid().v4(),
            'import_id': importId,
            'sheet_name': table,
            'row_number': 0,
            'field_name': 'Entire Sheet',
            'reason': 'Confidential evaluation / marks sheet skipped from public import pipeline.',
            'category': 'confidential_sheet',
          });
        }
      }

      if (scheduleCandidates.isEmpty && awardCandidates.isEmpty) {
        validationIssues.add({
          'id': const Uuid().v4(),
          'import_id': importId,
          'worksheet_name': 'Master File',
          'row_number': 0,
          'issue_type': 'unrecognized_worksheet',
          'severity': 'warning',
          'message': 'No schedule or award rows matched expected sheets (TENTATIF, PEMENANG ANUGERAH).',
        });
      }

      final importRecord = ImportRecord(
        id: importId,
        eventId: kEventSlug,
        sourceFilePath: file.name,
        sourceFileName: file.name,
        sourceFileHash: sha256.convert(bytes).toString(),
        uploadedBy: user.id,
        uploadedAt: DateTime.now(),
        parserVersion: '2.1.0-supabase',
        status: 'pending_review',
        summary: {
          'schedule': scheduleCandidates.length,
          'winners': awardCandidates.length,
        },
        warningCounts: {
          'skips': privacySkips.length,
          'issues': validationIssues.length,
        },
      );

      setState(() => _statusMessage = 'Saving staged rows...');
      final db = ref.read(supabaseDbServiceProvider);
      final eventId = await db.resolveEventId(kEventSlug);
      // One transaction: either the import and every staged row land, or
      // nothing does (previously five separate writes, no rollback).
      await db.stageImport(
        importRow: importToRow(
          importRecord,
          eventId: eventId,
          uploadedBy: user.id,
          fileSizeBytes: bytes.length,
        ),
        scheduleCandidates: scheduleCandidates,
        awardCandidates: awardCandidates,
        validationIssues: validationIssues,
        privacySkips: privacySkips,
      );

      ref.read(importsProvider.notifier).recordStagedImport(importRecord);

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
                color: DesignSystem.secondaryContainer.withValues(alpha: 0.3),
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
