import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/fypms_reports.dart';
import '../../../../core/domain/models/fypms/fyp_record.dart';
import '../../../../core/domain/models/fypms/fyp_report_submission.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../../../../core/utils/fypms_format.dart';
import '../../../../core/state/state_providers.dart';
import '../../../../core/supabase/fypms_rpc_service.dart';
import '../widgets/fypms_file_link.dart';
import '../widgets/fypms_loading_widget.dart';
import '../widgets/student_record_workspace.dart';

/// F6(a) proposal / F6(b) final report submissions: the report, its
/// similarity index (max 30 %) and the original plagiarism report, endorsed by
/// the supervisor.
class StudentReportsPage extends ConsumerWidget {
  const StudentReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StudentRecordWorkspace(
      title: 'Reports & Deliverables',
      builder: (context, ref, record) {
        final reports = ref.watch(fypReportSubmissionsProvider(record.id));
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(DesignSystem.gutter),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(child: Text('Report Versions', style: DesignSystem.h2)),
                  FilledButton.icon(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (_) => ReportSubmissionDialog(record: record),
                    ),
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Submit Report'),
                    style: FilledButton.styleFrom(
                      backgroundColor: DesignSystem.secondary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: reports.when(
                loading: () => const FypmsLoadingWidget(),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (items) {
                  if (items.isEmpty) {
                    return Center(
                      child: Text(
                        'No report submissions yet.\nUpload your proposal or final report with its plagiarism report.',
                        style: DesignSystem.bodyMd,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: DesignSystem.gutter),
                    itemCount: items.length,
                    itemBuilder: (context, index) => ReportSubmissionCard(report: items[index]),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

/// One F6 submission with its similarity, endorsement status and file links.
class ReportSubmissionCard extends StatelessWidget {
  const ReportSubmissionCard({super.key, required this.report, this.actions});

  final FypReportSubmission report;

  /// Extra controls under the card (e.g. the supervisor's Endorse / Return).
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    final bucket = reportBucket(report.reportType);
    final similarity = report.similarityIndex;
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: DesignSystem.spaceMd),
      shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusXl),
      color: DesignSystem.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.article, size: 32, color: DesignSystem.primary),
                const SizedBox(width: DesignSystem.spaceSm),
                Expanded(
                  child: Text(
                    '${report.reportType == 'final' ? 'Final report (F6b)' : 'Proposal (F6a)'} · v${report.version}',
                    style: DesignSystem.bodyLg.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignSystem.spaceXs),
            Text(reportStatusLabel(report.status), style: DesignSystem.bodySm.copyWith(fontWeight: FontWeight.w600)),
            if (similarity != null)
              Text(
                'Similarity index: ${similarity.toStringAsFixed(similarity == similarity.roundToDouble() ? 0 : 1)} %',
                style: DesignSystem.bodySm.copyWith(
                  color: similarity > kMaxSimilarityIndex ? DesignSystem.error : DesignSystem.onSurfaceVariant,
                ),
              ),
            if (report.pageCount != null)
              Text(
                '${report.pageCount} pages · ${report.referenceCount ?? 0} references '
                '(${report.academicReferenceCount ?? 0} academic)'
                '${report.involvesHumanSubjects ? ' · human subjects' : ''}',
                key: const Key('report-counts'),
                style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
              ),
            if (report.endorsedAt != null)
              Text('Endorsed ${formatFypDateTime(report.endorsedAt!)}', style: DesignSystem.bodySm),
            if (report.reviewComment?.isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.only(top: DesignSystem.spaceXs),
                child: Text(
                  'Supervisor: ${report.reviewComment}',
                  style: DesignSystem.bodySm.copyWith(color: DesignSystem.secondary),
                ),
              ),
            Text(
              'Submitted ${formatFypDateTime(report.submittedAt)}',
              style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
            ),
            Wrap(
              spacing: DesignSystem.spaceSm,
              children: [
                FypmsFileLink(label: 'Report', bucket: bucket, path: report.fileUrl),
                if (report.plagiarismReportUrl != null)
                  FypmsFileLink(label: 'Plagiarism report', bucket: bucket, path: report.plagiarismReportUrl!),
                if (report.ethicsFormUrl != null)
                  FypmsFileLink(label: 'REC ethics form', bucket: bucket, path: report.ethicsFormUrl!),
              ],
            ),
            ?actions,
          ],
        ),
      ),
    );
  }
}

/// F6 form: report type, report file (PDF / DOC / DOCX), similarity index
/// (0–30 %), the original plagiarism report (PDF), page / reference counts
/// (textbook minimums) and, for a proposal with human subjects, the REC form.
class ReportSubmissionDialog extends ConsumerStatefulWidget {
  const ReportSubmissionDialog({super.key, required this.record});

