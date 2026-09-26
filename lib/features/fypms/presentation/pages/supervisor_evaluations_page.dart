import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../widgets/form_evaluations_view.dart';

class SupervisorEvaluationsPage extends ConsumerWidget {
  const SupervisorEvaluationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FormEvaluationsView(
      title: 'Evaluations',
      role: 'supervisor',
      records: ref.watch(assignedFypRecordsProvider(null)),
      emptyText: 'No records assigned to you.',
    );
  }
}
