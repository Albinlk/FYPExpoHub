import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../widgets/fypms_loading_widget.dart';
import '../widgets/supervision_request_card.dart';

/// F1 Mutual Acceptance requests that name the lecturer. The chosen supervisor
/// accepts or declines (textbook: the supervisor signs F1); a named
/// co-supervisor sees the request for information.
class SupervisorRequestsPage extends ConsumerWidget {
  const SupervisorRequestsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(mySupervisionRequestsProvider);

    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        backgroundColor: DesignSystem.primary,
        title: Text(
          'Supervision Requests',
          style: DesignSystem.h3.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: requests.when(
        loading: () => const FypmsLoadingWidget(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No students have asked you to supervise them yet.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(DesignSystem.gutter),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              return SupervisionRequestCard(
                key: ValueKey(item.request.id),
                request: item.request,
                subtitle: [
                  item.studentName ?? 'Student',
                  ?item.courseCode,
                  ?item.programmeCode,
                  if (item.myRole == 'co_supervisor') 'you are named as co-supervisor',
                ].join(' · '),
                canDecide: item.myRole == 'supervisor',
                approveLabel: 'Accept',
                rejectLabel: 'Decline',
              );
            },
          );
        },
      ),
    );
  }
}
