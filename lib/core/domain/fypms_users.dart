/// A person as listed on the Users & Roles screen (`admin_list_users`).
class ManagedUser {
  const ManagedUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    required this.isActive,
    required this.roles,
    this.matricId,
  });

  factory ManagedUser.fromJson(Map<String, dynamic> m) => ManagedUser(
        id: m['id'] as String? ?? '',
        email: m['email'] as String? ?? '',
        displayName: m['display_name'] as String? ?? '',
        role: m['role'] as String? ?? 'student',
        isActive: m['is_active'] as bool? ?? true,
        matricId: m['matric_id'] as String?,
        roles: [
          for (final r in (m['roles'] as List? ?? const []))
            (
              (r as Map)['role_code'] as String? ?? '',
              r['programme_code'] as String? ?? '',
            ),
        ],
      );

  final String id;
  final String email;
  final String displayName;

  /// Account type: admin | lecturer | student.
  final String role;
  final bool isActive;
  final String? matricId;

  /// Active FYPMS roles as (role code, programme code; '' = all programmes).
  final List<(String, String)> roles;
}

/// FYPMS role codes with their labels, in display order.
const kAcademicRoleLabels = {
  'student': 'Student',
  'supervisor': 'Supervisor',
  'co_supervisor': 'Co-supervisor',
  'examiner': 'Examiner',
  'csp600_lecturer': 'CSP600 lecturer',
  'csp650_lecturer': 'CSP650 lecturer',
  'fyp_coordinator': 'FYP coordinator',
  'programme_head': 'PU head',
};

/// One student line in a bulk enrolment.
class EnrolmentRow {
  const EnrolmentRow({required this.email, required this.name, required this.programmeCode, this.matricId});

  final String email;
  final String name;
  final String programmeCode;
  final String? matricId;

  Map<String, dynamic> toJson() => {
        'email': email,
        'name': name,
        'programme_code': programmeCode,
        'matric_id': ?matricId,
      };
}

/// Parses pasted or uploaded CSV — `email, name, matric, programme` per
/// line (a header line is skipped) — into rows and per-line problems.
/// Duplicate emails in the list are reported once and kept once.
(List<EnrolmentRow>, List<String>) parseEnrolmentCsv(String text) {
  final rows = <EnrolmentRow>[];
  final problems = <String>[];
  final seen = <String>{};
  final email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  final lines = text.split(RegExp(r'\r?\n'));
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i].trim();
    if (line.isEmpty) continue;
    final cells = [for (final c in line.split(RegExp(r'[,;\t]'))) c.trim().replaceAll(RegExp(r'^"|"$'), '')];
    if (i == 0 && cells.first.toLowerCase().contains('email')) continue;
    final n = i + 1;
    if (cells.length < 4) {
      problems.add('Line $n: expected email, name, matric, programme.');
      continue;
    }
    final e = cells[0].toLowerCase();
    if (!email.hasMatch(e)) {
      problems.add('Line $n: "${cells[0]}" is not an email.');
      continue;
    }
    if (cells[1].isEmpty || cells[3].isEmpty) {
      problems.add('Line $n: name and programme are required.');
      continue;
    }
    if (!seen.add(e)) {
      problems.add('Line $n: $e is listed twice.');
      continue;
    }
    rows.add(EnrolmentRow(
      email: e,
      name: cells[1],
      matricId: cells[2].isEmpty ? null : cells[2],
      programmeCode: cells[3].toUpperCase(),
    ));
  }
  return (rows, problems);
}
