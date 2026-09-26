import '../../../core/domain/models/fypms/fyp_marks_summary.dart';
import '../../../core/domain/models/fypms/fyp_record.dart';
import '../../admin_feedback/presentation/widgets/feedback_csv_export.dart' show escapeCsv;

/// RES upload file (textbook R11 / A28): one row per student with finalized
/// course marks, in the order lecturers key them into UiTM's Result Entry
/// System — matric number, programme, course, total, grade. Only finalized
/// marks are exported; anything else would be a provisional grade.
const resExportHeader = 'Matric No,Programme,Course,Project Title,Total (%),Grade,Finalized';

String buildResExportCsv(List<(FypRecord, List<FypMarksSummary>)> rows) {
  final out = StringBuffer()..writeln(resExportHeader);
  final lines = <(String, String)>[];
  for (final (record, summaries) in rows) {
    for (final s in summaries) {
      if (!s.isFinalized || s.courseCode != record.currentCourseCode) continue;
      final line = [
        escapeCsv(record.matricId ?? ''),
        escapeCsv(record.programmeCode),
        escapeCsv(s.courseCode),
        escapeCsv(record.projectTitle ?? ''),
        s.weightedTotal.toStringAsFixed(2),
        escapeCsv(s.grade ?? ''),
        s.finalizedAt == null ? '' : _date(s.finalizedAt!),
      ].join(',');
      lines.add((record.matricId ?? '', line));
    }
  }
  // Sorted by matric number so the file lines up with RES class lists.
  lines.sort((a, b) => a.$1.compareTo(b.$1));
  for (final (_, line) in lines) {
    out.writeln(line);
  }
  return out.toString();
}

/// Number of finalized rows [buildResExportCsv] would write.
int resExportCount(List<(FypRecord, List<FypMarksSummary>)> rows) => [
      for (final (r, list) in rows)
        for (final s in list)
          if (s.isFinalized && s.courseCode == r.currentCourseCode) s,
    ].length;

/// Malaysia date, yyyy-mm-dd.
String _date(DateTime t) {
  final m = t.toUtc().add(const Duration(hours: 8));
  return '${m.year}-${m.month.toString().padLeft(2, '0')}-${m.day.toString().padLeft(2, '0')}';
}
