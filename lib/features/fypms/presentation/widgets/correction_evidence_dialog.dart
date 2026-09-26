import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/fypms/fyp_correction_item.dart';
import '../../../../core/domain/models/fypms/fyp_record.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../../../../core/state/state_providers.dart';
import '../../../../core/supabase/fypms_rpc_service.dart';

const kCorrectionEvidenceBucket = 'fyp-correction-evidence';

/// F12: the student describes the amendment and/or uploads the corrected
/// file; the supervisor or examiner then confirms it.
class CorrectionEvidenceDialog extends ConsumerStatefulWidget {
  const CorrectionEvidenceDialog({super.key, required this.record, required this.item});

  final FypRecord record;
  final FypCorrectionItem item;

  @override
  ConsumerState<CorrectionEvidenceDialog> createState() => _CorrectionEvidenceDialogState();
}

class _CorrectionEvidenceDialogState extends ConsumerState<CorrectionEvidenceDialog> {
  final _note = TextEditingController();
  PlatformFile? _file;
  bool _busy = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final result = await FilePicker.pickFiles(type: FileType.any, withData: true);
    if (result != null && result.files.isNotEmpty) setState(() => _file = result.files.first);
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    try {
      String? path;
      final file = _file;
      if (file != null) {
        final bytes = file.bytes;
        if (bytes == null) throw Exception('Could not read ${file.name}.');
        final semesters = await ref.read(fypmsSemestersProvider.future);
        final semesterCode = semesters
                .where((s) => s.id == widget.record.academicSemesterId)
                .map((s) => s.code)
                .firstOrNull ??
            'unknown';
        path = await ref.read(supabaseStorageServiceProvider).uploadFile(
              bucket: kCorrectionEvidenceBucket,
              semesterCode: semesterCode,
              fypRecordId: widget.record.id,
              resourceType: 'correction_${widget.item.itemCode ?? widget.item.id}',
              version: DateTime.now().millisecondsSinceEpoch,
              fileName: file.name,
              bytes: bytes,
            );
      }
      await ref.read(supabaseRpcServiceProvider).submitCorrectionEvidence(
            correctionItemId: widget.item.id,
            note: _note.text.trim().isEmpty ? null : _note.text.trim(),
            fileUrl: path,
          );
      ref.invalidate(fypCorrectionItemsProvider(widget.record.id));
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(const SnackBar(content: Text('Evidence submitted. Awaiting staff review.')));
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit evidence: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ready = !_busy && (_note.text.trim().isNotEmpty || _file != null);
    return AlertDialog(
      backgroundColor: DesignSystem.surfaceContainerLowest,
      title: Text('Submit Correction Evidence', style: DesignSystem.h2),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.item.description, style: DesignSystem.bodySm.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: DesignSystem.spaceSm),
            Text(
              'Describe what you amended and attach the corrected file if you have one. '
              'Your supervisor or examiner reviews and confirms it (F12).',
              style: DesignSystem.bodySm,
            ),
            const SizedBox(height: DesignSystem.spaceMd),
            TextField(
              key: const Key('evidence-note'),
              controller: _note,
              maxLength: 2000,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(labelText: 'What was amended'),
              maxLines: 3,
            ),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _busy ? null : _pick,
                icon: Icon(_file == null ? Icons.attach_file : Icons.check_circle, size: 18),
                label: Text(_file?.name ?? 'Attach corrected file (optional)', overflow: TextOverflow.ellipsis),
              ),
            ),
            if (_busy)
              const Padding(
                padding: EdgeInsets.only(top: DesignSystem.spaceMd),
                child: LinearProgressIndicator(),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _busy ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: ready ? _submit : null, child: const Text('Submit')),
      ],
    );
  }
}
