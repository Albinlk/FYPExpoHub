import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/fypms/fyp_rubric_template.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../../../../core/state/state_providers.dart';
import '../../../../core/supabase/fypms_rpc_service.dart';

/// Coordinator rubric editor (backlog U4). Saving creates a new version;
/// past evaluations keep the version they were scored with.
class CoordinatorRubricsPage extends ConsumerWidget {
  const CoordinatorRubricsPage({super.key});

  /// The active (latest) rubric per form, in form order.
  static List<FypRubricTemplate> activeRubrics(List<FypRubricTemplate> all) {
    final byForm = <String, FypRubricTemplate>{};
    for (final r in all) {
      if (!r.isActive) continue;
      final cur = byForm[r.formCode];
      if (cur == null || r.version > cur.version) byForm[r.formCode] = r;
    }
    int n(String code) => int.tryParse(code.replaceAll(RegExp(r'\D'), '')) ?? 0;
    return byForm.values.toList()..sort((a, b) => n(a.formCode).compareTo(n(b.formCode)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rubrics = ref.watch(fypRubricTemplatesProvider);
    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        backgroundColor: DesignSystem.primary,
        title: Text('Rubrics', style: DesignSystem.h3.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: rubrics.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (all) {
          final list = activeRubrics(all);
          return ListView(
            padding: const EdgeInsets.all(DesignSystem.gutter),
            children: [
              Text(
                'Saving creates a new version. Evaluations already made keep the version they were scored with.',
                style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
              ),
              const SizedBox(height: DesignSystem.spaceSm),
              for (final r in list)
                Card(
                  child: ListTile(
                    title: Text('${r.formCode} — ${r.rubricName}'),
                    subtitle: Text('Version ${r.version} · ${r.criteria.length} criteria · shares ${_shares(r.evaluatorShares)}'),
                    trailing: IconButton(
                      key: Key('edit-rubric-${r.formCode}'),
                      tooltip: 'Edit rubric',
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => showDialog<void>(context: context, builder: (_) => RubricEditorDialog(rubric: r)),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  static String _shares(Map<String, dynamic> shares) => shares.entries
      .map((e) => e.value is Map ? '${e.key} (${(e.value as Map).entries.map((x) => '${x.key} ${x.value}').join(', ')})' : '${e.key} ${e.value}')
      .join(', ');
}

/// One criterion being edited.
class _Row {
  _Row(Map<String, dynamic> m)
      : key = m['key'] as String? ?? '',
        label = TextEditingController(text: m['label'] as String? ?? ''),
        weight = TextEditingController(text: '${m['weight'] ?? 1}'),
        clo = TextEditingController(text: m['clo'] as String? ?? ''),
        supervisorOnly = m['supervisor_only'] == true;

  String key;
  final TextEditingController label;
  final TextEditingController weight;
  final TextEditingController clo;
  bool supervisorOnly;

  void dispose() {
    label.dispose();
    weight.dispose();
    clo.dispose();
  }
}

/// "Literature review" -> "literature_review".
String criterionKey(String label) {
  final k = label.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_').replaceAll(RegExp(r'^_+|_+$'), '');
  final s = k.isEmpty ? 'criterion' : k;
  return RegExp(r'^[a-z]').hasMatch(s) ? (s.length > 40 ? s.substring(0, 40) : s) : 'c_$s';
}

class RubricEditorDialog extends ConsumerStatefulWidget {
  const RubricEditorDialog({super.key, required this.rubric});
  final FypRubricTemplate rubric;

  @override
  ConsumerState<RubricEditorDialog> createState() => _RubricEditorDialogState();
}

class _RubricEditorDialogState extends ConsumerState<RubricEditorDialog> {
  late final _name = TextEditingController(text: widget.rubric.rubricName);
  late final List<_Row> _rows = [for (final c in widget.rubric.criteria) _Row(c)];
  // (clo or null, role) -> share
  late final Map<(String?, String), TextEditingController> _shares = {
    for (final e in widget.rubric.evaluatorShares.entries)
      if (e.value is Map)
        for (final r in (e.value as Map).entries) (e.key, r.key as String): TextEditingController(text: '${r.value}')
      else
        (null, e.key): TextEditingController(text: '${e.value}'),
  };
  late final bool _hasClo = widget.rubric.criteria.any((c) => (c['clo'] as String?)?.isNotEmpty == true);
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    for (final r in _rows) {
      r.dispose();
    }
    for (final c in _shares.values) {
      c.dispose();
    }
    super.dispose();
  }

  String? _validate() {
    if (_name.text.trim().isEmpty) return 'The rubric needs a name.';
    if (_rows.isEmpty) return 'Add at least one criterion.';
    for (final r in _rows) {
      if (r.label.text.trim().isEmpty) return 'Every criterion needs a label.';
      final w = num.tryParse(r.weight.text.trim());
      if (w == null || w <= 0 || w > 20) return 'Weights must be between 0 and 20.';
    }
    for (final c in _shares.values) {
      final v = num.tryParse(c.text.trim());
      if (v == null || v < 0 || v > 100) return 'Shares must be 0–100.';
    }
    return null;
  }

  Future<void> _save() async {
    final problem = _validate();
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }
    // Keys: keep existing ones (so scores stay comparable), derive new ones.
    final used = <String>{};
    final criteria = [
      for (final r in _rows)
        {
          'key': () {
            var k = r.key.isNotEmpty ? r.key : criterionKey(r.label.text);
            var i = 2;
            final base = k;
            while (!used.add(k)) {
              k = '${base}_${i++}';
            }
            return k;
          }(),
          'label': r.label.text.trim(),
          'weight': num.parse(r.weight.text.trim()),
          'max': 10,
          if (r.supervisorOnly) 'supervisor_only': true,
          if (r.clo.text.trim().isNotEmpty) 'clo': r.clo.text.trim().toUpperCase(),
        },
    ];
    final shares = <String, dynamic>{};
    for (final e in _shares.entries) {
      final (clo, role) = e.key;
      final v = num.parse(e.value.text.trim());
      if (clo == null) {
        shares[role] = v;
      } else {
        (shares[clo] ??= <String, dynamic>{}) as Map<String, dynamic>;
        (shares[clo] as Map<String, dynamic>)[role] = v;
      }
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(supabaseRpcServiceProvider).saveRubricVersion(
            formCode: widget.rubric.formCode,
            rubricName: _name.text.trim(),
            criteria: criteria,
            evaluatorShares: shares,
          );
      ref.invalidate(fypRubricTemplatesProvider);
      if (!mounted) return;
      final m = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      m.showSnackBar(SnackBar(content: Text('${widget.rubric.formCode} rubric saved as a new version.')));
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = '$e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit ${widget.rubric.formCode} rubric'),
      content: SizedBox(
        width: 620,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(controller: _name, decoration: const InputDecoration(labelText: 'Rubric name')),
              const SizedBox(height: DesignSystem.spaceSm),
              Text('Criteria (each scored 0–10; marks = weight × score)', style: DesignSystem.bodySm.copyWith(fontWeight: FontWeight.w600)),
              for (var i = 0; i < _rows.length; i++)
                Row(
                  key: ObjectKey(_rows[i]),
                  children: [
                    Expanded(
                      flex: 5,
                      child: TextField(
                        key: Key('criterion-label-$i'),
                        controller: _rows[i].label,
                        decoration: const InputDecoration(labelText: 'Criterion'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 64,
                      child: TextField(
                        key: Key('criterion-weight-$i'),
                        controller: _rows[i].weight,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Weight'),
                      ),
                    ),
                    if (_hasClo) ...[
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 64,
                        child: TextField(controller: _rows[i].clo, decoration: const InputDecoration(labelText: 'CLO')),
                      ),
                    ],
                    Tooltip(
                      message: 'Supervisor only',
                      child: Checkbox(
                        value: _rows[i].supervisorOnly,
                        onChanged: (v) => setState(() => _rows[i].supervisorOnly = v ?? false),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Remove criterion',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => setState(() => _rows.removeAt(i).dispose()),
                    ),
                  ],
                ),
              TextButton.icon(
                onPressed: () => setState(() => _rows.add(_Row(const {'weight': 1}))),
                icon: const Icon(Icons.add),
                label: const Text('Add criterion'),
              ),
              const Divider(),
              Text('Share of the course grade (%) per evaluator', style: DesignSystem.bodySm.copyWith(fontWeight: FontWeight.w600)),
              Wrap(
                spacing: DesignSystem.spaceSm,
                children: [
                  for (final e in _shares.entries)
                    SizedBox(
                      width: 150,
                      child: TextField(
                        key: Key('share-${e.key.$1 ?? ''}-${e.key.$2}'),
                        controller: e.value,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: '${e.key.$1 == null ? '' : '${e.key.$1} '}${e.key.$2}'),
                      ),
                    ),
                ],
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_error!, key: const Key('rubric-error'), style: DesignSystem.bodySm.copyWith(color: DesignSystem.error)),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _busy ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: _busy ? null : _save, child: const Text('Save new version')),
      ],
    );
  }
}
