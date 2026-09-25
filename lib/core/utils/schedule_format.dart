import '../domain/models/schedule_item.dart';
import '../supabase/row_mappers.dart' show clockMinutes;

const _months = [
  'January', 'February', 'March', 'April', 'May', 'June', 'July',
  'August', 'September', 'October', 'November', 'December',
];

/// A calendar date with no time part, so dates compare by day only.
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// The calendar day an instant falls on in Malaysia time (UTC+8).
DateTime mytDate(DateTime instant) => dateOnly(instant.toUtc().add(const Duration(hours: 8)));

/// Every day the event runs (inclusive, Malaysia time), plus any other day
/// that actually has a schedule item — so a slot added outside the event's
/// configured dates still shows instead of silently disappearing.
List<DateTime> scheduleDays(
  DateTime eventStart,
  DateTime eventEnd,
  Iterable<ScheduleItem> items,
) {
  final days = <DateTime>{};
  final first = mytDate(eventStart);
  final last = mytDate(eventEnd);
  for (var d = first; !d.isAfter(last); d = DateTime(d.year, d.month, d.day + 1)) {
    days.add(d);
  }
  for (final item in items) {
    days.add(dateOnly(item.date));
  }
  return days.toList()..sort();
}

/// "Day 2 (7 August)" for the day at [index] in [scheduleDays].
String dayLabel(int index, DateTime day) =>
    'Day ${index + 1} (${day.day} ${_months[day.month - 1]})';

/// "7 August 2026".
String longDate(DateTime day) => '${day.day} ${_months[day.month - 1]} ${day.year}';

/// Chronological order: by date, then by parsed start time. Plain string
/// comparison put "01:00 PM" before "09:00 AM".
int compareScheduleItems(ScheduleItem a, ScheduleItem b) {
  final byDate = dateOnly(a.date).compareTo(dateOnly(b.date));
  if (byDate != 0) return byDate;
  // Unparseable times sort last rather than throwing.
  final ta = clockMinutes(a.startAt) ?? 24 * 60;
  final tb = clockMinutes(b.startAt) ?? 24 * 60;
  return ta.compareTo(tb);
}

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
