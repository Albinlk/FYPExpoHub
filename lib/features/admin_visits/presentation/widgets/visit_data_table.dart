import 'package:flutter/material.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/project.dart';
import '../../../../core/domain/models/project_lecturer_assignment.dart';
import '../../../../core/domain/models/student_visit.dart';

class VisitDataTable extends StatelessWidget {
  final List<ProjectLecturerAssignment> assignments;
  final List<StudentVisit> visits;
  final Map<String, Project> projects;
  final String Function(StudentVisit v) formatVisitTime;
  final void Function(StudentVisit visit) onVoid;

  const VisitDataTable({
    super.key,
    required this.assignments,
    required this.visits,
    required this.projects,
    required this.formatVisitTime,
    required this.onVoid,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    if (isDesktop) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 24,
          headingRowColor: WidgetStatePropertyAll(DesignSystem.surfaceContainerLow),
          columns: const [
            DataColumn(label: Text('Lecturer', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Role', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Student', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Project', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Booth', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Time', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: assignments.map((a) {
            final project = projects[a.projectId];
            final visit = visits.where((v) => v.projectId == a.projectId && v.visitRole == a.role).firstOrNull;
            final isCompleted = visit != null && visit.status == 'completed';
            final isVoided = visit != null && visit.status == 'voided';
            return DataRow(cells: [
              DataCell(Text(a.lecturerDisplayName, style: DesignSystem.bodySm)),
              DataCell(_roleChip(a.role)),
              DataCell(Text(project?.teamDisplayNames.join(', ') ?? '-', style: DesignSystem.bodySm, overflow: TextOverflow.ellipsis)),
              DataCell(Text(project?.title ?? '-', style: DesignSystem.bodySm, overflow: TextOverflow.ellipsis)),
              DataCell(Text(project?.boothNumber ?? '-', style: DesignSystem.bodySm)),
              DataCell(_statusChip(isCompleted, isVoided)),
              DataCell(Text(visit != null ? formatVisitTime(visit) : '-', style: DesignSystem.bodySm)),
              DataCell(_buildActions(visit, isCompleted, isVoided)),
            ]);
          }).toList(),
        ),
      );
    }

    return Column(
      children: assignments.map((a) {
        final project = projects[a.projectId];
        final visit = visits.where((v) => v.projectId == a.projectId && v.visitRole == a.role).firstOrNull;
        final isCompleted = visit != null && visit.status == 'completed';
        final isVoided = visit != null && visit.status == 'voided';
        return Card(
          margin: const EdgeInsets.only(bottom: DesignSystem.spaceSm),
          child: Padding(
            padding: const EdgeInsets.all(DesignSystem.spaceSm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(a.lecturerDisplayName, style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    _roleChip(a.role),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Project: ${project?.title ?? '-'}', style: DesignSystem.bodySm),
                Text('Student: ${project?.teamDisplayNames.join(', ') ?? '-'}', style: DesignSystem.bodySm),
                Row(
                  children: [
                    Text('Booth: ${project?.boothNumber ?? '-'}', style: DesignSystem.bodySm),
                    const Spacer(),
                    _statusChip(isCompleted, isVoided),
                  ],
                ),
                if (visit != null && isCompleted) ...[
                  const SizedBox(height: 4),
                  Text('Time: ${formatVisitTime(visit)}', style: DesignSystem.bodySm),
                ],
                if (visit != null) _buildActions(visit, isCompleted, isVoided),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _roleChip(String role) {
    final isSv = role == 'supervisor';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isSv ? DesignSystem.primary.withOpacity(0.1) : DesignSystem.tertiary.withOpacity(0.1),
        borderRadius: DesignSystem.radiusSm,
      ),
      child: Text(isSv ? 'SV' : 'EX', style: DesignSystem.labelCaps.copyWith(
        color: isSv ? DesignSystem.primary : DesignSystem.tertiary,
        fontSize: 10,
      )),
    );
  }

  Widget _statusChip(bool isCompleted, bool isVoided) {
    if (isVoided) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(color: DesignSystem.errorContainer, borderRadius: DesignSystem.radiusSm),
        child: Text('Voided', style: DesignSystem.labelCaps.copyWith(color: DesignSystem.onErrorContainer, fontSize: 10)),
      );
    }
    if (isCompleted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(color: DesignSystem.tertiaryContainer.withOpacity(0.2), borderRadius: DesignSystem.radiusSm),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 10, color: DesignSystem.onTertiaryContainer),
            const SizedBox(width: 3),
            Text('Visited', style: DesignSystem.labelCaps.copyWith(color: DesignSystem.onTertiaryContainer, fontSize: 10)),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: DesignSystem.surfaceContainerHighest, borderRadius: DesignSystem.radiusSm),
      child: Text('Not Yet', style: DesignSystem.labelCaps.copyWith(color: DesignSystem.onSurfaceVariant, fontSize: 10)),
    );
  }

  Widget _buildActions(StudentVisit? visit, bool isCompleted, bool isVoided) {
    if (isCompleted && visit != null) {
      return TextButton.icon(
        onPressed: () => onVoid(visit),
        icon: const Icon(Icons.cancel_outlined, size: 14),
        label: Text('Void', style: DesignSystem.labelCaps.copyWith(color: DesignSystem.error, fontSize: 10)),
        style: TextButton.styleFrom(foregroundColor: DesignSystem.error, padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
      );
    }
    return const SizedBox.shrink();
  }
}

String exportVisitsCsv(
  List<ProjectLecturerAssignment> assignments,
  List<StudentVisit> visits,
  Map<String, Project> projects,
) {
  final buffer = StringBuffer();
  buffer.writeln('Lecturer,Role,Student,Project,Programme,Booth,Status,Visit Time,Note');

  for (final a in assignments) {
    final project = projects[a.projectId];
    final visit = visits.where((v) => v.projectId == a.projectId && v.visitRole == a.role).firstOrNull;
    final status = visit != null ? (visit.status == 'completed' ? 'Visited' : 'Voided') : 'Not Yet';
    final timeStr = visit != null ? visit.visitedAt.toIso8601String() : '';
    final note = visit?.visitNote ?? '';

    buffer.writeln([
      _escapeCsv(a.lecturerDisplayName),
      a.role == 'supervisor' ? 'SV' : 'EX',
      _escapeCsv(project?.teamDisplayNames.join('; ') ?? ''),
      _escapeCsv(project?.title ?? ''),
      _escapeCsv(project?.programmeCode ?? ''),
      project?.boothNumber ?? '',
      status,
      timeStr,
      _escapeCsv(note),
    ].join(','));
  }

  return buffer.toString();
}

String _escapeCsv(String value) {
  if (value.contains(',') || value.contains('"') || value.contains('\n')) {
    return '"${value.replaceAll('"', '""')}"';
  }
  return value;
}
