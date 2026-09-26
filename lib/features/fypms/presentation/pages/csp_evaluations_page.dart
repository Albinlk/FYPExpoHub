import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../widgets/form_evaluations_view.dart';

/// Course-lecturer evaluations (F2, F3, F4, F7, F9, F13, F14) for the
/// records of the lecturer's CSP course.
class CspEvaluationsPage extends ConsumerWidget {
  const CspEvaluationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FormEvaluationsView(
      title: 'Course Evaluations',
      role: 'lecturer',
      records: ref.watch(fypRecordsProvider),
      emptyText: 'No records in your course yet.',
    );
  }
}
