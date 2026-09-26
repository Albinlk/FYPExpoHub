import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/fypms/fyp_rubric_template.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../widgets/fypms_loading_widget.dart';

/// How each form contributes to the CSP600 / CSP650 grade (textbook shares).
/// The coordinator sets the F2 / F3 / F4 split of CSP600's formulation 30 %,
/// which the textbook leaves to the course's OBE document.
class CoordinatorMarkAllocationPage extends ConsumerWidget {
  const CoordinatorMarkAllocationPage({super.key});

  static const _courses = {
    'CSP600': ['F2', 'F3', 'F4', 'F7', 'F8'],
    'CSP650': ['F9', 'F10', 'F11', 'F13'],
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rubrics = ref.watch(fypRubricTemplatesProvider);

    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        backgroundColor: DesignSystem.primary,
        title: Text(
          'Mark Allocation',
          style: DesignSystem.h3.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: rubrics.when(
        loading: () => const FypmsLoadingWidget(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          final byForm = {for (final r in list) r.formCode: r};
          return ListView(
            padding: const EdgeInsets.all(DesignSystem.gutter),
            children: [
              _FormulationSharesCard(byForm: byForm),
              const SizedBox(height: DesignSystem.spaceLg),
              for (final course in _courses.entries) ...[
                Text(course.key, style: DesignSystem.bodyLg.copyWith(fontWeight: FontWeight.bold, color: DesignSystem.primary)),
                const SizedBox(height: DesignSystem.spaceSm),
                Card(
                  color: DesignSystem.surfaceContainerLowest,
                  child: Padding(
                    padding: const EdgeInsets.all(DesignSystem.spaceMd),
                    child: Column(
                      children: [
                        for (final code in course.value)
                          if (byForm[code] != null) _ShareRow(rubric: byForm[code]!),
                        const Divider(),
                        Row(
                          children: [
                            const Expanded(child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
                            Text(
                              '${_courseTotal(course.value, byForm).toStringAsFixed(0)} %',
                              key: Key('total-${course.key}'),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: DesignSystem.spaceLg),
              ],
            ],
          );
        },
      ),
    );
  }

  static num _courseTotal(List<String> codes, Map<String, FypRubricTemplate> byForm) {
    num total = 0;
    for (final code in codes) {
      total += shareTotal(byForm[code]?.evaluatorShares ?? const {});
    }
    return total;
  }
}

/// Sum of a rubric's shares, flat ({"supervisor": 15}) or per CLO group.
num shareTotal(Map<String, dynamic> shares) {
  num total = 0;
  for (final v in shares.values) {
    if (v is num) {
      total += v;
    } else if (v is Map) {
      for (final inner in v.values) {
        if (inner is num) total += inner;
      }
    }
  }
  return total;
}

class _ShareRow extends StatelessWidget {
  const _ShareRow({required this.rubric});

  final FypRubricTemplate rubric;

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    rubric.evaluatorShares.forEach((key, value) {
      if (value is num) {
        parts.add('$key ${value.toStringAsFixed(0)}');
      } else if (value is Map) {
        value.forEach((role, v) => parts.add('$key $role ${(v as num).toStringAsFixed(0)}'));
      }
    });
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(rubric.rubricName, style: DesignSystem.bodySm.copyWith(fontWeight: FontWeight.w600))),
          const SizedBox(width: DesignSystem.spaceSm),
          Flexible(
            child: Text(
              parts.isEmpty ? '—' : parts.join(' · '),
              textAlign: TextAlign.right,
              style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

/// Edit the CSP600 formulation split; F2 + F3 + F4 must stay at 30 %.
class _FormulationSharesCard extends ConsumerStatefulWidget {
  const _FormulationSharesCard({required this.byForm});

  final Map<String, FypRubricTemplate> byForm;

  @override
  ConsumerState<_FormulationSharesCard> createState() => _FormulationSharesCardState();
}

class _FormulationSharesCardState extends ConsumerState<_FormulationSharesCard> {
  static const _codes = ['F2', 'F3', 'F4'];
  late final Map<String, TextEditingController> _controllers = {
    for (final code in _codes)
      code: TextEditingController(
        text: shareTotal(widget.byForm[code]?.evaluatorShares ?? const {}).toStringAsFixed(0),
      ),
  };
  bool _saving = false;

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  num? _value(String code) => num.tryParse(_controllers[code]!.text.trim());

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(setCsp600FormulationSharesProvider)(_value('F2')!, _value('F3')!, _value('F4')!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mark allocation saved.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final values = [for (final code in _codes) _value(code)];
    final valid = values.every((v) => v != null && v >= 0);
    final sum = valid ? values.fold<num>(0, (a, b) => a + b!) : null;
    final ok = sum == 30;

    return Card(
      color: DesignSystem.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CSP600 formulation (course lecturer)', style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              'The textbook allocates F7 25 % and F8 45 %; split the remaining 30 % across F2, F3 and F4 per the course OBE document.',
              style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
            ),
            const SizedBox(height: DesignSystem.spaceMd),
            Wrap(
              spacing: DesignSystem.spaceMd,
              runSpacing: DesignSystem.spaceSm,
              children: [
                for (final code in _codes)
                  SizedBox(
                    width: 110,
                    child: TextField(
                      key: Key('share-$code'),
                      controller: _controllers[code],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: '$code %'),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: DesignSystem.spaceSm),
            Row(
              children: [
                Expanded(
                  child: Text(
                    sum == null ? 'Enter a number for each form.' : 'F2 + F3 + F4 = ${sum.toStringAsFixed(0)} / 30',
                    style: DesignSystem.bodySm.copyWith(color: ok ? DesignSystem.onSurfaceVariant : DesignSystem.error),
                  ),
                ),
                FilledButton(
                  onPressed: ok && !_saving ? _save : null,
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
