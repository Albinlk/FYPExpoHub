import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../widgets/form_evaluations_view.dart';

class ExaminerEvaluationsPage extends ConsumerWidget {
  const ExaminerEvaluationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FormEvaluationsView(
      title: 'Examiner Evaluations',
      role: 'examiner',
      records: ref.watch(assignedFypRecordsProvider('examiner')),
      emptyText: 'No records assigned for examination.',
    );
  }
}
