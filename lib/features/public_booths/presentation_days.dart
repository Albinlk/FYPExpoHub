import '../../core/utils/schedule_format.dart' show mytDate;

const _shortMonths = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// The longest event span the fallback labels cover, so a misconfigured end
/// date cannot fill the Day dropdown with months of options.
const _maxEventDays = 14;

/// "Day 1 - 06 Aug 2026": the `presentation_day` format the importer writes.
String presentationDayLabel(int index, DateTime day) {
  final dd = day.day.toString().padLeft(2, '0');
  return 'Day ${index + 1} - $dd ${_shortMonths[day.month - 1]} ${day.year}';
}

final _dayNumber = RegExp(r'^\s*Day\s+(\d+)', caseSensitive: false);

/// The Day filter's options, in "Day N" order.
///
/// The projects' own distinct `presentation_day` values are used as they are
/// (so the filter always matches the data exactly). Every other day of the
/// event (start to end, Malaysia time) is added in the same format, so a day
/// with no published booths yet, or no data at all, still shows as before.
List<String> presentationDayOptions(
  Iterable<String?> dataDays, {
  required DateTime eventStart,
  required DateTime eventEnd,
}) {
  final byNumber = <int, Set<String>>{};
  final unnumbered = <String>{};
  for (final d in dataDays) {
    if (d == null || d.trim().isEmpty) continue;
    final n = int.tryParse(_dayNumber.firstMatch(d)?.group(1) ?? '');
    if (n == null) {
      unnumbered.add(d);
    } else {
      // Every distinct data label stays, even two spellings of one day.
      (byNumber[n] ??= <String>{}).add(d);
    }
  }
  final first = mytDate(eventStart);
  final last = mytDate(eventEnd);
  var index = 0;
  for (var d = first;
      !d.isAfter(last) && index < _maxEventDays;
      d = DateTime(d.year, d.month, d.day + 1), index++) {
    byNumber.putIfAbsent(index + 1, () => {presentationDayLabel(index, d)});
  }
  // An end before the start still gives the filter one day to show.
  if (byNumber.isEmpty && unnumbered.isEmpty) byNumber[1] = {presentationDayLabel(0, first)};
  final numbers = byNumber.keys.toList()..sort();
  return [
    for (final n in numbers) ...(byNumber[n]!.toList()..sort()),
    ...(unnumbered.toList()..sort()),
  ];
}
