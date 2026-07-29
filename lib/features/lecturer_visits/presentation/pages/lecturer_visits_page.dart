import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/project.dart';
import '../../../../core/domain/models/project_lecturer_assignment.dart';
import '../../../../core/domain/models/student_visit.dart';
import '../../../../core/firebase/firebase_providers.dart';
import '../../../../core/state/state_providers.dart';
import '../../../../core/widgets/project_cover_image.dart';
import '../../../lecturer_auth/presentation/pages/lecturer_sign_in_page.dart';
import '../widgets/mark_visited_dialog.dart';
import '../widgets/undo_visit_dialog.dart';

class LecturerVisitsPage extends ConsumerStatefulWidget {
  const LecturerVisitsPage({super.key});

  @override
  ConsumerState<LecturerVisitsPage> createState() => _LecturerVisitsPageState();
}

class _LecturerVisitsPageState extends ConsumerState<LecturerVisitsPage> {
  String _roleFilter = 'Semua';
  String _statusFilter = 'Semua';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    final padding = isDesktop ? DesignSystem.marginDesktop : DesignSystem.marginMobile;
    final lecturer = ref.watch(lecturerAuthProvider);
    final assignments = ref.watch(lecturerAssignmentsProvider);
    final visits = ref.watch(lecturerVisitsProvider);
    final projects = ref.watch(projectsProvider);
    final adminUser = ref.watch(authStateChangesProvider).asData?.value;

    if (lecturer == null) {
      return _buildSignInPrompt(context, padding);
    }

    final svAssignments = assignments.where((a) => a.role == 'supervisor').toList();
    final exAssignments = assignments.where((a) => a.role == 'examiner').toList();
    final svCompleted = visits.where((v) => v.visitRole == 'supervisor' && v.status == 'completed').length;
    final exCompleted = visits.where((v) => v.visitRole == 'examiner' && v.status == 'completed').length;

    final completedSet = <String>{};
    final voidedSet = <String>{};
    for (final v in visits) {
      final key = '${v.projectId}_${v.visitRole}';
      if (v.status == 'completed') completedSet.add(key);
      if (v.status == 'voided') voidedSet.add(key);
    }

