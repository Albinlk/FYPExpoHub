import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../../../../core/supabase/supabase_client_provider.dart';
import '../../../../core/utils/download_util.dart';
import '../../../../core/utils/fypms_format.dart';
import '../../../../core/widgets/async_state.dart';

/// One lecturer's active assignments in the report.
class WorkloadRow {
  const WorkloadRow({required this.name, required this.supervisor, required this.coSupervisor, required this.examiner});

  factory WorkloadRow.fromJson(Map<String, dynamic> m) => WorkloadRow(
        name: m['name'] as String? ?? 'Unknown',
        supervisor: (m['supervisor'] as num?)?.toInt() ?? 0,
        coSupervisor: (m['co_supervisor'] as num?)?.toInt() ?? 0,
        examiner: (m['examiner'] as num?)?.toInt() ?? 0,
      );

  final String name;
  final int supervisor;
  final int coSupervisor;
  final int examiner;

  int get total => supervisor + coSupervisor + examiner;
}

/// `fyp_cohort_report` (backlog F6).
class CohortReport {
  const CohortReport({
    required this.records,
    required this.statusCounts,
    required this.courseCounts,
    required this.grades,
    required this.finalized,
    required this.workload,
    required this.withoutSupervisor,
    required this.overdueMilestones,
  });

  factory CohortReport.fromJson(Map<String, dynamic> m) {
    Map<String, int> counts(Object? v) => {
          for (final e in ((v as Map?) ?? const {}).entries) '${e.key}': (e.value as num).toInt(),
        };
    final grades = <String, Map<String, int>>{};
    for (final g in (m['grades'] as List?) ?? const []) {
      final row = Map<String, dynamic>.from(g as Map);
      grades.putIfAbsent(row['course_code'] as String, () => {})[row['grade'] as String] = (row['count'] as num).toInt();
    }
    return CohortReport(
      records: (m['records'] as num?)?.toInt() ?? 0,
      statusCounts: counts(m['status_counts']),
      courseCounts: counts(m['course_counts']),
      grades: grades,
      finalized: {
        for (final e in ((m['finalized'] as Map?) ?? const {}).entries)
          '${e.key}': (
            count: ((e.value as Map)['count'] as num).toInt(),
            average: ((e.value as Map)['average_total'] as num?)?.toDouble(),
          ),
      },
      workload: [for (final w in (m['workload'] as List?) ?? const []) WorkloadRow.fromJson(Map<String, dynamic>.from(w as Map))],
      withoutSupervisor: (m['without_supervisor'] as num?)?.toInt() ?? 0,
      overdueMilestones: (m['overdue_milestones'] as num?)?.toInt() ?? 0,
    );
  }

  final int records;
  final Map<String, int> statusCounts;
  final Map<String, int> courseCounts;

  /// course → grade → count (finalized marks only).
  final Map<String, Map<String, int>> grades;
  final Map<String, ({int count, double? average})> finalized;
  final List<WorkloadRow> workload;
  final int withoutSupervisor;
  final int overdueMilestones;

  String workloadCsv() {
    String q(String s) => '"${s.replaceAll('"', '""')}"';
    return [
      'Lecturer,Supervisor,Co-supervisor,Examiner,Total',
      for (final w in workload) '${q(w.name)},${w.supervisor},${w.coSupervisor},${w.examiner},${w.total}',
    ].join('\n');
  }
}

/// UiTM grade order for the distribution.
const kGradeOrder = ['A+', 'A', 'A-', 'B+', 'B', 'B-', 'C+', 'C', 'C-', 'D+', 'D', 'E', 'F'];

final fypCohortReportProvider = FutureProvider<CohortReport>((ref) async {
  final semesterId = ref.watch(fypmsEffectiveSemesterIdProvider);
  final res = await ref.read(supabaseClientProvider).rpc<dynamic>('fyp_cohort_report', params: {'p_semester_id': semesterId});
  return CohortReport.fromJson(Map<String, dynamic>.from(res as Map));
});

