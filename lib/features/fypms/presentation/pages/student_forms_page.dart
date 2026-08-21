import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../../../../core/state/state_providers.dart';
import '../../../../core/supabase/fypms_rpc_service.dart';
import '../widgets/fypms_loading_widget.dart';
import '../widgets/student_record_workspace.dart';

class StudentFormsPage extends ConsumerWidget {
  const StudentFormsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formCodes = ref.watch(fypmsAvailableFormCodesProvider);
    final features = ref.watch(fypmsFeaturesProvider);

    return StudentRecordWorkspace(
      title: 'Form Submissions',
      builder: (context, ref, record) {
        final submissions = ref.watch(fypFormSubmissionsProvider(record.id));
        return Column(
          children: [
            if (features.value?.specialEvaluationEnabled != true)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(DesignSystem.gutter),
                padding: const EdgeInsets.all(DesignSystem.spaceMd),
                decoration: BoxDecoration(
                  color: DesignSystem.surfaceContainerLow,
                  borderRadius: DesignSystem.radiusXl,
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: DesignSystem.primary),
                    SizedBox(width: DesignSystem.spaceSm),
                    Expanded(
                      child: Text(
                        'Special evaluation forms (F14-F16) are currently disabled by the coordinator.',
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
                error: (e, _) => Center(child: Text('Error: $e')),
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
                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: DesignSystem.gutter),
                    children: [
                      for (final sub in items)
                        Card(
                          elevation: 1,
                          margin: const EdgeInsets.only(bottom: DesignSystem.spaceSm),
                          shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusLg),
                          color: DesignSystem.surfaceContainerLowest,
                          child: ListTile(
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
                          ),
                        ),
                    ],
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
    final payloadController = TextEditingController(
      text: '{\n  "title": ""\n}',
    );
    String? selectedCode = formCodes.isNotEmpty ? formCodes.first : null;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final isDesktop = MediaQuery.of(context).size.width >= 768;
            return AlertDialog(
              title: Text(
                'Submit Form',
                style: (isDesktop ? DesignSystem.h3 : DesignSystem.bodyLg)
                    .copyWith(color: DesignSystem.primary),
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: isDesktop ? 500 : MediaQuery.of(context).size.width * 0.85,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: selectedCode,
                        decoration: const InputDecoration(labelText: 'Form Code'),
                        isExpanded: true,
                        items: [
                          for (final code in formCodes)
                            DropdownMenuItem(value: code, child: Text(code)),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            setState(() => selectedCode = v);
                          }
                        },
                      ),
                      const SizedBox(height: DesignSystem.spaceSm),
                      TextField(
                        controller: payloadController,
                        decoration: const InputDecoration(
                          labelText: 'Payload (JSON)',
                          helperText: 'Enter form answers as a JSON object.',
                        ),
                        maxLines: 8,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final code = selectedCode;
                    if (code == null) return;
                    Map<String, dynamic>? payload;
                    try {
                      final decoded = payloadController.text.trim().isEmpty
                          ? <String, dynamic>{}
                          : (jsonDecode(payloadController.text) as Map<String, dynamic>?);
                      payload = decoded ?? <String, dynamic>{};
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Payload must be valid JSON.')),
                        );
                      }
                      return;
                    }
                    Navigator.of(dialogContext).pop();
                    try {
                      final rpc = ref.read(supabaseRpcServiceProvider);
                      await rpc.submitFypForm(
                        fypRecordId: fypRecordId,
                        formCode: code,
                        payload: payload,
                      );
                      if (context.mounted) {
                        ref.invalidate(fypFormSubmissionsProvider(fypRecordId));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Form submitted successfully.')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to submit: $e')),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignSystem.secondary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