    final filteredAssignments = assignments.where((a) {
      if (_roleFilter == 'SV' && a.role != 'supervisor') return false;
      if (_roleFilter == 'EX' && a.role != 'examiner') return false;

      final key = '${a.projectId}_${a.role}';
      if (_statusFilter == 'Belum Dilawati' && completedSet.contains(key)) return false;
      if (_statusFilter == 'Telah Dilawati' && !completedSet.contains(key)) return false;
      if (_statusFilter == 'Voided' && !voidedSet.contains(key)) return false;

      final project = projects.where((p) => p.id == a.projectId).firstOrNull;
      if (project == null) return false;
      final query = _searchController.text.toLowerCase().trim();
      if (query.isEmpty) return true;
      return project.title.toLowerCase().contains(query) ||
          project.teamDisplayNames.any((n) => n.toLowerCase().contains(query)) ||
          (project.boothNumber?.toLowerCase().contains(query) ?? false);
    }).toList();

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: DesignSystem.spaceXl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Lawatan Saya', style: DesignSystem.h1.copyWith(color: DesignSystem.primary)),
                    const SizedBox(height: DesignSystem.spaceXs),
                    Text(
                      'Selamat datang, ${lecturer.displayName}',
                      style: DesignSystem.bodyLg.copyWith(color: DesignSystem.onSurfaceVariant),
                    ),
                  ],
                ),
                if (adminUser != null)
                  TextButton.icon(
                    onPressed: () => context.go('/admin'),
                    icon: const Icon(Icons.admin_panel_settings, size: 16),
                    label: Text('Panel Admin', style: DesignSystem.bodySm.copyWith(color: DesignSystem.primary)),
                  ),
                TextButton.icon(
                  onPressed: () {
                    ref.read(lecturerAuthProvider.notifier).signOut();
                  },
                  icon: const Icon(Icons.logout, size: 16),
                  label: Text('Log Keluar', style: DesignSystem.bodySm.copyWith(color: DesignSystem.error)),
                ),
              ],
            ),
            const SizedBox(height: DesignSystem.spaceLg),
            Row(
              children: [
                Expanded(child: _VisitProgressCard(
                  title: 'Penyelia (SV)',
                  completed: svCompleted,
                  total: svAssignments.length,
                  color: DesignSystem.primary,
                )),
                const SizedBox(width: DesignSystem.spaceMd),
                Expanded(child: _VisitProgressCard(
                  title: 'Pemeriksa (EX)',
                  completed: exCompleted,
                  total: exAssignments.length,
                  color: DesignSystem.tertiary,
                )),
              ],
            ),
            const SizedBox(height: DesignSystem.spaceLg),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(DesignSystem.spaceMd),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'Cari projek, pelajar, booth...',
                        prefixIcon: Icon(Icons.search, color: DesignSystem.primary),
                      ),
                    ),
                    const SizedBox(height: DesignSystem.spaceSm),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('Peranan:', _roleFilter, ['Semua', 'SV', 'EX']),
                          const SizedBox(width: DesignSystem.spaceSm),
                          _buildFilterChip('Status:', _statusFilter, ['Semua', 'Belum Dilawati', 'Telah Dilawati', 'Voided']),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: DesignSystem.spaceLg),
            if (filteredAssignments.isEmpty)
              _buildEmptyState(_searchController.text.isNotEmpty || _roleFilter != 'Semua' || _statusFilter != 'Semua')
            else ...[
              Text(
                '${filteredAssignments.length} projek dijumpai',
                style: DesignSystem.labelCaps.copyWith(color: DesignSystem.primary),
              ),
              const SizedBox(height: DesignSystem.spaceMd),
              ...filteredAssignments.map((a) => _buildVisitCard(a, projects, completedSet, voidedSet, visits)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSignInPrompt(BuildContext context, double padding) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.login, size: 64, color: DesignSystem.outlineVariant),
              const SizedBox(height: DesignSystem.spaceMd),
              Text(
                'Log masuk untuk mengurus lawatan',
                style: DesignSystem.h2.copyWith(color: DesignSystem.primary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DesignSystem.spaceSm),
              Text(
                'Sila log masuk dengan akaun UiTM anda untuk mula menanda lawatan pelajar.',
                style: DesignSystem.bodyMd.copyWith(color: DesignSystem.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DesignSystem.spaceLg),
              ElevatedButton(
                onPressed: () => context.push('/lecturer/sign-in'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignSystem.primary,
                  foregroundColor: DesignSystem.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: DesignSystem.spaceXl, vertical: DesignSystem.spaceMd),
                  shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusLg),
                ),
                child: Text('Log Masuk', style: DesignSystem.button),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool hasFilters) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spaceXl),
        child: Column(
          children: [
            Icon(
              hasFilters ? Icons.search_off : Icons.check_circle_outline,
              size: 64,
              color: DesignSystem.outlineVariant,
            ),
            const SizedBox(height: DesignSystem.spaceMd),
            Text(
              hasFilters ? 'Tiada projek ditemui.' : 'Semua projek telah dilawati!',
              style: DesignSystem.bodyMd.copyWith(color: DesignSystem.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String current, List<String> options) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: DesignSystem.labelCaps.copyWith(color: DesignSystem.onSurfaceVariant)),
        const SizedBox(width: DesignSystem.spaceXs),
        ...options.map((opt) {
          final selected = current == opt;
          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: ChoiceChip(
              label: Text(opt, style: TextStyle(fontSize: 11, color: selected ? Colors.white : DesignSystem.onSurfaceVariant)),
              selected: selected,
              onSelected: (_) => setState(() {
                if (label.contains('Peranan')) _roleFilter = opt;
                else _statusFilter = opt;
              }),
              selectedColor: label.contains('Peranan') ? DesignSystem.primary : DesignSystem.tertiary,
              visualDensity: VisualDensity.compact,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildVisitCard(
    ProjectLecturerAssignment assignment,
    List<Project> projects,
    Set<String> completedSet,
    Set<String> voidedSet,
    List<StudentVisit> visits,
  ) {
    final project = projects.where((p) => p.id == assignment.projectId).firstOrNull;
    if (project == null) return const SizedBox.shrink();

    final key = '${project.id}_${assignment.role}';
    final isCompleted = completedSet.contains(key);
    final isVoided = voidedSet.contains(key);
    final visit = visits.where((v) => v.projectId == project.id && v.visitRole == assignment.role).firstOrNull;

    return Card(
      clipBehavior: Clip.antiAlias,
      color: project.calonIndustri ? DesignSystem.tertiaryContainer.withValues(alpha: 0.15) : null,
      surfaceTintColor: project.calonIndustri ? DesignSystem.tertiary : null,
      margin: const EdgeInsets.only(bottom: DesignSystem.spaceSm),
      child: InkWell(
        onTap: () => context.push('/lecturer/visits/${project.id}'),
        child: Padding(
          padding: const EdgeInsets.all(DesignSystem.spaceSm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: 80,
                    height: 60,
                    child: ProjectCoverImage(
                      title: project.title,
                      category: project.category,
                      imageUrl: project.coverImageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (project.calonIndustri)
                    Positioned(
                      top: 2,
                      left: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: DesignSystem.tertiary,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Icon(Icons.workspace_premium, size: 10, color: Colors.white),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: DesignSystem.spaceSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.title,
                      style: DesignSystem.bodySm.copyWith(fontWeight: FontWeight.bold, color: DesignSystem.primary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      project.teamDisplayNames.join(', '),
                      style: DesignSystem.labelCaps.copyWith(color: DesignSystem.onSurfaceVariant, fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: assignment.role == 'supervisor' ? DesignSystem.primary.withOpacity(0.1) : DesignSystem.tertiary.withOpacity(0.1),
                            borderRadius: DesignSystem.radiusSm,
                          ),
                          child: Text(
                            assignment.role == 'supervisor' ? 'SV' : 'EX',
                            style: DesignSystem.labelCaps.copyWith(
                              color: assignment.role == 'supervisor' ? DesignSystem.primary : DesignSystem.tertiary,
                              fontSize: 9,
                            ),
                          ),
                        ),
                        const SizedBox(width: DesignSystem.spaceSm),
                        if (project.boothNumber != null)
                          Text(
                            project.boothNumber!,
                            style: DesignSystem.labelCaps.copyWith(color: DesignSystem.secondary, fontSize: 9),
                          ),
                        const Spacer(),
                        _buildStatusChip(isCompleted, isVoided, visit),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool isCompleted, bool isVoided, StudentVisit? visit) {
    if (isVoided) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: DesignSystem.errorContainer,
          borderRadius: DesignSystem.radiusSm,
        ),
        child: Text('Voided', style: DesignSystem.labelCaps.copyWith(color: DesignSystem.onErrorContainer, fontSize: 9)),
      );
    }
    if (isCompleted) {
      final timeStr = visit?.visitedAt != null
          ? '${visit!.visitedAt.hour.toString().padLeft(2, '0')}:${visit.visitedAt.minute.toString().padLeft(2, '0')}'
          : '';
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: DesignSystem.tertiaryContainer.withOpacity(0.2),
          borderRadius: DesignSystem.radiusSm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 10, color: DesignSystem.onTertiaryContainer),
            const SizedBox(width: 3),
            Text(timeStr, style: DesignSystem.labelCaps.copyWith(color: DesignSystem.onTertiaryContainer, fontSize: 9)),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: DesignSystem.surfaceContainerHighest,
        borderRadius: DesignSystem.radiusSm,
      ),
      child: Text('Belum', style: DesignSystem.labelCaps.copyWith(color: DesignSystem.onSurfaceVariant, fontSize: 9)),
    );
  }
}

class _VisitProgressCard extends StatelessWidget {
  final String title;
  final int completed;
  final int total;
  final Color color;

  const _VisitProgressCard({
    required this.title,
    required this.completed,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? completed / total : 0.0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: DesignSystem.labelCaps.copyWith(color: DesignSystem.onSurfaceVariant)),
            const SizedBox(height: DesignSystem.spaceSm),
            Text('$completed / $total', style: DesignSystem.h2.copyWith(color: color, fontWeight: FontWeight.bold)),
            const SizedBox(height: DesignSystem.spaceSm),
            ClipRRect(
              borderRadius: DesignSystem.radiusFull,
              child: LinearProgressIndicator(
                value: pct,
                backgroundColor: DesignSystem.surfaceContainer,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
