import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/fypms/fyp_record.dart';
import '../../../../core/state/fypms_state_providers.dart';
import 'fypms_loading_widget.dart';
import 'rubric_evaluation_dialog.dart';
import 'special_evaluation_dialog.dart';

/// The evaluations list shared by the supervisor, examiner and CSP-lecturer
/// workspaces. Only forms [role] evaluates (see [fypmsFormEvaluatorRoles])
/// get an Evaluate action; the server enforces the same rule.
class FormEvaluationsView extends StatelessWidget {
  const FormEvaluationsView({
    super.key,
    required this.title,
    required this.role,
    required this.records,
    required this.emptyText,
  });

  final String title;

  /// supervisor | examiner | lecturer | coordinator
  final String role;
  final AsyncValue<List<FypRecord>> records;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        backgroundColor: DesignSystem.primary,
        title: Text(
          title,
          style: DesignSystem.h3.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: records.when(
        loading: () => const FypmsLoadingWidget(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return Center(child: Text(emptyText));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(DesignSystem.gutter),
            itemCount: list.length,
            itemBuilder: (context, index) => _RecordEvaluationSection(record: list[index], role: role),
          );
        },
      ),
    );
  }
}

class _RecordEvaluationSection extends ConsumerWidget {
  final FypRecord record;
  final String role;

  const _RecordEvaluationSection({required this.record, required this.role});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissions = ref.watch(fypFormSubmissionsProvider(record.id));
    final special = ref.watch(fypSpecialEvaluationProvider(record.id));
    final qualified = special.value?.eligible ?? false;
    // F14 is decided by the CSP650 lecturer, not scored with a rubric.
    final showF14 = role == 'lecturer' && record.currentCourseCode == 'CSP650';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: DesignSystem.spaceSm),
          child: Text(
            record.projectTitle ?? 'Untitled Project',
            style: DesignSystem.bodyLg.copyWith(fontWeight: FontWeight.bold, color: DesignSystem.primary),
          ),
        ),
        if (showF14)
          Card(
            elevation: 1,
            margin: const EdgeInsets.only(bottom: DesignSystem.spaceXs),
            shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusLg),
            color: DesignSystem.surfaceContainerLowest,
            child: ListTile(
              dense: true,
              leading: Icon(
                qualified ? Icons.verified : Icons.fact_check_outlined,
                color: qualified ? DesignSystem.secondary : DesignSystem.primary,
              ),
              title: Text('F14 — Special evaluation', style: DesignSystem.bodySm.copyWith(fontWeight: FontWeight.bold)),
              subtitle: Text(specialEvaluationStatusLabel(special.value), style: DesignSystem.bodySm),
              trailing: OutlinedButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => SpecialEvaluationDialog(record: record),
                ),
                child: const Text('Check'),
              ),
            ),
          ),
        submissions.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error: $e'),
          data: (all) {
            final list = [for (final s in all) if (fypmsCanEvaluate(s.formCode, role)) s];
            if (list.isEmpty) {
              return const Padding(
                padding: EdgeInsets.only(bottom: DesignSystem.spaceMd),
                child: Text('No forms for you to evaluate on this project.', style: DesignSystem.bodySm),
              );
            }
            return Column(
              children: [
                for (final sub in list)
                  Card(
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: DesignSystem.spaceXs),
                    shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusLg),
                    color: DesignSystem.surfaceContainerLowest,
                    child: ListTile(
                      dense: true,
                      leading: const Icon(Icons.description, color: DesignSystem.primary),
                      title: Text('Form ${sub.formCode}', style: DesignSystem.bodySm.copyWith(fontWeight: FontWeight.bold)),
                      subtitle: Text('Submitted: ${_formatDate(sub.createdAt)}', style: DesignSystem.bodySm),
                      trailing: _isSpecial(sub.formCode) && !qualified
                          ? const Tooltip(
                              message: 'The CSP650 lecturer has not qualified this student on F14.',
                              child: FilledButton(onPressed: null, child: Text('Not qualified')),
                            )
                          : FilledButton(
                              onPressed: () => showDialog<void>(
                                context: context,
                                builder: (_) => RubricEvaluationDialog(submission: sub, role: role),
                              ),
                              child: const Text('Evaluate'),
                            ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: DesignSystem.spaceLg),
      ],
    );
  }

  static bool _isSpecial(String formCode) => formCode == 'F15' || formCode == 'F16';

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    return '${local.day.toString().padLeft(2, '0')}-${local.month.toString().padLeft(2, '0')}-${local.year}';
  }
}
