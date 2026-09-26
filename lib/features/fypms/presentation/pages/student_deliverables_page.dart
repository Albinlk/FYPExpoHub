import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/fypms_deliverables.dart';
import '../../../../core/domain/models/fypms/fyp_deliverable.dart';
import '../../../../core/domain/models/fypms/fyp_record.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../../../../core/state/state_providers.dart';
import '../../../../core/supabase/fypms_rpc_service.dart';
import '../../../../core/utils/external_link.dart';
import '../widgets/fypms_file_link.dart';
import '../widgets/fypms_loading_widget.dart';
import '../widgets/student_record_workspace.dart';

const _bucket = 'fyp-deliverables';

/// CSP650 deliverables handed to the Project lecturer (FYP Text Book): the
/// report as PDF and Word, slides, poster, and the "if relevant" project
/// files, with an exhibition-readiness count of the required ones.
class StudentDeliverablesPage extends ConsumerWidget {
  const StudentDeliverablesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StudentRecordWorkspace(
      title: 'Deliverables',
      builder: (context, ref, record) {
        final deliverables = ref.watch(fypDeliverablesProvider(record.id));
        return deliverables.when(
          loading: () => const FypmsLoadingWidget(),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (items) => _Body(record: record, items: items),
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.record, required this.items});

  final FypRecord record;
  final List<FypDeliverable> items;

  @override
  Widget build(BuildContext context) {
    final byType = {for (final d in items) d.deliverableType ?? '': d};
    final readiness = deliverableReadiness(items);
    final ready = readiness.done == readiness.total;
    final others = otherDeliverables(items);

    return ListView(
      padding: const EdgeInsets.all(DesignSystem.gutter),
      children: [
        Card(
          color: DesignSystem.surfaceContainerLowest,
          child: Padding(
            padding: const EdgeInsets.all(DesignSystem.spaceMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Exhibition Readiness', style: DesignSystem.h3Mobile.copyWith(color: DesignSystem.primary)),
                const SizedBox(height: DesignSystem.spaceSm),
                LinearProgressIndicator(
                  value: readiness.total == 0 ? 0 : readiness.done / readiness.total,
                  minHeight: 8,
                  borderRadius: DesignSystem.radiusFull,
                ),
                const SizedBox(height: DesignSystem.spaceSm),
                Text(
                  '${readiness.done}/${readiness.total} required deliverables submitted',
                  style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  ready
                      ? 'All required items are in. Add the "if relevant" project files that apply.'
                      : 'The report (PDF and Word), slides and poster are required.',
                  style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: DesignSystem.spaceLg),
        Text('Deliverables Checklist', style: DesignSystem.h3Mobile.copyWith(color: DesignSystem.primary)),
        const SizedBox(height: DesignSystem.spaceSm),
        for (final spec in fypmsDeliverableChecklist)
          _DeliverableRow(record: record, spec: spec, current: byType[spec.type]),
        if (others.isNotEmpty) ...[
          const SizedBox(height: DesignSystem.spaceLg),
          Text('Other submitted items', style: DesignSystem.bodyLg.copyWith(fontWeight: FontWeight.bold)),
          for (final d in others)
            ListTile(
              dense: true,
              leading: const Icon(Icons.inventory_2_outlined),
              title: Text(d.title),
              subtitle: Text('${d.deliverableType ?? 'item'} · v${d.version}'),
              trailing: d.fileUrl == null ? null : _OpenButton(url: d.fileUrl!),
            ),
        ],
      ],
    );
  }
}

class _DeliverableRow extends StatelessWidget {
  const _DeliverableRow({required this.record, required this.spec, required this.current});

  final FypRecord record;
  final DeliverableSpec spec;
  final FypDeliverable? current;

  @override
  Widget build(BuildContext context) {
    final done = current?.fileUrl?.isNotEmpty ?? false;
    return Card(
      margin: const EdgeInsets.only(bottom: DesignSystem.spaceSm),
      color: DesignSystem.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: DesignSystem.spaceMd, vertical: DesignSystem.spaceSm),
        child: Row(
          children: [
            Icon(
              done ? Icons.check_circle : Icons.radio_button_unchecked,
              color: done ? DesignSystem.tertiary : DesignSystem.onSurfaceVariant,
            ),
            const SizedBox(width: DesignSystem.spaceSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(spec.title, style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.w600)),
                  Text(
                    [
                      spec.required ? 'Required' : 'If relevant',
                      ?spec.hint,
                      if (done) 'Submitted (v${current!.version})',
                    ].join(' · '),
                    style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            if (done) _OpenButton(url: current!.fileUrl!),
            TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => DeliverableUploadDialog(record: record, spec: spec, current: current),
              ),
              child: Text(done ? 'Replace' : 'Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Opens a stored file (signed URL) or an https link.
class _OpenButton extends StatelessWidget {
  const _OpenButton({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    if (!url.startsWith('http')) return FypmsFileLink(label: 'Open', bucket: _bucket, path: url);
    final uri = safeExternalUri(url);
    return TextButton.icon(
      onPressed: uri == null ? null : () => launchUrl(uri, webOnlyWindowName: '_blank'),
      icon: const Icon(Icons.open_in_new, size: 16),
      label: const Text('Open'),
      style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
    );
  }
}

/// Upload one deliverable (or, for "if relevant" items, give an https link).
class DeliverableUploadDialog extends ConsumerStatefulWidget {
  const DeliverableUploadDialog({super.key, required this.record, required this.spec, this.current});

  final FypRecord record;
  final DeliverableSpec spec;
  final FypDeliverable? current;

  @override
  ConsumerState<DeliverableUploadDialog> createState() => _DeliverableUploadDialogState();
}

class _DeliverableUploadDialogState extends ConsumerState<DeliverableUploadDialog> {
  late final _title = TextEditingController(text: widget.current?.title ?? widget.spec.title);
  final _description = TextEditingController();
  final _link = TextEditingController();
  PlatformFile? _file;
  bool _useLink = false;
  bool _busy = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _link.dispose();
    super.dispose();
  }

  bool get _linkValid => _link.text.trim().startsWith('https://') && safeExternalUri(_link.text) != null;

  Future<void> _pick() async {
    final exts = widget.spec.extensions;
    final result = await FilePicker.pickFiles(
      type: exts.isEmpty ? FileType.any : FileType.custom,
      allowedExtensions: exts.isEmpty ? null : exts,
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) setState(() => _file = result.files.first);
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    try {
      final record = widget.record;
      String url;
      if (_useLink) {
        url = _link.text.trim();
      } else {
        final bytes = _file!.bytes;
        if (bytes == null) throw Exception('Could not read ${_file!.name}.');
        final semesters = await ref.read(fypmsSemestersProvider.future);
        final semesterCode =
            semesters.where((s) => s.id == record.academicSemesterId).map((s) => s.code).firstOrNull ?? 'unknown';
        url = await ref.read(supabaseStorageServiceProvider).uploadFile(
              bucket: _bucket,
              semesterCode: semesterCode,
              fypRecordId: record.id,
              resourceType: 'deliverable_${widget.spec.type}',
              version: (widget.current?.version ?? 0) + 1,
              fileName: _file!.name,
              bytes: bytes,
            );
      }
      await ref.read(supabaseRpcServiceProvider).submitDeliverable(
            fypRecordId: record.id,
            deliverableType: widget.spec.type,
            title: _title.text.trim(),
            description: _description.text.trim().isEmpty ? null : _description.text.trim(),
            fileUrl: url,
          );
      ref.invalidate(fypDeliverablesProvider(record.id));
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(SnackBar(content: Text('${widget.spec.title} submitted.')));
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    final spec = widget.spec;
    final ready = !_busy && _title.text.trim().isNotEmpty && (_useLink ? _linkValid : _file != null);
    final types = spec.extensions.isEmpty ? 'any file' : spec.extensions.map((e) => '.$e').join(' / ');

    return AlertDialog(
      title: Text(spec.title, style: (isDesktop ? DesignSystem.h3 : DesignSystem.bodyLg).copyWith(color: DesignSystem.primary)),
      content: SingleChildScrollView(
        child: SizedBox(
          width: isDesktop ? 480 : MediaQuery.of(context).size.width * 0.85,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _title,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(labelText: 'Title *'),
              ),
              const SizedBox(height: DesignSystem.spaceSm),
              TextField(
                controller: _description,
                decoration: const InputDecoration(labelText: 'Description (optional)'),
                maxLines: 2,
              ),
              const SizedBox(height: DesignSystem.spaceMd),
              if (spec.linkAllowed)
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: false, label: Text('Upload file'), icon: Icon(Icons.upload_file)),
                    ButtonSegment(value: true, label: Text('Link'), icon: Icon(Icons.link)),
                  ],
                  selected: {_useLink},
                  onSelectionChanged: _busy ? null : (s) => setState(() => _useLink = s.first),
                ),
              const SizedBox(height: DesignSystem.spaceSm),
              if (_useLink)
                TextField(
                  key: const Key('deliverable-link'),
                  controller: _link,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'https:// link',
                    helperText: 'For large systems, repositories or datasets',
                    errorText: _link.text.isNotEmpty && !_linkValid ? 'Use an https:// address' : null,
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _busy ? null : _pick,
                    icon: Icon(_file == null ? Icons.attach_file : Icons.check_circle, size: 18),
                    label: Text(_file?.name ?? 'Choose file ($types)', overflow: TextOverflow.ellipsis),
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
      ),
      actions: [
        TextButton(onPressed: _busy ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: ready ? _submit : null,
          style: ElevatedButton.styleFrom(backgroundColor: DesignSystem.secondary, foregroundColor: Colors.white),
          child: Text(_busy ? 'Uploading...' : 'Submit'),
        ),
      ],
    );
  }
}
