import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/fypms/academic_course.dart';
import '../../../../core/domain/models/fypms/academic_semester.dart';
import '../../../../core/domain/models/fypms/fyp_course_offering.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../../../../core/utils/fypms_format.dart';
import '../../../../core/widgets/async_state.dart';
import '../../../../core/widgets/admin_actions.dart';

/// Coordinator: semesters (planned -> active -> completed -> archived; one
/// active), who teaches CSP600 / CSP650 in each, and the course details
/// (backlog S1, S5). Past semesters are kept, never deleted.
class CoordinatorSemestersPage extends ConsumerStatefulWidget {
  const CoordinatorSemestersPage({super.key});

  @override
  ConsumerState<CoordinatorSemestersPage> createState() => _CoordinatorSemestersPageState();
}

class _CoordinatorSemestersPageState extends ConsumerState<CoordinatorSemestersPage> {
  Future<void> _run(Future<void> Function() action, String success) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
      messenger.showSnackBar(SnackBar(content: Text(success)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Failed: ${friendlyError(e)}')));
    }
  }

  static const _next = {
    'planned': [('active', 'Make active')],
    'active': [('completed', 'Complete')],
    'completed': [('active', 'Re-open'), ('archived', 'Archive')],
    'archived': [('completed', 'Unarchive')],
  };

  @override
  Widget build(BuildContext context) {
    final semesters = ref.watch(fypmsSemestersProvider);
    final offerings = ref.watch(fypmsOfferingsProvider).value ?? const <FypCourseOffering>[];
    final courses = ref.watch(fypmsCoursesProvider).value ?? const <AcademicCourse>[];
    final staff = ref.watch(fypStaffProvider(const ['csp600_lecturer', 'csp650_lecturer'])).value ?? const [];
    final staffNames = {
      for (final s in staff)
        if (s['id'] is String) s['id'] as String: (s['display_name'] as String? ?? s['email'] as String? ?? ''),
    };

    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        backgroundColor: DesignSystem.primary,
        title: Text('Semesters & Courses', style: DesignSystem.h3.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog<void>(context: context, builder: (_) => const _NewSemesterDialog()),
        icon: const Icon(Icons.add),
        label: const Text('New Semester'),
      ),
      body: semesters.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AsyncErrorView(error: e, onRetry: () => ref.invalidate(fypmsSemestersProvider), what: 'this page'),
        data: (list) {
          final sorted = [...list]..sort((a, b) => b.startDate.compareTo(a.startDate));
          return ListView(
            padding: const EdgeInsets.all(DesignSystem.gutter),
            children: [
              if (sorted.isEmpty) const Text('No semesters yet. Add the current one to begin.'),
              for (final s in sorted)
                Card(
                  margin: const EdgeInsets.only(bottom: DesignSystem.spaceSm),
                  child: Padding(
                    padding: const EdgeInsets.all(DesignSystem.spaceMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: DesignSystem.spaceSm,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text('${s.code} — ${s.label}', style: DesignSystem.bodyLg.copyWith(fontWeight: FontWeight.bold)),
                            _StatusChip(status: s.status),
                          ],
                        ),
                        Text('${formatFypDate(s.startDate)} – ${formatFypDate(s.endDate)}', style: DesignSystem.bodySm),
                        const SizedBox(height: DesignSystem.spaceXs),
                        for (final c in courses)
                          _OfferingRow(
                            semester: s,
                            course: c,
                            offering: offerings
                                .where((o) => o.academicSemesterId == s.id && o.courseCode == c.code)
                                .firstOrNull,
                            staffNames: staffNames,
                          ),
                        Wrap(
                          spacing: DesignSystem.spaceSm,
                          children: [
                            for (final (status, label) in _next[s.status] ?? const <(String, String)>[])
                              OutlinedButton(
                                key: Key('semester-${s.code}-$status'),
                                onPressed: () => _run(
                                  () => ref.read(semesterAdminProvider).setStatus(s.id, status),
                                  '${s.code} is now $status.',
                                ),
                                child: Text(label),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: DesignSystem.spaceLg),
              Text('Courses', style: DesignSystem.h3Mobile.copyWith(color: DesignSystem.primary)),
              for (final c in courses)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('${c.code} — ${c.name}'),
                  subtitle: Text('${c.creditHours} credit hours · ${c.isActive ? 'active' : 'inactive'}'),
                  trailing: IconButton(
                    tooltip: 'Edit course',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => showDialog<void>(context: context, builder: (_) => _CourseDialog(course: c)),
                  ),
                ),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final active = status == 'active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: active ? DesignSystem.secondaryContainer : DesignSystem.surfaceContainerHighest,
        borderRadius: DesignSystem.radiusSm,
      ),
      child: Text(
        status,
        style: DesignSystem.bodySm.copyWith(color: active ? DesignSystem.onSecondaryContainer : DesignSystem.onSurfaceVariant),
      ),
    );
  }
}

/// "CSP600: DR X (max 40)" with Edit, for one semester.
class _OfferingRow extends ConsumerWidget {
  const _OfferingRow({required this.semester, required this.course, required this.offering, required this.staffNames});

  final AcademicSemester semester;
  final AcademicCourse course;
  final FypCourseOffering? offering;
  final Map<String, String> staffNames;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final who = offering?.lecturerId == null ? 'no lecturer' : (staffNames[offering!.lecturerId] ?? 'lecturer');
    final editable = semester.status != 'archived';
    return Row(
      children: [
        Expanded(
          child: Text(
            '${course.code}: ${offering == null ? 'not offered' : who}'
            '${offering?.maxStudents == null ? '' : ' (max ${offering!.maxStudents})'}',
            style: DesignSystem.bodySm,
          ),
        ),
        if (editable)
          TextButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => _OfferingDialog(semester: semester, course: course, offering: offering, staffNames: staffNames),
            ),
            child: Text(offering == null ? 'Offer' : 'Edit'),
          ),
      ],
    );
  }
}

