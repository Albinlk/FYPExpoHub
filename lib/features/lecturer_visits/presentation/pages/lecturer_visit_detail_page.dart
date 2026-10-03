import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/project.dart';
import '../../../../core/domain/models/project_lecturer_assignment.dart';
import '../../../../core/domain/models/student_visit.dart';
import '../../../../core/supabase/supabase_client_provider.dart';
import '../../../../core/domain/fypms_exhibition_evaluation.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../../../../core/state/state_providers.dart';
import '../../../../core/widgets/project_cover_image.dart';
import '../../../fypms/presentation/widgets/rubric_evaluation_dialog.dart';
import '../widgets/mark_visited_dialog.dart';
import '../widgets/undo_visit_dialog.dart';
import '../../../../core/widgets/admin_actions.dart';

class LecturerVisitDetailPage extends ConsumerStatefulWidget {
  final String projectId;

  const LecturerVisitDetailPage({super.key, required this.projectId});

  @override
  ConsumerState<LecturerVisitDetailPage> createState() => _LecturerVisitDetailPageState();
}

class _LecturerVisitDetailPageState extends ConsumerState<LecturerVisitDetailPage> {
  bool _isOpeningScore = false;

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/lecturer/visits');
    }
  }

  /// Plain-language reason a mark-visited call failed, with the next step.
  String _markErrorMessage(Object e) {
    final text = e.toString();
    // "failed-precondition: Visits closed on 08 Aug 2026 00:00." etc.
    final window = RegExp(r'(Visits (?:open|closed) on [^.]+\.|Student project visits are currently disabled\.)')
        .firstMatch(text)
        ?.group(1);
    if (text.contains('already-exists')) return 'Visit has already been recorded.';
    if (window != null) return window;
    if (text.contains('permission-denied')) return 'You are not allowed to mark this visit.';
    return 'Could not save the visit: ${friendlyError(e)}';
  }

  Future<void> _markVisited(Project project, String assignmentId, String role) async {
    final result = await showMarkVisitedDialog(
      context,
      project,
      role,
      describeError: _markErrorMessage,
      onSubmit: (note) async {
        final user = ref.read(currentAuthUserProvider);
        if (user == null) throw Exception('Not authenticated');
        await ref.read(supabaseRpcServiceProvider).markStudentProjectVisited(
              assignmentId: assignmentId,
              visitNote: note,
            );
      },
    );
    if (result == null) return;

    ref.invalidate(allVisitsProvider);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Student has been marked as visited.'),
        backgroundColor: DesignSystem.tertiary,
      ),
    );
  }

  /// R9: the supervisor / examiner scores F10 (or F15 for a student qualified
  /// on F14) with its textbook rubric right from the exhibition visit.
  Future<void> _scoreExhibitionForm(String role) async {
    setState(() => _isOpeningScore = true);
    try {
      final opened = await ref.read(openExhibitionEvaluationProvider)(widget.projectId);
      final submission = opened.submission;
      if (!mounted) return;
      setState(() => _isOpeningScore = false);
      if (submission == null) throw Exception('The form could not be opened.');
      await showDialog<void>(
        context: context,
        builder: (_) => RubricEvaluationDialog(submission: submission, role: opened.evaluatorRole ?? role),
      );
      ref.invalidate(exhibitionEvaluationProvider(widget.projectId));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isOpeningScore = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open the evaluation: ${friendlyError(e)}'), backgroundColor: DesignSystem.error),
      );
    }
  }

  String _undoErrorMessage(Object e) {
    final text = e.toString();
    if (text.contains('permission-denied')) return 'You are not allowed to cancel this visit.';
    if (text.contains('expired') || text.contains('window')) {
      return 'The undo window for this visit has expired.';
    }
    return 'Could not cancel the visit: ${friendlyError(e)}';
  }

  Future<void> _undoVisit(StudentVisit visit) async {
    final reason = await showUndoVisitDialog(
      context,
      describeError: _undoErrorMessage,
      onSubmit: (reason) async {
        final user = ref.read(currentAuthUserProvider);
        if (user == null) throw Exception('Not authenticated');
        await ref.read(supabaseRpcServiceProvider).voidStudentProjectVisit(
              visitId: visit.id,
              reason: reason,
            );
      },
    );
    if (reason == null) return;

    ref.invalidate(allVisitsProvider);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Visit has been cancelled. Student can be revisited.'),
        backgroundColor: DesignSystem.tertiary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    final padding = isDesktop ? DesignSystem.marginDesktop : DesignSystem.marginMobile;
    final projects = ref.watch(publicProjectsProvider);
    final project = projects.where((p) => p.id == widget.projectId).firstOrNull;
    final assignments = ref.watch(lecturerAssignmentsProvider);
    final visits = ref.watch(lecturerVisitsProvider);

    if (project == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Project Not Found')),
        body: const Center(child: Text('Project not found.')),
      );
    }

    final svAssignment = assignments.where((a) => a.projectId == project.id && a.role == 'supervisor').firstOrNull;
    final exAssignment = assignments.where((a) => a.projectId == project.id && a.role == 'examiner').firstOrNull;
    final svVisit = visits.where((v) => v.projectId == project.id && v.visitRole == 'supervisor').firstOrNull;
    final exVisit = visits.where((v) => v.projectId == project.id && v.visitRole == 'examiner').firstOrNull;
    final exhibition = ref.watch(exhibitionEvaluationProvider(project.id)).value;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: _goBack,
        ),
        title: Text(project.title, style: DesignSystem.h3.copyWith(color: DesignSystem.primary, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: DesignSystem.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              clipBehavior: Clip.antiAlias,
              color: project.calonIndustri ? DesignSystem.tertiaryContainer.withValues(alpha: 0.15) : null,
              surfaceTintColor: project.calonIndustri ? DesignSystem.tertiary : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      SizedBox(
                        height: 180,
                        width: double.infinity,
                        child: ProjectCoverImage(
                          title: project.title,
                          category: project.category,
                          imageUrl: project.coverImageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (project.calonIndustri)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: DesignSystem.tertiary,
                              borderRadius: DesignSystem.radiusSm,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.workspace_premium, size: 13, color: Colors.white),
                                const SizedBox(width: 4),
                                const Text(
                                  'Industry Candidate',
                                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(DesignSystem.spaceMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(project.title, style: DesignSystem.h3.copyWith(color: DesignSystem.primary)),
                        const SizedBox(height: DesignSystem.spaceXs),
                        Text(project.teamDisplayNames.join(', '), style: DesignSystem.bodyMd.copyWith(color: DesignSystem.onSurfaceVariant)),
                        const SizedBox(height: DesignSystem.spaceXs),
                        Text(project.programmeName, style: DesignSystem.bodySm.copyWith(color: DesignSystem.secondary)),
                        if (project.boothNumber != null) ...[
                          const SizedBox(height: DesignSystem.spaceXs),
                          Row(
                            children: [
                              Icon(Icons.room, size: 16, color: DesignSystem.secondary),
                              const SizedBox(width: 4),
                              Text('Booth ${project.boothNumber}', style: DesignSystem.bodyMd.copyWith(color: DesignSystem.secondary)),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: DesignSystem.spaceMd),
            _buildVisitSection('Supervisor (SV)', svAssignment, svVisit, project, exhibition),
            const SizedBox(height: DesignSystem.spaceSm),
            _buildVisitSection('Examiner (EX)', exAssignment, exVisit, project, exhibition),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitSection(
    String title,
    ProjectLecturerAssignment? assignment,
    StudentVisit? visit,
    Project project,
    ExhibitionEvaluation? exhibition,
  ) {
    final role = title.contains('SV') ? 'supervisor' : 'examiner';
    final canScore =
        assignment != null && exhibition != null && exhibition.canScore && exhibition.evaluatorRole == role;
    final hasAssignment = assignment != null;
    final hasVisit = visit != null && visit.status == 'completed';
    final isVoided = visit != null && visit.status == 'voided';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // The role chip gives way on narrow phones rather than
                // pushing the status chip off the card.
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: role == 'supervisor' ? DesignSystem.primary.withValues(alpha: 0.1) : DesignSystem.tertiary.withValues(alpha: 0.1),
                        borderRadius: DesignSystem.radiusSm,
                      ),
                      child: Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: DesignSystem.labelCaps.copyWith(
                          color: role == 'supervisor' ? DesignSystem.primary : DesignSystem.tertiary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: DesignSystem.spaceSm),
                if (hasVisit)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: DesignSystem.tertiaryContainer.withValues(alpha: 0.2),
                      borderRadius: DesignSystem.radiusSm,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, size: 14, color: DesignSystem.onTertiaryContainer),
                        const SizedBox(width: 4),
                        Text('Visited', style: DesignSystem.labelCaps.copyWith(color: DesignSystem.onTertiaryContainer)),
                      ],
                    ),
                  )
                else if (isVoided)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: DesignSystem.errorContainer,
                      borderRadius: DesignSystem.radiusSm,
                    ),
                    child: Text('Voided', style: DesignSystem.labelCaps.copyWith(color: DesignSystem.onErrorContainer)),
                  )
                else if (hasAssignment)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: DesignSystem.surfaceContainerHighest,
                      borderRadius: DesignSystem.radiusSm,
                    ),
                    child: Text('Not Visited', style: DesignSystem.labelCaps.copyWith(color: DesignSystem.onSurfaceVariant)),
                  ),
              ],
            ),
            if (hasVisit) ...[
              const SizedBox(height: DesignSystem.spaceMd),
              _visitDetailRow('Visit Time', _formatDateTime(visit.visitedAt)),
              if (visit.visitNote != null && visit.visitNote!.isNotEmpty)
                _visitDetailRow('Note', visit.visitNote!),
              const SizedBox(height: DesignSystem.spaceMd),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _undoVisit(visit),
                    icon: const Icon(Icons.undo, size: 16),
                    label: const Text('Cancel Visit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: DesignSystem.error,
                      side: const BorderSide(color: DesignSystem.error),
                      textStyle: DesignSystem.bodySm,
                      shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusLg),
                    ),
                  ),
                ],
              ),
            ] else if (hasAssignment && (!hasVisit || isVoided)) ...[
              const SizedBox(height: DesignSystem.spaceMd),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _markVisited(project, assignment.id, role),
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: Text('Mark as Visited', style: DesignSystem.button),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignSystem.primary,
                    foregroundColor: DesignSystem.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: DesignSystem.spaceMd),
                    shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusLg),
                  ),
                ),
              ),
            ] else if (!hasAssignment) ...[
              const SizedBox(height: DesignSystem.spaceMd),
              Text('You are not assigned to this role.', style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant)),
            ],
            if (canScore) _buildScoreRow(exhibition, role),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreRow(ExhibitionEvaluation exhibition, String role) {
    final form = exhibition.formCode!;
    final mine = exhibition.myWeightedTotal;
    return Padding(
      padding: const EdgeInsets.only(top: DesignSystem.spaceSm),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          key: Key('score-$form-$role'),
          onPressed: _isOpeningScore ? null : () => _scoreExhibitionForm(role),
          icon: _isOpeningScore
              ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : Icon(mine == null ? Icons.grading : Icons.edit_note, size: 18),
          label: Text(
            mine == null
                ? 'Score $form (${form == 'F15' ? 'special evaluation' : 'final presentation'})'
                : '$form scored · ${mine.toStringAsFixed(1)}% — update',
            overflow: TextOverflow.ellipsis,
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: DesignSystem.spaceSm),
            shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusLg),
          ),
        ),
      ),
    );
  }

  Widget _visitDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: DesignSystem.labelCaps.copyWith(color: DesignSystem.onSurfaceVariant)),
          ),
          Expanded(
            child: Text(value, style: DesignSystem.bodySm.copyWith(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final day = dt.day.toString();
    final month = months[dt.month - 1];
    final year = dt.year.toString();
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day $month $year, $hour:$minute';
  }
}
