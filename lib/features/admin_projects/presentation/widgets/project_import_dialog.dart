import 'dart:convert';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/state/state_providers.dart';
import '../../../../core/supabase/supabase_client_provider.dart';
import '../../../../core/supabase/supabase_database_service.dart' show kEventSlug;
import '../../domain/project_import.dart';
import '../../../../core/widgets/admin_actions.dart';
import '../../../../core/layout/responsive.dart';

/// Applies previewed rows to the current exhibition (`import_event_projects`).
/// [onDuplicate] is 'skip' or 'update'.
final importEventProjectsProvider =
    Provider<Future<Map<String, dynamic>> Function(List<Map<String, Object>> rows, String onDuplicate, bool publish)>((ref) {
  return (rows, onDuplicate, publish) async {
    final eventId = await ref.read(supabaseDbServiceProvider).resolveEventId(kEventSlug);
    final res = await ref.read(supabaseClientProvider).rpc<dynamic>('import_event_projects', params: {
      'p_event_id': eventId,
      'p_rows': rows,
      'p_on_duplicate': onDuplicate,
      'p_publish': publish,
    });
    await ref.read(projectsProvider.notifier).refresh();
    ref.invalidate(boothsProvider);
    return Map<String, dynamic>.from(res as Map);
  };
});

/// Reads a picked file into a header + rows grid: a CSV, or the XLSX sheet
/// whose name mentions projects / booths (else the first sheet).
List<List<String>> projectGridFromFile(String name, List<int> bytes) {
  if (!name.toLowerCase().endsWith('.xlsx') && !name.toLowerCase().endsWith('.xls')) {
    return parseCsvRows(utf8.decode(bytes, allowMalformed: true).replaceFirst('﻿', ''));
  }
  final excel = Excel.decodeBytes(bytes);
  final names = excel.tables.keys.toList();
  if (names.isEmpty) return const [];
  final sheetName = names.firstWhere(
    (n) => RegExp(r'PROJEK|PROJECT|BOOTH|GERAI', caseSensitive: false).hasMatch(n),
    orElse: () => names.first,
  );
  return [
    for (final row in excel.tables[sheetName]!.rows)
      [for (final c in row) c?.value?.toString() ?? ''],
  ];
}

/// Admin imports projects and booth numbers from the Master File / CSV
/// (backlog F5): pick → preview with duplicates flagged → import.
class ProjectImportDialog extends ConsumerStatefulWidget {
  const ProjectImportDialog({super.key, this.initialGrid, this.initialFileName});

  /// For tests: skip the file picker.
  final List<List<String>>? initialGrid;
  final String? initialFileName;

  @override
  ConsumerState<ProjectImportDialog> createState() => _ProjectImportDialogState();
}

