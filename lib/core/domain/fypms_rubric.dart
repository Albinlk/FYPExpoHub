/// Rubric scoring from the FSKM FYP Text Book (4th ed.): each criterion is
/// scored 0–10 and Marks = Weight × Score. Mirrors the server's
/// `submit_form_evaluation`, which stores the form percentage.
class RubricCriterion {
  const RubricCriterion({
    required this.key,
    required this.label,
    required this.weight,
    this.max = 10,
    this.supervisorOnly = false,
    this.clo,
  });

  factory RubricCriterion.fromMap(Map<String, dynamic> m) => RubricCriterion(
        key: m['key'] as String,
        label: (m['label'] as String?) ?? (m['key'] as String),
        weight: (m['weight'] as num?)?.toInt() ?? 0,
        max: (m['max'] as num?)?.toInt() ?? 10,
        supervisorOnly: (m['supervisor_only'] as bool?) ?? false,
        clo: m['clo'] as String?,
      );

  final String key;
  final String label;
  final int weight;
  final int max;

  /// Scored by the supervisor only (e.g. F8/F11 progress evaluation).
  final bool supervisorOnly;

  /// Course learning outcome group (F11/F16: CLO1 or CLO4).
  final String? clo;
}

/// The criteria [role] scores: supervisor-only ones are left out for
/// everyone but the supervisor.
List<RubricCriterion> criteriaFor(List<RubricCriterion> all, String role) =>
    [for (final c in all) if (!c.supervisorOnly || role == 'supervisor') c];

/// Textbook score band for a 0–10 score.
String rubricBand(int score) {
  if (score >= 8) return 'Excellent';
  if (score >= 6) return 'Good';
  if (score == 5) return 'Satisfactory';
  if (score >= 1) return 'Poor';
  return 'No evidence';
}

/// Marks earned and possible (Σ W×S and Σ W×max) over [criteria].
({int earned, int possible}) rubricMarks(List<RubricCriterion> criteria, Map<String, int> scores) {
  var earned = 0;
  var possible = 0;
  for (final c in criteria) {
    earned += (scores[c.key] ?? 0) * c.weight;
    possible += c.max * c.weight;
  }
  return (earned: earned, possible: possible);
}

/// The form percentage the server stores: 100 × Σ(W×S) ÷ Σ(W×max).
double rubricPercentage(List<RubricCriterion> criteria, Map<String, int> scores) {
  final m = rubricMarks(criteria, scores);
  return m.possible == 0 ? 0 : 100 * m.earned / m.possible;
}
