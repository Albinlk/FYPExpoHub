import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/fypms_users.dart';
import '../../../../core/domain/models/fypms/academic_semester.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../../../../core/widgets/admin_actions.dart';

/// Enrol Students (backlog U3, S4): paste or upload a class list
/// (`email, name, matric, programme` per line) for a semester and course.
/// Missing logins are created (students set their password with "Forgot
/// password?" on first sign-in) and each gets their FYP record.
class CoordinatorEnrolPage extends ConsumerStatefulWidget {
  const CoordinatorEnrolPage({super.key});

  @override
  ConsumerState<CoordinatorEnrolPage> createState() => _CoordinatorEnrolPageState();
}

class _CoordinatorEnrolPageState extends ConsumerState<CoordinatorEnrolPage> {
  final _text = TextEditingController();
  String? _semesterId;
  String _course = 'CSP600';
  bool _busy = false;
  List<Map<String, dynamic>>? _results;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final f = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['csv', 'txt'], withData: true);
    final bytes = f?.files.firstOrNull?.bytes;
    if (bytes != null) setState(() => _text.text = utf8.decode(bytes, allowMalformed: true));
  }

  Future<void> _enrol(List<EnrolmentRow> rows) async {
    setState(() {
      _busy = true;
      _results = null;
    });
    try {
      final results = await ref.read(userAdminProvider).enrol(_semesterId!, _course, rows);
      if (mounted) setState(() => _results = results);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Enrolment failed: ${friendlyError(e)}')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final semesters = [
      for (final s in ref.watch(fypmsSemestersProvider).value ?? const <AcademicSemester>[])
        if (s.status == 'planned' || s.status == 'active') s,
    ];
    _semesterId ??= activeSemesterOf(semesters)?.id ?? semesters.firstOrNull?.id;
    final (rows, problems) = parseEnrolmentCsv(_text.text);
    final results = _results;
    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        backgroundColor: DesignSystem.primary,
        title: Text('Enrol Students', style: DesignSystem.h3.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(DesignSystem.gutter),
        children: [
          Wrap(
            spacing: DesignSystem.spaceMd,
            runSpacing: DesignSystem.spaceSm,
            children: [
              SizedBox(
                width: 260,
                child: DropdownButtonFormField<String>(
                  key: const Key('enrol-semester'),
                  initialValue: semesters.any((s) => s.id == _semesterId) ? _semesterId : null,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Semester'),
                  items: [for (final s in semesters) DropdownMenuItem(value: s.id, child: Text('${s.code} — ${s.label}'))],
                  onChanged: (v) => setState(() => _semesterId = v),
                ),
              ),
              SizedBox(
                width: 160,
                child: DropdownButtonFormField<String>(
                  initialValue: _course,
                  decoration: const InputDecoration(labelText: 'Course'),
                  items: const [
                    DropdownMenuItem(value: 'CSP600', child: Text('CSP600')),
                    DropdownMenuItem(value: 'CSP650', child: Text('CSP650')),
                  ],
                  onChanged: (v) => setState(() => _course = v ?? 'CSP600'),
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignSystem.spaceMd),
          Text(
            'One student per line: email, name, matric, programme (e.g. aina@student.uitm.edu.my, Nur Aina, 2027123456, CS266). '
            'New students set their password with "Forgot password?" on the sign-in page.',
            style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
          ),
          TextField(
            key: const Key('enrol-text'),
            controller: _text,
            onChanged: (_) => setState(() {}),
            minLines: 6,
            maxLines: 14,
            decoration: const InputDecoration(hintText: 'email, name, matric, programme'),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(onPressed: _pickFile, icon: const Icon(Icons.upload_file), label: const Text('Load a CSV file')),
          ),
          Text('${rows.length} students ready', key: const Key('enrol-count'), style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.w600)),
          for (final p in problems) Text(p, style: DesignSystem.bodySm.copyWith(color: DesignSystem.error)),
          const SizedBox(height: DesignSystem.spaceSm),
          FilledButton.icon(
            key: const Key('enrol-submit'),
            onPressed: _busy || rows.isEmpty || _semesterId == null ? null : () => _enrol(rows),
            icon: _busy
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.group_add),
            label: Text('Enrol ${rows.length} students'),
          ),
          if (results != null) ...[
            const Divider(height: 32),
            Text(
              '${results.where((r) => r['status'] == 'enrolled').length} enrolled · '
              '${results.where((r) => r['status'] == 'already_enrolled').length} already enrolled · '
              '${results.where((r) => r['status'] == 'error').length} failed',
              key: const Key('enrol-summary'),
              style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.w600),
            ),
            for (final r in results)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  r['status'] == 'error' ? Icons.error_outline : Icons.check_circle_outline,
                  color: r['status'] == 'error' ? DesignSystem.error : DesignSystem.secondary,
                ),
                title: Text('${r['email']}'),
                subtitle: Text(switch (r['status']) {
                  'enrolled' => r['account_created'] == true ? 'Enrolled · new account' : 'Enrolled',
                  'already_enrolled' => 'Already enrolled',
                  _ => '${r['message'] ?? 'Failed'}',
                }),
              ),
          ],
        ],
      ),
    );
  }
}
