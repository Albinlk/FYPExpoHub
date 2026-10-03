import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../widgets/fypms_loading_widget.dart';
import '../widgets/student_form_dialog.dart';
import '../widgets/student_record_workspace.dart';
import '../../../../core/widgets/async_state.dart';

class StudentFormsPage extends ConsumerWidget {
  const StudentFormsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final features = ref.watch(fypmsFeaturesProvider);
    final applicationsOpen = features.value?.specialEvaluationEnabled ?? false;

    return StudentRecordWorkspace(
      title: 'Form Submissions',
      builder: (context, ref, record) {
        final submissions = ref.watch(fypFormSubmissionsProvider(record.id));
        final qualified = ref.watch(fypSpecialEvaluationProvider(record.id)).value?.eligible ?? false;
        final formCodes = fypmsFormCodesFor(applicationsOpen: applicationsOpen, qualified: qualified);
        return Column(
          children: [
            if (record.currentCourseCode == 'CSP650' || qualified)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(DesignSystem.gutter),
                padding: const EdgeInsets.all(DesignSystem.spaceMd),
                decoration: BoxDecoration(
                  color: DesignSystem.surfaceContainerLow,
                  borderRadius: DesignSystem.radiusXl,
                ),
                child: Row(
                  children: [
                    Icon(
                      qualified ? Icons.verified : Icons.info_outline,
                      color: qualified ? DesignSystem.secondary : DesignSystem.primary,
                    ),
                    const SizedBox(width: DesignSystem.spaceSm),
                    Expanded(
                      child: Text(
                        qualified
                            ? 'You qualified for special evaluation — F15 and F16 are open.'
                            : applicationsOpen
                                ? 'Special evaluation (F14) applications are open. F15 and F16 open once '
                                    'the CSP650 lecturer qualifies you.'
                                : 'Special evaluation (F14) applications are closed.',
                        key: const Key('special-evaluation-banner'),
                        style: DesignSystem.bodySm,
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: DesignSystem.gutter),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Forms & Submissions', style: DesignSystem.h2),
                  FilledButton.icon(
                    onPressed: () =>
                        _showSubmitFormDialog(context, ref, record.id, formCodes),
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Submit Form'),
                    style: FilledButton.styleFrom(
                      backgroundColor: DesignSystem.secondary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: DesignSystem.spaceSm),
            Expanded(
              child: submissions.when(
                loading: () => const FypmsLoadingWidget(),
                error: (e, _) => AsyncErrorView(error: e, onRetry: () => ref.invalidate(fypFormSubmissionsProvider(record.id)), what: 'this page'),
                data: (items) {
                  if (items.isEmpty) {
                    return Center(
                      child: Text(
                        'No form submissions yet.\nUse "Submit Form" to begin.',
                        style: DesignSystem.bodyMd,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: DesignSystem.gutter),
                    itemCount: items.length,
                    itemBuilder: (context, itemIndex) {
                      final sub = items[itemIndex];
                        return Card(
                          elevation: 1,
                          margin: const EdgeInsets.only(bottom: DesignSystem.spaceSm),
                          shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusLg),
                          color: DesignSystem.surfaceContainerLowest,
                          child: ExpansionTile(
                            dense: true,
                            leading: const Icon(Icons.description, color: DesignSystem.primary),
                            title: Text(
                              'Form ${sub.formCode} (v${sub.formVersion})',
                              style: DesignSystem.bodySm.copyWith(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Status: ${sub.status.replaceAll('_', ' ')}',
                              style: DesignSystem.bodySm,
                            ),
                            expandedAlignment: Alignment.centerLeft,
                            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            children: [FormAnswersView(formCode: sub.formCode, payload: sub.payload)],
                          ),
                        );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSubmitFormDialog(
      BuildContext context, WidgetRef ref, String fypRecordId, List<String> formCodes) {
    showDialog<void>(
      context: context,
      builder: (_) => StudentFormDialog(fypRecordId: fypRecordId, formCodes: formCodes),
    );
  }
}
