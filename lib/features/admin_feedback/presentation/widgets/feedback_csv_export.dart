import 'package:fyp_expo_hub/core/domain/models/feedback_entry.dart';

String escapeCsv(String value) {
  final needsQuoting = value.contains(',') || value.contains('"') || value.contains('\n');
  if (!needsQuoting) return value;
  final escaped = value.replaceAll('"', '""');
  return '"$escaped"';
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
