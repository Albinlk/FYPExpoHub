import 'package:fyp_expo_hub/core/domain/models/feedback_entry.dart';

/// Characters that make Excel / Sheets treat a cell as a formula. Feedback
/// text is written by anonymous visitors, so a message like
/// `=HYPERLINK("https://evil", "click")` must stay inert when an admin
/// opens the export (OWASP "CSV injection").
const _formulaTriggers = {'=', '+', '-', '@', '\t', '\r'};

String escapeCsv(String value) {
  var v = value;
  if (v.isNotEmpty && _formulaTriggers.contains(v[0])) {
    // A leading apostrophe forces the spreadsheet to read the cell as text.
    v = "'$v";
  }
  final needsQuoting = v.contains(',') || v.contains('"') || v.contains('\n') || v.contains('\r');
  if (!needsQuoting) return v;
  return '"${v.replaceAll('"', '""')}"';
}

String exportFeedbackCsv(List<FeedbackEntry> entries) {
  final buffer = StringBuffer();
  buffer.writeln('ID,User ID,Subject,Message,Rating,Status,Admin Note,Created At,Updated At');

  for (final e in entries) {
    buffer.writeln([
      escapeCsv(e.id),
      escapeCsv(e.userId ?? ''),
      escapeCsv(e.subject),
      escapeCsv(e.message),
      e.rating?.toString() ?? '',
      escapeCsv(e.status),
      escapeCsv(e.adminNote ?? ''),
      e.createdAt.toIso8601String(),
      e.updatedAt.toIso8601String(),
    ].join(','));
  }

  return buffer.toString();
}
