import 'models/fypms/fyp_progress_log.dart';

/// F5 consultation attendance (FSKM FYP Text Book: 80 % attendance is
/// required). A week counts as attended when a consultation in it was signed
/// (validated) by the supervisor.
const double kRequiredAttendance = 80;

/// Semester week (1-based) a date falls in, counted from the semester start.
int semesterWeek(DateTime semesterStart, DateTime date) {
  final start = DateTime(semesterStart.year, semesterStart.month, semesterStart.day);
  final day = DateTime(date.year, date.month, date.day);
  return day.difference(start).inDays ~/ 7 + 1;
}

class ConsultationAttendance {
  const ConsultationAttendance({required this.attendedWeeks, required this.expectedWeeks, required this.pending});

  /// Weeks with at least one signed consultation.
  final int attendedWeeks;

  /// Semester weeks elapsed so far (to today, capped at the semester end).
  final int expectedWeeks;

  /// Consultations logged but not yet signed by the supervisor.
  final int pending;

  double get percent => expectedWeeks == 0 ? 100 : 100 * attendedWeeks / expectedWeeks;
  bool get meetsRequirement => percent >= kRequiredAttendance;

  String get summary => expectedWeeks == 0
      ? 'The semester has not started yet.'
      : 'Signed consultations in $attendedWeeks of $expectedWeeks weeks (${percent.toStringAsFixed(0)} %)';
}

ConsultationAttendance consultationAttendance(
  List<FypProgressLog> logs, {
  required DateTime semesterStart,
  required DateTime semesterEnd,
  required DateTime today,
}) {
  final until = today.isAfter(semesterEnd) ? semesterEnd : today;
  final expected = until.isBefore(semesterStart) ? 0 : semesterWeek(semesterStart, until);
  final attended = {
    for (final l in logs)
      if (l.status == 'validated') semesterWeek(semesterStart, l.progressDate),
  }.where((w) => w >= 1 && w <= expected).length;
  return ConsultationAttendance(
    attendedWeeks: attended,
    expectedWeeks: expected,
    pending: logs.where((l) => l.status == 'submitted').length,
  );
}