class CoordinatorReportsPage extends ConsumerWidget {
  const CoordinatorReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(fypCohortReportProvider);
    return Scaffold(
      backgroundColor: DesignSystem.background,
      body: report.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AsyncErrorView(error: e, onRetry: () => ref.invalidate(fypCohortReportProvider), what: 'the report'),
        data: (r) => ListView(
          padding: const EdgeInsets.all(DesignSystem.gutter),
          children: [
            Row(
              children: [
                Expanded(child: Text('Cohort Reports', style: DesignSystem.h2)),
                IconButton(
                  tooltip: 'Refresh',
                  icon: const Icon(Icons.refresh),
                  onPressed: () => ref.invalidate(fypCohortReportProvider),
                ),
              ],
            ),
            Text('Follows the semester chosen in the top bar.', style: DesignSystem.bodySm),
            const SizedBox(height: DesignSystem.spaceMd),
            Wrap(
              spacing: DesignSystem.spaceMd,
              runSpacing: DesignSystem.spaceMd,
              children: [
                _Stat('Records', '${r.records}'),
                for (final e in r.courseCounts.entries) _Stat(e.key, '${e.value}'),
                _Stat('No supervisor yet', '${r.withoutSupervisor}', warn: r.withoutSupervisor > 0),
                _Stat('Overdue milestones', '${r.overdueMilestones}', warn: r.overdueMilestones > 0),
              ],
            ),
            const SizedBox(height: DesignSystem.spaceLg),
            _Section(
              title: 'Progress by status',
              child: _Bars({for (final e in r.statusCounts.entries) fypStatusLabel(e.key): e.value}),
            ),
            _Section(
              title: 'Grade distribution (finalized marks)',
              child: r.grades.isEmpty
                  ? const Text('No finalized marks yet.')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final course in r.grades.keys.toList()..sort()) ...[
                          Text(
                            '$course — ${r.finalized[course]?.count ?? 0} finalized'
                            '${r.finalized[course]?.average == null ? '' : ', average ${r.finalized[course]!.average!.toStringAsFixed(1)}%'}',
                            style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          _Bars({
                            for (final g in [
                              ...kGradeOrder.where(r.grades[course]!.containsKey),
                              ...r.grades[course]!.keys.where((g) => !kGradeOrder.contains(g)),
                            ])
                              g: r.grades[course]![g]!,
                          }),
                          const SizedBox(height: DesignSystem.spaceMd),
                        ],
                      ],
                    ),
            ),
            _Section(
              title: 'Supervisor workload',
              trailing: TextButton.icon(
                onPressed: r.workload.isEmpty ? null : () => downloadTextFileWeb('supervisor_workload.csv', r.workloadCsv()),
                icon: const Icon(Icons.download),
                label: const Text('CSV'),
              ),
              child: r.workload.isEmpty
                  ? const Text('No active assignments.')
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Lecturer')),
                          DataColumn(label: Text('Supervisor'), numeric: true),
                          DataColumn(label: Text('Co-supervisor'), numeric: true),
                          DataColumn(label: Text('Examiner'), numeric: true),
                          DataColumn(label: Text('Total'), numeric: true),
                        ],
                        rows: [
                          for (final w in r.workload)
                            DataRow(cells: [
                              DataCell(Text(w.name)),
                              DataCell(Text('${w.supervisor}')),
                              DataCell(Text('${w.coSupervisor}')),
                              DataCell(Text('${w.examiner}')),
                              DataCell(Text('${w.total}', style: const TextStyle(fontWeight: FontWeight.w600))),
                            ]),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, {this.warn = false});

  final String label;
  final String value;
  final bool warn;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: DesignSystem.h2.copyWith(color: warn ? DesignSystem.error : DesignSystem.primary)),
              Text(label, style: DesignSystem.bodySm),
            ],
          ),
        ),
      );
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: DesignSystem.spaceMd),
        child: Padding(
          padding: const EdgeInsets.all(DesignSystem.spaceMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [Expanded(child: Text(title, style: DesignSystem.h3)), ?trailing]),
              const SizedBox(height: DesignSystem.spaceSm),
              child,
            ],
          ),
        ),
      );
}

/// Horizontal bars, longest = full width.
class _Bars extends StatelessWidget {
  const _Bars(this.values);

  final Map<String, int> values;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return const Text('Nothing to show.');
    final max = values.values.fold<int>(1, (a, b) => b > a ? b : a);
    return Column(
      children: [
        for (final e in values.entries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                SizedBox(width: 190, child: Text(e.key, style: DesignSystem.bodySm, overflow: TextOverflow.ellipsis)),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: e.value / max,
                      minHeight: 14,
                      backgroundColor: DesignSystem.surfaceContainerLowest,
                    ),
                  ),
                ),
                SizedBox(width: 44, child: Text('${e.value}', textAlign: TextAlign.right)),
              ],
            ),
          ),
      ],
    );
  }
}