  final FypRecord record;

  @override
  ConsumerState<ReportSubmissionDialog> createState() => _ReportSubmissionDialogState();
}

class _ReportSubmissionDialogState extends ConsumerState<ReportSubmissionDialog> {
  final _similarity = TextEditingController();
  final _pages = TextEditingController();
  final _references = TextEditingController();
  final _academic = TextEditingController();
  String _reportType = 'proposal';
  PlatformFile? _report;
  PlatformFile? _plagiarism;
  PlatformFile? _ethics;
  bool _humanSubjects = false;
  bool _uploading = false;

  @override
  void dispose() {
    _similarity.dispose();
    _pages.dispose();
    _references.dispose();
    _academic.dispose();
    super.dispose();
  }

  Future<PlatformFile?> _pick(List<String> extensions) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: extensions,
      withData: true,
    );
    return (result == null || result.files.isEmpty) ? null : result.files.first;
  }

  static String? _contentType(String name) {
    final ext = name.split('.').last.toLowerCase();
    return switch (ext) {
      'pdf' => 'application/pdf',
      'doc' => 'application/msword',
      'docx' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      _ => null,
    };
  }

  Future<void> _submit() async {
    setState(() => _uploading = true);
    try {
      final record = widget.record;
      final rpc = ref.read(supabaseRpcServiceProvider);
      final storage = ref.read(supabaseStorageServiceProvider);
      final semesters = await ref.read(fypmsSemestersProvider.future);
      final semesterCode =
          semesters.where((s) => s.id == record.academicSemesterId).map((s) => s.code).firstOrNull ?? 'unknown';
      final existing = await ref.read(fypReportSubmissionsProvider(record.id).future);
      final version = existing.where((r) => r.reportType == _reportType).length + 1;
      final bucket = reportBucket(_reportType);

      Future<String> upload(PlatformFile file, String resourceType) {
        final bytes = file.bytes;
        if (bytes == null) throw Exception('Could not read ${file.name}.');
        return storage.uploadFile(
          bucket: bucket,
          semesterCode: semesterCode,
          fypRecordId: record.id,
          resourceType: resourceType,
          version: version,
          fileName: file.name,
          bytes: bytes,
          contentType: _contentType(file.name),
        );
      }

      final reportPath = await upload(_report!, _reportType);
      final plagiarismPath = await upload(_plagiarism!, '${_reportType}_plagiarism');
      final ethicsPath = _needsEthics ? await upload(_ethics!, '${_reportType}_ethics') : null;

      await rpc.submitReportVersion(
        fypRecordId: record.id,
        reportType: _reportType,
        fileUrl: reportPath,
        similarityIndex: parseSimilarity(_similarity.text),
        plagiarismReportUrl: plagiarismPath,
        pageCount: int.parse(_pages.text.trim()),
        referenceCount: int.parse(_references.text.trim()),
        academicReferenceCount: int.parse(_academic.text.trim()),
        involvesHumanSubjects: _humanSubjects,
        ethicsFormUrl: ethicsPath,
      );

      ref.invalidate(fypReportSubmissionsProvider(record.id));
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(const SnackBar(content: Text('Report submitted for supervisor endorsement.')));
    } catch (e) {
      if (!mounted) return;
      setState(() => _uploading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit: $e')));
    }
  }

  /// REC forms go with a proposal involving human subjects (textbook).
  bool get _needsEthics => _reportType == 'proposal' && _humanSubjects;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    final similarityError = _similarity.text.isEmpty ? null : similarityProblem(_similarity.text);
    final anyCount = _pages.text.isNotEmpty || _references.text.isNotEmpty || _academic.text.isNotEmpty;
    final countsProblem = reportCountsProblem(_reportType, _pages.text, _references.text, _academic.text);
    final (minPages, minRefs) = reportMinimums(_reportType);
    final ready = _report != null &&
        _plagiarism != null &&
        similarityProblem(_similarity.text) == null &&
        countsProblem == null &&
        (!_needsEthics || _ethics != null) &&
        !_uploading;

    return AlertDialog(
      title: Text(
        'Submit Report (F6)',
        style: (isDesktop ? DesignSystem.h3 : DesignSystem.bodyLg).copyWith(color: DesignSystem.primary),
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: isDesktop ? 500 : MediaQuery.of(context).size.width * 0.85,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _reportType,
                decoration: const InputDecoration(labelText: 'Report type'),
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'proposal', child: Text('Proposal (F6a)')),
                  DropdownMenuItem(value: 'final', child: Text('Final report (F6b)')),
                ],
                onChanged: _uploading ? null : (v) => setState(() => _reportType = v ?? _reportType),
              ),
              const SizedBox(height: DesignSystem.spaceMd),
              _FileRow(
                label: 'Report (PDF / DOC / DOCX)',
                file: _report,
                onPick: _uploading
                    ? null
                    : () async {
                        final f = await _pick(const ['pdf', 'doc', 'docx']);
                        if (f != null) setState(() => _report = f);
                      },
              ),
              const SizedBox(height: DesignSystem.spaceSm),
              TextField(
                key: const Key('similarity-index'),
                controller: _similarity,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Similarity index (%)',
                  helperText: 'From the anti-plagiarism report. Maximum 30 %.',
                  errorText: similarityError,
                ),
              ),
              const SizedBox(height: DesignSystem.spaceSm),
              _FileRow(
                label: 'Original plagiarism report (PDF)',
                file: _plagiarism,
                onPick: _uploading
                    ? null
                    : () async {
                        final f = await _pick(const ['pdf']);
                        if (f != null) setState(() => _plagiarism = f);
                      },
              ),
              const SizedBox(height: DesignSystem.spaceSm),
              Row(
                children: [
                  for (final (key, label, c) in [
                    ('report-pages', 'Pages', _pages),
                    ('report-refs', 'References', _references),
                    ('report-academic', 'Academic', _academic),
                  ]) ...[
                    Expanded(
                      child: TextField(
                        key: Key(key),
                        controller: c,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(labelText: label),
                      ),
                    ),
                    if (key != 'report-academic') const SizedBox(width: DesignSystem.spaceSm),
                  ],
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  anyCount && countsProblem != null
                      ? countsProblem
                      : 'At least $minPages pages and $minRefs references, half of them academic.',
                  key: const Key('report-counts-help'),
                  style: DesignSystem.bodySm.copyWith(
                    color: anyCount && countsProblem != null ? DesignSystem.error : DesignSystem.onSurfaceVariant,
                  ),
                ),
              ),
              if (_reportType == 'proposal')
                SwitchListTile(
                  key: const Key('human-subjects'),
                  contentPadding: EdgeInsets.zero,
                  value: _humanSubjects,
                  onChanged: _uploading ? null : (v) => setState(() => _humanSubjects = v),
                  title: const Text('The project involves human subjects'),
                  subtitle: const Text('Surveys, interviews, user testing… — attach the REC ethics form.'),
                ),
              if (_needsEthics)
                _FileRow(
                  label: 'REC ethics form (PDF)',
                  file: _ethics,
                  onPick: _uploading
                      ? null
                      : () async {
                          final f = await _pick(const ['pdf']);
                          if (f != null) setState(() => _ethics = f);
                        },
                ),
              if (_uploading)
                const Padding(
                  padding: EdgeInsets.only(top: DesignSystem.spaceMd),
                  child: LinearProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _uploading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: ready ? _submit : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: DesignSystem.secondary,
            foregroundColor: Colors.white,
          ),
          child: Text(_uploading ? 'Uploading...' : 'Submit'),
        ),
      ],
    );
  }
}

class _FileRow extends StatelessWidget {
  const _FileRow({required this.label, required this.file, required this.onPick});

  final String label;
  final PlatformFile? file;
  final VoidCallback? onPick;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPick,
        icon: Icon(file == null ? Icons.attach_file : Icons.check_circle, size: 18),
        label: Text(file?.name ?? label, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}
