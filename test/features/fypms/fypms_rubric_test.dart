import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/domain/fypms_rubric.dart';

/// Same numbers the server returned in the migration checks, so the dialog's
/// live total and the stored percentage agree.
void main() {
  final f8 = [
    for (final m in const [
      {'key': 'background_problem', 'weight': 3, 'max': 10},
      {'key': 'objectives', 'weight': 2, 'max': 10},
      {'key': 'significance', 'weight': 1, 'max': 10},
      {'key': 'literature_review', 'weight': 5, 'max': 10},
      {'key': 'methodology', 'weight': 6, 'max': 10},
      {'key': 'report_presentation', 'weight': 3, 'max': 10},
      {'key': 'progress_evaluation', 'weight': 2, 'max': 10, 'supervisor_only': true},
    ])
      RubricCriterion.fromMap(m),
  ];

  test('supervisor scoring F8 at 8 on every criterion is 80%', () {
    final criteria = criteriaFor(f8, 'supervisor');
    final scores = {for (final c in criteria) c.key: 8};
    expect(rubricMarks(criteria, scores), (earned: 176, possible: 220));
    expect(rubricPercentage(criteria, scores), 80);
  });

  test('examiner scoring F8 leaves out the supervisor-only criterion', () {
    final criteria = criteriaFor(f8, 'examiner');
    expect(criteria.map((c) => c.key), isNot(contains('progress_evaluation')));
    expect(rubricPercentage(criteria, {for (final c in criteria) c.key: 5}), 50);
  });

  test('F3 lecturer example: 10 / 5 / 5 on weights 2 / 4 / 4 is 60%', () {
    const f3 = [
      RubricCriterion(key: 'relevance_context', label: 'Relevance', weight: 2),
      RubricCriterion(key: 'knowledge_of_field', label: 'Knowledge', weight: 4),
      RubricCriterion(key: 'writing', label: 'Writing', weight: 4),
    ];
    expect(rubricPercentage(f3, {'relevance_context': 10, 'knowledge_of_field': 5, 'writing': 5}), 60);
  });

  test('textbook bands', () {
    expect([10, 8, 7, 6, 5, 4, 1, 0].map(rubricBand), [
      'Excellent', 'Excellent', 'Good', 'Good', 'Satisfactory', 'Poor', 'Poor', 'No evidence',
    ]);
  });
}
