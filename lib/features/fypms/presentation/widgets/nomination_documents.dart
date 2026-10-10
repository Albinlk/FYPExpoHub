import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/fypms_supervisor_change.dart';
import '../../../../core/layout/responsive.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../../../../core/utils/fypms_format.dart';
import '../../../../core/widgets/admin_actions.dart';
import '../../../../core/widgets/async_state.dart';
import '../../../../core/widgets/busy_button.dart';
import 'fypms_file_link.dart';

/// Largest CV the bucket accepts (5 MB).
const kNominationCvMaxBytes = 5 * 1024 * 1024;

/// The CV and declaration on a nomination (FSKM handbook App. N): a link to
/// the CV and the declaration date, or what is still missing.
class NominationDocumentsLine extends StatelessWidget {
  const NominationDocumentsLine({super.key, required this.nomination});

  final PendingNomination nomination;

  @override
  Widget build(BuildContext context) {
    final cv = nomination.cvPath;
    final declared = nomination.notRelatedDeclaredAt;
    if (!nomination.hasDocuments) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: DesignSystem.spaceXs),
        child: Text(
          'Waiting for the CV and declaration from the nominating lecturer.',
          style: DesignSystem.bodySm.copyWith(color: DesignSystem.error),
        ),
      );
    }
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: DesignSystem.spaceSm,
      children: [
        FypmsFileLink(label: 'View CV', bucket: kNominationCvBucket, path: cv!),
        Text(
          'Declared not a relative or close friend on ${formatFypDate(declared!)}',
          style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
        ),
      ],
    );
  }
}

/// The nominator attaches the nominee's CV (PDF) and declares the nominee is
/// not a relative or close friend of the student or the other supervisors.
class AttachNominationCvDialog extends ConsumerStatefulWidget {
  const AttachNominationCvDialog({super.key, required this.nomination});

  final PendingNomination nomination;

  @override
  ConsumerState<AttachNominationCvDialog> createState() => _AttachNominationCvDialogState();
}

class _AttachNominationCvDialogState extends ConsumerState<AttachNominationCvDialog> {
  PlatformFile? _file;
  bool _notRelated = false;
  bool _busy = false;
  String? _fileError;

  Future<void> _pick() async {
    final result = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['pdf'], withData: true);
    if (result == null || result.files.isEmpty) return;
    final f = result.files.first;
    setState(() {
      if (f.size > kNominationCvMaxBytes) {
        _file = null;
        _fileError = 'The CV must be a PDF of 5 MB or less.';
      } else {
        _file = f;
        _fileError = null;
      }
    });
  }

  Future<void> _submit() async {
    final bytes = _file?.bytes;
    if (bytes == null) return;
    setState(() => _busy = true);
    try {
      await ref.read(submitNominationDocumentsProvider)(
        assignmentId: widget.nomination.assignmentId,
        cvBytes: bytes,
        notRelated: _notRelated,
      );
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context, true);
      messenger.showSnackBar(const SnackBar(content: Text('CV and declaration sent to the PU.')));
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: ${friendlyError(e)}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.nomination;
    final ready = _file != null && _notRelated && !_busy;
    return AlertDialog(
      title: const Text('Attach CV and Declaration'),
      content: SizedBox(
        width: dialogWidth(context, 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${n.roleLabel}: ${n.lecturerName ?? '—'}', style: DesignSystem.bodyLg.copyWith(fontWeight: FontWeight.bold)),
            Text('${n.projectTitle ?? 'Untitled'} · ${n.studentName ?? ''}', style: DesignSystem.bodySm),
            const SizedBox(height: DesignSystem.spaceMd),
            Text(
              'The CV should list about two years of supervision. For staff with no supervision yet, '
              'it should show their expertise in the project area (FSKM handbook, Appendix N).',
              style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
            ),
            const SizedBox(height: DesignSystem.spaceSm),
            OutlinedButton.icon(
              onPressed: _busy ? null : _pick,
              icon: const Icon(Icons.upload_file),
              label: Text(_file == null ? 'Choose CV (PDF)' : _file!.name, overflow: TextOverflow.ellipsis),
            ),
            if (_fileError != null)
              Padding(
                padding: const EdgeInsets.only(top: DesignSystem.spaceXs),
                child: Text(_fileError!, style: DesignSystem.bodySm.copyWith(color: DesignSystem.error)),
              ),
            const SizedBox(height: DesignSystem.spaceSm),
            CheckboxListTile(
              value: _notRelated,
              onChanged: _busy ? null : (v) => setState(() => _notRelated = v ?? false),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text(
                'I declare the nominee is not a relative or close friend of the student or of the other supervisors.',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _busy ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        BusyButton(label: 'Send to PU', busyLabel: 'Sending…', busy: _busy, onPressed: ready ? _submit : null),
      ],
    );
  }
}

/// CSP lecturers and the coordinator: nominations they made that wait for
/// the PU, with the CV and declaration the PU needs before approving.
class NominatorNominationsPage extends ConsumerWidget {
  const NominatorNominationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nominations = ref.watch(myPendingNominationsProvider);
    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        backgroundColor: DesignSystem.surfaceContainerLowest,
        foregroundColor: DesignSystem.primary,
        surfaceTintColor: Colors.transparent,
        shape: const Border(bottom: BorderSide(color: DesignSystem.outlineVariant)),
        title: Text(
          'Nomination CVs',
          style: DesignSystem.h3.copyWith(color: DesignSystem.primary, fontWeight: FontWeight.bold),
        ),
      ),
      body: nominations.when(
        loading: () => const AsyncLoadingView(),
        error: (e, _) => AsyncErrorView(
          error: e,
          onRetry: () => ref.invalidate(myPendingNominationsProvider),
          what: 'your nominations',
        ),
        data: (list) => list.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(DesignSystem.gutter),
                  child: Text('No nominations are waiting for the PU.', textAlign: TextAlign.center),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(DesignSystem.gutter),
                children: [
                  Text(
                    'The PU approves a supervisor or examiner nomination only after you attach the '
                    'nominee\'s CV and the declaration.',
                    style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
                  ),
                  const SizedBox(height: DesignSystem.spaceMd),
                  for (final n in list)
                    Card(
                      margin: const EdgeInsets.only(bottom: DesignSystem.spaceSm),
                      child: Padding(
                        padding: const EdgeInsets.all(DesignSystem.spaceMd),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${n.roleLabel}: ${n.lecturerName ?? '—'}',
                              style: DesignSystem.bodyLg.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${n.projectTitle ?? 'Untitled'} · ${n.studentName ?? ''}'
                              '${n.matricId == null ? '' : ' (${n.matricId})'}',
                              style: DesignSystem.bodySm,
                            ),
                            NominationDocumentsLine(nomination: n),
                            Align(
                              alignment: Alignment.centerRight,
                              child: FilledButton.tonal(
                                onPressed: () => showDialog<bool>(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => AttachNominationCvDialog(nomination: n),
                                ),
                                child: Text(n.hasDocuments ? 'Replace CV' : 'Attach CV'),
                              ),
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
