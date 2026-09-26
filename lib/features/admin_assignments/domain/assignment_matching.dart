import '../../../core/domain/models/project.dart';
import '../../../core/domain/models/project_lecturer_assignment.dart';

/// An active lecturer account that can be assigned to projects.
class LecturerRef {
  const LecturerRef({required this.id, required this.name, this.email});

  /// From a `profiles` row (snake or camel keys); null when inactive or
  /// unusable (no id / name).
  static LecturerRef? fromRow(Map<String, dynamic> m) {
    final id = m['id'] as String?;
    final name = (m['display_name'] ?? m['displayName']) as String?;
    final active = (m['is_active'] ?? m['isActive']) as bool? ?? true;
    if (id == null || name == null || name.trim().isEmpty || !active) return null;
    return LecturerRef(id: id, name: name.trim(), email: m['email'] as String?);
  }

  final String id;
  final String name;
  final String? email;
}

/// An assignment the admin can create in bulk.
class ProposedAssignment {
  const ProposedAssignment({required this.project, required this.lecturer, required this.role});

  final Project project;
  final LecturerRef lecturer;

  /// supervisor | examiner
  final String role;
}

class MatchResult {
  const MatchResult({required this.proposals, required this.unmatchedNames, required this.ambiguousNames});

  final List<ProposedAssignment> proposals;

  /// Names on projects with no lecturer account (normalised).
  final Set<String> unmatchedNames;

  /// Names shared by more than one lecturer account — never auto-assigned.
  final Set<String> ambiguousNames;
}

const _honorifics = {
  'DR', 'PROF', 'PROFESSOR', 'MADYA', 'ASSOC', 'ASSOCIATE', 'PM', 'TS', 'IR', 'EN', 'PN', 'CIK', 'ENCIK', 'PUAN',
  'SR', 'HJ', 'HAJI', 'HJH', 'HAJAH', 'DATO', "DATO'", 'DATUK', 'MR', 'MRS', 'MS',
};

/// "Dr. Aminah  binti Ali" → "AMINAH BINTI ALI": upper-case, punctuation
/// and titles removed, single spaces — so the project's free-text lecturer
/// name can meet the account's display name.
String normalizePersonName(String raw) {
  final words = raw
      .toUpperCase()
      .replaceAll(RegExp(r"[.,()\[\]]"), ' ')
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty && !_honorifics.contains(w))
      .toList();
  return words.join(' ');
}

/// Proposes an assignment wherever a project's supervisor / examiner name
/// matches exactly one active lecturer, skipping ones that already exist
/// (active) for that project, lecturer and role.
MatchResult proposeAssignments({
  required List<Project> projects,
  required List<LecturerRef> lecturers,
  required List<ProjectLecturerAssignment> existing,
}) {
  final byName = <String, List<LecturerRef>>{};
  for (final l in lecturers) {
    byName.putIfAbsent(normalizePersonName(l.name), () => []).add(l);
  }
  final taken = {
    for (final a in existing)
      if (a.status == 'active' && a.lecturerId != null) '${a.projectId}|${a.lecturerId}|${a.role}',
  };
  final proposals = <ProposedAssignment>[];
  final unmatched = <String>{};
  final ambiguous = <String>{};
  for (final p in projects) {
    for (final (role, name) in [('supervisor', p.supervisorDisplayName), ('examiner', p.examinerDisplayName ?? '')]) {
      final key = normalizePersonName(name);
      if (key.isEmpty) continue;
      final hits = byName[key];
      if (hits == null) {
        unmatched.add(key);
      } else if (hits.length > 1) {
        ambiguous.add(key);
      } else if (!taken.contains('${p.id}|${hits.single.id}|$role')) {
        proposals.add(ProposedAssignment(project: p, lecturer: hits.single, role: role));
      }
    }
  }
  return MatchResult(proposals: proposals, unmatchedNames: unmatched, ambiguousNames: ambiguous);
}

/// A `lecturer_assignments` row (active) for [eventId] (the event's uuid).
Map<String, dynamic> assignmentRow({
  required String eventId,
  required String projectId,
  required LecturerRef lecturer,
  required String role,
  String? assignedBy,
}) {
  final now = DateTime.now().toUtc().toIso8601String();
  return {
    'event_id': eventId,
    'project_id': projectId,
    'lecturer_id': lecturer.id,
    'lecturer_display_name': lecturer.name,
    'lecturer_email': ?lecturer.email,
    'role': role,
    'status': 'active',
    'assigned_by': ?assignedBy,
    'assigned_at': now,
    'updated_at': now,
  };
}