class _ProjectImportDialogState extends ConsumerState<ProjectImportDialog> {
  String? _fileName;
  ProjectImportParse? _parse;
  int _problems = 0;
  bool _update = false;
  bool _publish = false;
  bool _busy = false;
  Map<String, dynamic>? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialGrid != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _load(widget.initialFileName ?? 'import.csv', widget.initialGrid!));
    }
  }

  void _load(String name, List<List<String>> grid) {
    final parse = parseProjectSheet(grid);
    final projects = ref.read(projectsProvider);
    final problems = checkProjectImport(
      parse.rows,
      existingTitles: projects.map((p) => p.title),
      existingBooths: {
        for (final p in projects)
          if (p.boothNumber != null && p.boothNumber!.isNotEmpty) p.boothNumber!: p.title,
      },
    );
    setState(() {
      _fileName = name;
      _parse = parse;
      _problems = problems;
      _result = null;
      _error = parse.error;
    });
  }

  Future<void> _pick() async {
    final f = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['csv', 'txt', 'xlsx'], withData: true);
    final file = f?.files.firstOrNull;
    if (file?.bytes == null) return;
    try {
      _load(file!.name, projectGridFromFile(file.name, file.bytes!));
    } catch (e) {
      setState(() => _error = 'Could not read ${file!.name}: ${friendlyError(e)}');
    }
  }

  List<ProjectImportRow> get _importable => [
        for (final r in _parse?.rows ?? const <ProjectImportRow>[])
          if (r.problem == null && (_update || !r.existing)) r,
      ];

  Future<void> _import() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final res = await ref.read(importEventProjectsProvider)(
        [for (final r in _importable) r.toPayload()],
        _update ? 'update' : 'skip',
        _publish,
      );
      if (mounted) setState(() => _result = res);
    } catch (e) {
      if (mounted) setState(() => _error = 'Import failed: ${friendlyError(e)}');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final parse = _parse;
    final rows = parse?.rows ?? const <ProjectImportRow>[];
    final existing = rows.where((r) => r.problem == null && r.existing).length;
    final result = _result;
    return AlertDialog(
      backgroundColor: DesignSystem.surfaceContainerLowest,
      title: Text('Import Projects & Booths', style: DesignSystem.h2),
      content: SizedBox(
        width: dialogWidth(context, 720),
        height: 520,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Use the Master File project sheet or a CSV with a header row: Title (required), Students, Matric, '
              'Programme, Supervisor, Examiner, Booth, Zone, Category, Tags, Description, Day. '
              'Projects already in this exhibition (same title) are skipped unless you choose to update them.',
              style: DesignSystem.bodySm,
            ),
            const SizedBox(height: DesignSystem.spaceSm),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _busy ? null : _pick,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Choose file'),
                ),
                const SizedBox(width: DesignSystem.spaceSm),
                Expanded(child: Text(_fileName ?? 'No file chosen', overflow: TextOverflow.ellipsis)),
              ],
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_error!, style: const TextStyle(color: DesignSystem.error)),
              ),
            if (parse != null && parse.unmatchedHeaders.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('Ignored columns: ${parse.unmatchedHeaders.join(', ')}', style: DesignSystem.bodySm),
              ),
            if (rows.isNotEmpty) ...[
              const SizedBox(height: DesignSystem.spaceSm),
              Text(
                '${rows.length} rows · ${rows.length - _problems - existing} new · $existing already listed · $_problems with problems',
                key: const Key('import-summary'),
                style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.w600),
              ),
              SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text('Update projects already listed'),
                value: _update,
                onChanged: _busy ? null : (v) => setState(() => _update = v),
              ),
              SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text('Publish new projects and booths now (otherwise drafts)'),
                value: _publish,
                onChanged: _busy ? null : (v) => setState(() => _publish = v),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: rows.length,
                  itemBuilder: (_, i) {
                    final r = rows[i];
                    final status = r.problem ?? (r.existing ? (_update ? 'Will update' : 'Already listed — skipped') : 'New');
                    return ListTile(
                      dense: true,
                      leading: Text('${r.rowNumber}', style: DesignSystem.bodySm),
                      title: Text(r.title.isEmpty ? '(no title)' : r.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(
                        [
                          if (r.boothNumber != null) 'Booth ${r.boothNumber}',
                          if (r.values['supervisor_display_name'] != null) 'SV ${r.values['supervisor_display_name']}',
                          status,
                        ].join(' · '),
                        style: TextStyle(color: r.problem != null ? DesignSystem.error : null),
                      ),
                    );
                  },
                ),
              ),
            ],
            if (result != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Imported: ${result['inserted']} new, ${result['updated']} updated, ${result['skipped']} skipped, '
                  '${result['booths_linked']} booths linked.'
                  '${(result['problems'] as List?)?.isNotEmpty == true ? '\n${(result['problems'] as List).map((p) => 'Row ${p['row']}: ${p['problem']}').join('\n')}' : ''}',
                  key: const Key('import-result'),
                  style: const TextStyle(color: DesignSystem.secondary),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(result == null ? 'Cancel' : 'Close')),
        if (result == null)
          FilledButton(
            onPressed: _busy || _importable.isEmpty ? null : _import,
            child: Text(_busy ? 'Importing…' : 'Import ${_importable.length}'),
          ),
      ],
    );
  }
}
