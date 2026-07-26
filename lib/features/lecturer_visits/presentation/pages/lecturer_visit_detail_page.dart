import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/project.dart';
import '../../../../core/domain/models/student_visit.dart';
import '../../../../core/state/state_providers.dart';
import '../../../../core/widgets/project_cover_image.dart';
import '../widgets/mark_visited_dialog.dart';
import '../widgets/undo_visit_dialog.dart';

class LecturerVisitDetailPage extends ConsumerStatefulWidget {
  final String projectId;

  const LecturerVisitDetailPage({super.key, required this.projectId});

  @override
  ConsumerState<LecturerVisitDetailPage> createState() => _LecturerVisitDetailPageState();
}

class _LecturerVisitDetailPageState extends ConsumerState<LecturerVisitDetailPage> {
  bool _isMarking = false;
  bool _isUndoing = false;

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/lecturer/visits');
    }
  }

  Future<void> _markVisited(Project project, String assignmentId, String role) async {
    final result = await showMarkVisitedDialog(context, project, role);
    if (result == null) return;

    setState(() => _isMarking = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not authenticated');

      final db = FirebaseFirestore.instance;
      final visitRef = db.collection('studentProjectVisits').doc();
      final now = FieldValue.serverTimestamp();

      await visitRef.set({
        'id': visitRef.id,
        'eventId': 'fskm-fyp-2026',
        'projectId': project.id,
        'assignmentId': assignmentId,
        'lecturerId': user.uid,
        'visitRole': role,
        'visitNote': result['note'] ?? '',
        'status': 'completed',
        'visitedAt': now,
        'createdAt': now,
        'updatedAt': now,
        'source': 'lecturer',
      });

      await db.collection('auditLogs').add({
        'actorUid': user.uid,
        'action': 'visit_marked',
        'targetType': 'studentProjectVisits',
        'targetId': visitRef.id,
        'eventId': 'fskm-fyp-2026',
        'metadataSafe': {
          'projectId': project.id,
          'assignmentId': assignmentId,
          'visitRole': role,
        },
        'createdAt': now,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pelajar telah ditanda sebagai dilawati.'),
            backgroundColor: DesignSystem.tertiary,
          ),
        );
        setState(() => _isMarking = false);
      }
    } on FirebaseException catch (e) {
      setState(() => _isMarking = false);
      final msg = e.code == 'already-exists'
          ? 'Lawatan telah pun direkodkan.'
          : e.code == 'permission-denied'
              ? 'Anda tidak dibenarkan menanda lawatan ini.'
              : 'Ralat: ${e.message}';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: DesignSystem.error),
        );
      }
    } catch (e) {
      setState(() => _isMarking = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ralat: ${e.toString()}'), backgroundColor: DesignSystem.error),
        );
      }
    }
  }

  Future<void> _undoVisit(StudentVisit visit) async {
    final reason = await showUndoVisitDialog(context);
    if (reason == null) return;

    setState(() => _isUndoing = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not authenticated');

      final db = FirebaseFirestore.instance;
      final now = FieldValue.serverTimestamp();

      await db.collection('studentProjectVisits').doc(visit.id).update({
        'status': 'voided',
        'voidedAt': now,
        'voidedBy': user.uid,
        'voidReason': reason,
        'updatedAt': now,
      });

      await db.collection('auditLogs').add({
        'actorUid': user.uid,
        'action': 'visit_voided',
        'targetType': 'studentProjectVisits',
        'targetId': visit.id,
        'eventId': visit.eventId,
        'metadataSafe': {
          'projectId': visit.projectId,
          'reason': reason,
          'voidedByRole': 'lecturer',
        },
        'createdAt': now,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lawatan telah dibatalkan.'),
            backgroundColor: DesignSystem.error,
          ),
        );
        setState(() => _isUndoing = false);
      }
    } on FirebaseException catch (e) {
      setState(() => _isUndoing = false);
      final msg = e.code == 'failed-precondition'
          ? 'Tempoh 30 minit untuk membatalkan lawatan telah tamat.'
          : e.code == 'permission-denied'
              ? 'Anda tidak dibenarkan membatalkan lawatan ini.'
              : 'Ralat: ${e.message}';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: DesignSystem.error),
        );
      }
    } catch (e) {
      setState(() => _isUndoing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ralat: ${e.toString()}'), backgroundColor: DesignSystem.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    final padding = isDesktop ? DesignSystem.marginDesktop : DesignSystem.marginMobile;
    final projects = ref.watch(projectsProvider);
    final project = projects.where((p) => p.id == widget.projectId).firstOrNull;
    final assignments = ref.watch(lecturerAssignmentsProvider);
    final visits = ref.watch(lecturerVisitsProvider);

    if (project == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Projek tidak dijumpai')),
        body: const Center(child: Text('Projek tidak dijumpai.')),
      );
    }

    final svAssignment = assignments.where((a) => a.projectId == project.id && a.role == 'supervisor').firstOrNull;
    final exAssignment = assignments.where((a) => a.projectId == project.id && a.role == 'examiner').firstOrNull;
    final svVisit = visits.where((v) => v.projectId == project.id && v.visitRole == 'supervisor').firstOrNull;
    final exVisit = visits.where((v) => v.projectId == project.id && v.visitRole == 'examiner').firstOrNull;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
                                Icon(Icons.workspace_premium, size: 13, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  'Calon Industri',
                                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
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
            _buildVisitSection('Penyelia (SV)', svAssignment, svVisit, project, _isMarking, _isUndoing),
            const SizedBox(height: DesignSystem.spaceSm),
            _buildVisitSection('Pemeriksa (EX)', exAssignment, exVisit, project, _isMarking, _isUndoing),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitSection(
    String title,
    dynamic assignment,
    StudentVisit? visit,
    Project project,
    bool isMarking,
    bool isUndoing,
  ) {
    final role = title.contains('SV') ? 'supervisor' : 'examiner';
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: role == 'supervisor' ? DesignSystem.primary.withOpacity(0.1) : DesignSystem.tertiary.withOpacity(0.1),
                    borderRadius: DesignSystem.radiusSm,
                  ),
                  child: Text(title, style: DesignSystem.labelCaps.copyWith(
                    color: role == 'supervisor' ? DesignSystem.primary : DesignSystem.tertiary,
                    fontWeight: FontWeight.bold,
                  )),
                ),
                const Spacer(),
                if (hasVisit)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: DesignSystem.tertiaryContainer.withOpacity(0.2),
                      borderRadius: DesignSystem.radiusSm,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, size: 14, color: DesignSystem.onTertiaryContainer),
                        const SizedBox(width: 4),
                        Text('Dilawati', style: DesignSystem.labelCaps.copyWith(color: DesignSystem.onTertiaryContainer)),
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
                    child: Text('Belum Dilawati', style: DesignSystem.labelCaps.copyWith(color: DesignSystem.onSurfaceVariant)),
                  ),
              ],
            ),
            if (hasVisit && visit != null) ...[
              const SizedBox(height: DesignSystem.spaceMd),
              _visitDetailRow('Masa Lawatan', _formatDateTime(visit.visitedAt)),
              if (visit.visitNote != null && visit.visitNote!.isNotEmpty)
                _visitDetailRow('Catatan', visit.visitNote!),
              const SizedBox(height: DesignSystem.spaceMd),
              Row(
                children: [
                  if (!isUndoing)
                    OutlinedButton.icon(
                      onPressed: () => _undoVisit(visit),
                      icon: const Icon(Icons.undo, size: 16),
                      label: Text('Batal Lawatan', style: DesignSystem.bodySm.copyWith(color: DesignSystem.error)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: DesignSystem.error,
                        side: const BorderSide(color: DesignSystem.error),
                        shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusLg),
                      ),
                    )
                  else
                    const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                ],
              ),
            ] else if (hasAssignment && !isVoided) ...[
              const SizedBox(height: DesignSystem.spaceMd),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isMarking ? null : () => _markVisited(project, assignment.id, role),
                  icon: isMarking
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.check_circle_outline, size: 18),
                  label: Text('Tanda sebagai Dilawati', style: DesignSystem.button),
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
              Text('Anda tidak ditugaskan untuk peranan ini.', style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant)),
            ],
          ],
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
    final months = ['Jan', 'Feb', 'Mac', 'Apr', 'Mei', 'Jun', 'Jul', 'Ogos', 'Sep', 'Okt', 'Nov', 'Dis'];
    final day = dt.day.toString();
    final month = months[dt.month - 1];
    final year = dt.year.toString();
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day $month $year, $hour:$minute';
  }
}