class _NewSemesterDialog extends ConsumerStatefulWidget {
  const _NewSemesterDialog();

  @override
  ConsumerState<_NewSemesterDialog> createState() => _NewSemesterDialogState();
}

class _NewSemesterDialogState extends ConsumerState<_NewSemesterDialog> {
  final _code = TextEditingController();
  final _label = TextEditingController();
  DateTime? _start;
  DateTime? _end;
  bool _busy = false;

  @override
  void dispose() {
    _code.dispose();
    _label.dispose();
    super.dispose();
  }

  Future<void> _pick(bool start) async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: (start ? _start : _end) ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (d != null) setState(() => start ? _start = d : _end = d);
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    try {
      await ref
          .read(semesterAdminProvider)
          .create(code: _code.text.trim(), label: _label.text.trim(), start: _start!, end: _end!);
      if (!mounted) return;
      final m = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      m.showSnackBar(const SnackBar(content: Text('Semester created (planned).')));
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: ${friendlyError(e)}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ready = _code.text.trim().isNotEmpty &&
        _label.text.trim().isNotEmpty &&
        _start != null &&
        _end != null &&
        !_end!.isBefore(_start!) &&
        !_busy;
    return AlertDialog(
      title: const Text('New Semester'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const Key('semester-code'),
              controller: _code,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(labelText: 'Code (e.g. 2027_1)'),
            ),
            TextField(
              key: const Key('semester-label'),
              controller: _label,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(labelText: 'Label (e.g. March – August 2027)'),
            ),
            const SizedBox(height: DesignSystem.spaceSm),
            Wrap(
              spacing: DesignSystem.spaceSm,
              children: [
                OutlinedButton(
                  key: const Key('semester-start'),
                  onPressed: () => _pick(true),
                  child: Text(_start == null ? 'Start date' : 'Starts ${formatFypDate(_start!)}'),
                ),
                OutlinedButton(
                  key: const Key('semester-end'),
                  onPressed: () => _pick(false),
                  child: Text(_end == null ? 'End date' : 'Ends ${formatFypDate(_end!)}'),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: ready ? _save : null, child: const Text('Create')),
      ],
    );
  }
}

class _OfferingDialog extends ConsumerStatefulWidget {
  const _OfferingDialog({required this.semester, required this.course, required this.offering, required this.staffNames});

  final AcademicSemester semester;
  final AcademicCourse course;
  final FypCourseOffering? offering;
  final Map<String, String> staffNames;

  @override
  ConsumerState<_OfferingDialog> createState() => _OfferingDialogState();
}

class _OfferingDialogState extends ConsumerState<_OfferingDialog> {
  late String? _lecturer = widget.staffNames.containsKey(widget.offering?.lecturerId) ? widget.offering!.lecturerId : null;
  late final _max = TextEditingController(text: widget.offering?.maxStudents?.toString() ?? '');

  @override
  void dispose() {
    _max.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    try {
      await ref.read(semesterAdminProvider).saveOffering(
            semesterId: widget.semester.id,
            courseCode: widget.course.code,
            lecturerId: _lecturer,
            maxStudents: int.tryParse(_max.text.trim()),
          );
      nav.pop();
      messenger.showSnackBar(SnackBar(content: Text('${widget.course.code} offering saved.')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Failed: ${friendlyError(e)}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.course.code} in ${widget.semester.code}'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String?>(
              initialValue: _lecturer,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Course lecturer'),
              items: [
                const DropdownMenuItem<String?>(value: null, child: Text('Not assigned yet')),
                for (final e in widget.staffNames.entries)
                  DropdownMenuItem<String?>(value: e.key, child: Text(e.value, overflow: TextOverflow.ellipsis)),
              ],
              onChanged: (v) => setState(() => _lecturer = v),
            ),
            TextField(
              controller: _max,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Maximum students (optional)'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}

class _CourseDialog extends ConsumerStatefulWidget {
  const _CourseDialog({required this.course});
  final AcademicCourse course;

  @override
  ConsumerState<_CourseDialog> createState() => _CourseDialogState();
}

class _CourseDialogState extends ConsumerState<_CourseDialog> {
  late final _name = TextEditingController(text: widget.course.name);
  late final _credits = TextEditingController(text: '${widget.course.creditHours}');
  late bool _active = widget.course.isActive;

  @override
  void dispose() {
    _name.dispose();
    _credits.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    try {
      await ref.read(semesterAdminProvider).updateCourse(
            code: widget.course.code,
            name: _name.text.trim(),
            creditHours: int.tryParse(_credits.text.trim()) ?? widget.course.creditHours,
            isActive: _active,
          );
      nav.pop();
      messenger.showSnackBar(const SnackBar(content: Text('Course saved.')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Failed: ${friendlyError(e)}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.course.code),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name')),
            TextField(
              controller: _credits,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Credit hours'),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _active,
              onChanged: (v) => setState(() => _active = v),
              title: const Text('Active'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
