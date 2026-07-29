import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/project.dart';
import '../../../../core/domain/models/project_lecturer_assignment.dart';
import '../../../../core/domain/models/student_visit.dart';
import '../../../../core/state/state_providers.dart';
import '../widgets/summary_cards.dart';
import '../widgets/visit_data_table.dart';

class AdminVisitsPage extends ConsumerStatefulWidget {
  const AdminVisitsPage({super.key});

  @override
  ConsumerState<AdminVisitsPage> createState() => _AdminVisitsPageState();
}

class _AdminVisitsPageState extends ConsumerState<AdminVisitsPage> {
  String _currentTab = 'Overview';
  String _roleFilter = 'All';
  String _statusFilter = 'All';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _voidVisit(StudentVisit visit) async {
    final reasonController = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusXl),
        title: Text('Void Visit', style: DesignSystem.h3.copyWith(color: DesignSystem.error)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('You are about to void this visit. This action cannot be undone.', style: DesignSystem.bodyMd),
            const SizedBox(height: DesignSystem.spaceMd),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Reason *'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final r = reasonController.text.trim();
              if (r.isEmpty) return;
              Navigator.pop(ctx, r);
            },
            style: ElevatedButton.styleFrom(backgroundColor: DesignSystem.error, foregroundColor: Colors.white),
            child: const Text('Void'),
          ),
        ],
      ),
    );

    if (reason == null) return;

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
          'voidedByRole': 'admin',
        },
        'createdAt': now,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Visit has been voided.'), backgroundColor: DesignSystem.error),
        );
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        final msg = e.code == 'permission-denied' ? 'You are not allowed.' : 'Error: ${e.message}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: DesignSystem.error),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: DesignSystem.error),
        );
      }
    }
  }

  void _exportCsv(
    List<ProjectLecturerAssignment> filteredAssignments,
    List<StudentVisit> visits,
    List<Project> projects,
  ) {
    final csv = exportVisitsCsv(filteredAssignments, visits, projects);
    final bytes = utf8.encode(csv);
    final base64 = base64Encode(bytes);
    final href = 'data:text/csv;base64,$base64';

    final document = globalContext['document'] as JSObject;
    final anchor = document.callMethod('createElement'.toJS, ['a'.toJS].toJS) as JSObject;
    anchor['href'] = href.toJS;
    anchor['download'] = 'student_visits.csv'.toJS;
    anchor.callMethod('click'.toJS, null);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    final padding = isDesktop ? DesignSystem.marginDesktop : DesignSystem.marginMobile;
    final assignments = ref.watch(allAssignmentsProvider).asData?.value ?? [];
    final visits = ref.watch(allVisitsProvider).asData?.value ?? [];
    final projects = ref.watch(projectsProvider);

    final svTotal = assignments.where((a) => a.role == 'supervisor' && a.status == 'active').length;
    final exTotal = assignments.where((a) => a.role == 'examiner' && a.status == 'active').length;
    final totalRequired = svTotal + exTotal;
    final svCompleted = visits.where((v) => v.visitRole == 'supervisor' && v.status == 'completed').length;
    final exCompleted = visits.where((v) => v.visitRole == 'examiner' && v.status == 'completed').length;
    final completed = svCompleted + exCompleted;
    final pending = totalRequired - completed;
    final voided = visits.where((v) => v.status == 'voided').length;

    final todayStart = DateTime.now();
    final todayEnd = DateTime(todayStart.year, todayStart.month, todayStart.day + 1);
    final visitedToday = visits.where((v) =>
      v.status == 'completed' &&
      v.visitedAt.isAfter(todayStart) &&
      v.visitedAt.isBefore(todayEnd)
    ).length;

    final filteredAssignments = assignments.where((a) {
      if (_roleFilter == 'SV' && a.role != 'supervisor') return false;
      if (_roleFilter == 'EX' && a.role != 'examiner') return false;
      final visit = visits.where((v) => v.projectId == a.projectId && v.visitRole == a.role).firstOrNull;
      if (_statusFilter == 'Visited' && (visit == null || visit.status != 'completed')) return false;
      if (_statusFilter == 'Not Yet' && visit != null && visit.status == 'completed') return false;
      if (_statusFilter == 'Voided' && (visit == null || visit.status != 'voided')) return false;
      if (_statusFilter == 'Visited' && visit == null) return false;

      final query = _searchController.text.toLowerCase().trim();
      if (query.isEmpty) return true;
      final project = projects.where((p) => p.id == a.projectId).firstOrNull;
      if (project == null) return false;
      return a.lecturerDisplayName.toLowerCase().contains(query) ||
          project.title.toLowerCase().contains(query) ||
          project.teamDisplayNames.any((n) => n.toLowerCase().contains(query)) ||
          (project.boothNumber?.toLowerCase().contains(query) ?? false);
    }).toList();

    final tabs = ['Overview', 'By Lecturer', 'By Project', 'Visit Log'];

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: DesignSystem.spaceXl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Student Visit Monitoring', style: DesignSystem.h1.copyWith(color: DesignSystem.primary)),
            const SizedBox(height: DesignSystem.spaceSm),
            Text('Summary of student visits by lecturer', style: DesignSystem.bodyLg.copyWith(color: DesignSystem.onSurfaceVariant)),
            const SizedBox(height: DesignSystem.spaceLg),
            SummaryCardsRow(
              totalRequired: totalRequired,
              completed: completed,
              pending: pending,
              svCompleted: svCompleted,
              svTotal: svTotal,
              exCompleted: exCompleted,
              exTotal: exTotal,
              visitedToday: visitedToday,
              voided: voided,
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
                        hintText: 'Search lecturers, projects, students, booths...',
                        prefixIcon: Icon(Icons.search, color: DesignSystem.primary),
                      ),
                    ),
                    const SizedBox(height: DesignSystem.spaceSm),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _filterChip('Role', _roleFilter, ['All', 'SV', 'EX']),
                          const SizedBox(width: DesignSystem.spaceSm),
                          _filterChip('Status', _statusFilter, ['All', 'Visited', 'Not Yet', 'Voided']),
                          const SizedBox(width: DesignSystem.spaceSm),
                          ElevatedButton.icon(
                            onPressed: () => _exportCsv(filteredAssignments, visits, projects),
                            icon: const Icon(Icons.file_download, size: 16),
                            label: const Text('Export CSV', style: TextStyle(fontSize: 12)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: DesignSystem.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusLg),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: DesignSystem.spaceLg),
            if (isDesktop)
              Row(
                children: tabs.map((tab) {
                  final active = _currentTab == tab;
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: ChoiceChip(
                      label: Text(tab, style: TextStyle(fontSize: 13, color: active ? Colors.white : DesignSystem.onSurfaceVariant)),
                      selected: active,
                      onSelected: (_) => setState(() => _currentTab = tab),
                      selectedColor: DesignSystem.primary,
                    ),
                  );
                }).toList(),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: tabs.map((tab) {
                    final active = _currentTab == tab;
                    return Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: ChoiceChip(
                        label: Text(tab, style: TextStyle(fontSize: 12, color: active ? Colors.white : DesignSystem.onSurfaceVariant)),
                        selected: active,
                        onSelected: (_) => setState(() => _currentTab = tab),
                        selectedColor: DesignSystem.primary,
                      ),
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: DesignSystem.spaceMd),
            _buildTabContent(_currentTab, filteredAssignments, visits, projects),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(
    String tab,
    List<ProjectLecturerAssignment> filtered,
    List<StudentVisit> visits,
    List<Project> projects,
  ) {
    switch (tab) {
      case 'Overview':
        return VisitDataTable(
          assignments: filtered,
          visits: visits,
          projects: projects,
          formatVisitTime: _formatVisitTime,
          onVoid: _voidVisit,
        );
      case 'By Lecturer':
        final grouped = <String, List<ProjectLecturerAssignment>>{};
        for (final a in filtered) {
          grouped.putIfAbsent(a.lecturerDisplayName, () => []);
          grouped[a.lecturerDisplayName]!.add(a);
        }
        return Column(
          children: grouped.entries.map((e) {
            final lecturerVisits = visits.where((v) =>
              e.value.any((a) => a.projectId == v.projectId && a.role == v.visitRole)
            ).toList();
            final completedCount = lecturerVisits.where((v) => v.status == 'completed').length;
            return Card(
              margin: const EdgeInsets.only(bottom: DesignSystem.spaceSm),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: DesignSystem.primary,
                  child: Text(e.key[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                ),
                title: Text(e.key, style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.bold)),
                subtitle: Text('${e.value.length} assignments, $completedCount visited', style: DesignSystem.bodySm),
                trailing: Text('${completedCount}/${e.value.length}', style: DesignSystem.h3.copyWith(color: DesignSystem.primary)),
              ),
            );
          }).toList(),
        );
      case 'By Project':
        final grouped = <String, List<ProjectLecturerAssignment>>{};
        for (final a in filtered) {
          grouped.putIfAbsent(a.projectId, () => []);
          grouped[a.projectId]!.add(a);
        }
        return Column(
          children: grouped.entries.map((e) {
            final project = projects.where((p) => p.id == e.key).firstOrNull;
            final projectVisits = visits.where((v) => v.projectId == e.key).toList();
            final completedCount = projectVisits.where((v) => v.status == 'completed').length;
            return Card(
              margin: const EdgeInsets.only(bottom: DesignSystem.spaceSm),
              child: ListTile(
                title: Text(project?.title ?? e.key, style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.bold)),
                subtitle: Text('${e.value.length} lecturers, $completedCount visits', style: DesignSystem.bodySm),
                trailing: Text('$completedCount/${e.value.length}', style: DesignSystem.h3.copyWith(color: DesignSystem.primary)),
              ),
            );
          }).toList(),
        );
      case 'Visit Log':
        final sortedVisits = List<StudentVisit>.from(visits)
          ..sort((a, b) => b.visitedAt.compareTo(a.visitedAt));
        return Column(
          children: sortedVisits.map((v) {
            final project = projects.where((p) => p.id == v.projectId).firstOrNull;
            final assignment = filtered.where((a) => a.id == v.assignmentId).firstOrNull;
            final isCompleted = v.status == 'completed';
            final isVoided = v.status == 'voided';
            return Card(
              margin: const EdgeInsets.only(bottom: DesignSystem.spaceXs),
              child: ListTile(
                leading: Icon(
                  isCompleted ? Icons.check_circle : Icons.cancel,
                  color: isCompleted ? DesignSystem.onTertiaryContainer : DesignSystem.error,
                ),
                title: Text(
                  '${assignment?.lecturerDisplayName ?? '?'} - ${project?.title ?? '?'}',
                  style: DesignSystem.bodySm.copyWith(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${v.visitRole == 'supervisor' ? 'SV' : 'EX'} • ${_formatVisitTime(v)}${v.visitNote != null && v.visitNote!.isNotEmpty ? ' • ${v.visitNote}' : ''}${isVoided ? ' • Voided: ${v.voidReason}' : ''}',
                  style: DesignSystem.labelCaps.copyWith(color: DesignSystem.onSurfaceVariant, fontSize: 10),
                ),
                trailing: isCompleted
                    ? TextButton.icon(
                        onPressed: () => _voidVisit(v),
                        icon: const Icon(Icons.cancel_outlined, size: 14),
                        label: const Text('Void', style: TextStyle(fontSize: 11)),
                        style: TextButton.styleFrom(foregroundColor: DesignSystem.error, padding: EdgeInsets.zero),
                      )
                    : null,
              ),
            );
          }).toList(),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _filterChip(String label, String current, List<String> options) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: ', style: DesignSystem.labelCaps.copyWith(color: DesignSystem.onSurfaceVariant)),
        ...options.map((opt) {
          final selected = current == opt;
          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: ChoiceChip(
              label: Text(opt, style: TextStyle(fontSize: 11, color: selected ? Colors.white : DesignSystem.onSurfaceVariant)),
              selected: selected,
              onSelected: (_) => setState(() {
                if (label == 'Role') _roleFilter = opt;
                else _statusFilter = opt;
              }),
              selectedColor: DesignSystem.primary,
              visualDensity: VisualDensity.compact,
            ),
          );
        }),
      ],
    );
  }

  String _formatVisitTime(StudentVisit v) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dt = v.visitedAt;
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
