/// F6(a)/F6(b) rules from the FSKM FYP Text Book (4th ed.): the report is
/// screened for plagiarism and the similarity index may not exceed 30 %.
const double kMaxSimilarityIndex = 30;

/// Why a typed similarity index can't be submitted, or null when it is fine.
String? similarityProblem(String raw) {
  final text = raw.trim().replaceAll('%', '').trim();
  if (text.isEmpty) return 'Enter the similarity index from the plagiarism report.';
  final value = double.tryParse(text);
  if (value == null || value < 0 || value > 100) return 'Enter a percentage between 0 and 100.';
  if (value > kMaxSimilarityIndex) {
    return 'Above the 30 % limit — revise the report before submitting.';
  }
  return null;
}

/// The typed similarity index as a number (after [similarityProblem] passes).
double parseSimilarity(String raw) => double.parse(raw.trim().replaceAll('%', '').trim());

/// Textbook minimums per report type: (pages, references). At least half
/// of the references must be academic.
(int, int) reportMinimums(String reportType) => reportType == 'final' ? (50, 30) : (30, 15);

/// Why the typed page / reference counts can't be submitted, or null.
String? reportCountsProblem(String reportType, String pages, String references, String academic) {
  final (minPages, minRefs) = reportMinimums(reportType);
  final p = int.tryParse(pages.trim());
  final r = int.tryParse(references.trim());
  final a = int.tryParse(academic.trim());
  if (p == null || r == null || a == null) return 'Enter the page and reference counts.';
  if (p < minPages) return 'A ${reportType == 'final' ? 'final report' : 'proposal'} needs at least $minPages pages.';
  if (r < minRefs) return 'At least $minRefs references are needed.';
  if (a > r) return 'Academic references cannot exceed the total.';
  if (a * 2 < r) return 'At least half of the references must be academic.';
  return null;
}

/// Storage bucket for a report type.
String reportBucket(String reportType) =>
    reportType == 'final' ? 'fyp-final-reports' : 'fyp-proposal-reports';

/// Human label for a report submission status.
String reportStatusLabel(String status) => switch (status) {
      'submitted' => 'Awaiting supervisor endorsement',
      'under_review' => 'Endorsed — under review',
      'approved' => 'Approved',
      'rejected' => 'Returned',
      _ => status.replaceAll('_', ' '),
    };
