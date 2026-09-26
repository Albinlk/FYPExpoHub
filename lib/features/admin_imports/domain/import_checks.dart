/// Import checks done while staging a Master File (known-gaps register
/// G-06). They annotate the staged candidate maps in place
/// (`comparison_status`, `is_duplicate`, `is_overlapping`,
/// `overlap_details`) and return the validation issues to stage with them.
///
/// comparison_status:
///   new        nothing like it is live yet
///   unchanged  an identical item is already live (default action: Skip)
///   updated    same day + title is live with a different time or venue
///              (default action: Replace existing)
library;

import '../../../core/domain/models/award.dart';
import '../../../core/domain/models/schedule_item.dart';
import '../../../core/supabase/row_mappers.dart' show clockMinutes, scheduleDateString;


String _norm(String? s) => (s ?? '').toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();

class _Slot {
  _Slot(this.date, this.start, this.end, this.title, this.venue, this.label);
  final String date;
  final int start;
  final int end;
  final String title;
  final String venue;

  /// For messages, e.g. `"Opening" 09:00–10:00`.
  final String label;

  bool overlaps(_Slot o) => date == o.date && venue.isNotEmpty && venue == o.venue && start < o.end && o.start < end;
}

String _hhmm(int m) => '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';

_Slot? _candidateSlot(Map<String, dynamic> c) {
  final date = c['event_date'] as String?;
  final start = clockMinutes(c['start_at'] as String?);
  final end = clockMinutes(c['end_at'] as String?);
  if (date == null || start == null || end == null) return null;
  return _Slot(date, start, end, _norm(c['title'] as String?), _norm(c['venue'] as String?),
      '"${c['title']}" ${_hhmm(start)}–${_hhmm(end)}');
}

_Slot? _itemSlot(ScheduleItem s) {
  final start = clockMinutes(s.startAt);
  final end = clockMinutes(s.endAt);
  if (start == null || end == null) return null;
  return _Slot(scheduleDateString(s.date), start, end, _norm(s.title), _norm(s.venue),
      '"${s.title}" ${_hhmm(start)}–${_hhmm(end)}');
}

Map<String, dynamic> _issue(String importId, String sheet, Object? row, String type, String severity, String message) => {
      'import_id': importId,
      'worksheet_name': sheet,
      'row_number': row ?? 0,
      'issue_type': type,
      'severity': severity,
      'message': message,
    };

/// Checks schedule candidates against each other and the live schedule.
List<Map<String, dynamic>> checkScheduleCandidates({
  required String importId,
  required String defaultSheet,
  required List<Map<String, dynamic>> candidates,
  required List<ScheduleItem> existing,
}) {
  final issues = <Map<String, dynamic>>[];
  final live = [for (final s in existing) (s, _itemSlot(s))];
  final seen = <_Slot>[];
  for (final c in candidates) {
    final slot = _candidateSlot(c);
    if (slot == null) continue; // unreadable day/time: already reported
    final row = c['row_number'];
    final sheet = (c['_sheet'] as String?) ?? defaultSheet;

    // Same day, title and time earlier in this file.
    if (seen.any((o) => o.date == slot.date && o.title == slot.title && o.start == slot.start)) {
      c['is_duplicate'] = true;
      issues.add(_issue(importId, sheet, row, 'duplicate', 'warning',
          'Row $row repeats ${slot.label} from earlier in the file. Skip one of them.'));
    }

    // Against the live schedule.
    final sameTitle = [for (final (s, l) in live) if (l != null && l.date == slot.date && l.title == slot.title) (s, l)];
    if (sameTitle.any((e) => e.$2.start == slot.start && e.$2.end == slot.end && e.$2.venue == slot.venue)) {
      c['comparison_status'] = 'unchanged';
      c['is_duplicate'] = true;
      issues.add(_issue(importId, sheet, row, 'duplicate', 'info', '${slot.label} is already on the schedule.'));
    } else if (sameTitle.isNotEmpty) {
      c['comparison_status'] = 'updated';
      issues.add(_issue(importId, sheet, row, 'changed', 'info',
          '${slot.label} changes ${sameTitle.first.$2.label} on the schedule — choose Replace existing to update it.'));
    }

    // Same venue at an overlapping time, in this file or live (other items).
    final clashes = [
      for (final o in seen)
        if (o.overlaps(slot) && o.title != slot.title) o.label,
      for (final (_, l) in live)
        if (l != null && l.overlaps(slot) && l.title != slot.title) l.label,
    ];
    if (clashes.isNotEmpty) {
      c['is_overlapping'] = true;
      c['overlap_details'] = 'Overlaps ${clashes.join(', ')} in ${c['venue']}';
      issues.add(_issue(importId, sheet, row, 'overlap', 'warning',
          '${slot.label} overlaps ${clashes.join(', ')} in ${c['venue']}.'));
    }
    seen.add(slot);
  }
  return issues;
}

/// Checks award candidates: the same award + team twice in the file, or
/// already published.
List<Map<String, dynamic>> checkAwardCandidates({
  required String importId,
  required String defaultSheet,
  required List<Map<String, dynamic>> candidates,
  required List<PublishedAwardWinner> existing,
}) {
  final issues = <Map<String, dynamic>>[];
  final live = {for (final w in existing) '${_norm(w.projectTitle)}|${_norm(w.teamDisplayName)}'};
  final seen = <String>{};
  for (final c in candidates) {
    final key = '${_norm(c['award_category'] as String?)}|${_norm(c['team_display_name'] as String?)}';
    final row = c['row_number'];
    final sheet = (c['_sheet'] as String?) ?? defaultSheet;
    final label = '${c['award_category']}: ${c['team_display_name']}';
    if (!seen.add(key)) {
      c['is_skip'] = true;
      issues.add(_issue(importId, sheet, row, 'duplicate', 'warning', 'Row $row repeats $label from earlier in the file.'));
    }
    if (live.contains(key)) {
      c['comparison_status'] = 'unchanged';
      // Suggest Skip, as for a schedule row that is already live (the award
      // review list keys its default off is_skip).
      c['is_skip'] = true;
      issues.add(_issue(importId, sheet, row, 'duplicate', 'info', '$label is already published.'));
    }
  }
  return issues;
}

/// English / Malay sheet names the parser treats alike (it reads
/// "TENTATIF or SCHEDULE" and "ANUGERAH or AWARD" sheets).
const _sheetAliases = [
  {'SCHEDULE', 'TENTATIF'},
  {'AWARD', 'ANUGERAH'},
];

/// Worksheets named in the `excel_import.mandatoryWorksheets` setting
/// (comma separated, case-insensitive substring match, English/Malay
/// aliases accepted) that the file lacks.
List<String> missingWorksheets(String? setting, Iterable<String> sheetNames) {
  final names = [for (final n in sheetNames) n.toUpperCase()];
  bool present(String wanted) {
    final w = wanted.toUpperCase();
    final alternatives = {
      w,
      for (final group in _sheetAliases)
        if (group.any(w.contains)) ...group,
    };
    return names.any((n) => alternatives.any(n.contains));
  }

  return [
    for (final w in (setting ?? '').split(','))
      if (w.trim().isNotEmpty && !present(w.trim())) w.trim(),
  ];
}

/// "10 MB", "500KB", "2.5 mb", "1048576" → bytes; null if unreadable.
int? parseFileSize(String? raw) {
  final m = RegExp(r'^\s*(\d+(?:\.\d+)?)\s*(b|kb|mb|gb)?\s*$', caseSensitive: false).firstMatch(raw ?? '');
  if (m == null) return null;
  final n = double.parse(m.group(1)!);
  final unit = (m.group(2) ?? 'b').toLowerCase();
  const mult = {'b': 1, 'kb': 1024, 'mb': 1024 * 1024, 'gb': 1024 * 1024 * 1024};
  return (n * mult[unit]!).round();
}

/// The default review action for a staged row.
String defaultImportAction({required String comparisonStatus, required bool isDuplicate}) {
  if (comparisonStatus == 'unchanged' || isDuplicate) return 'skip';
  if (comparisonStatus == 'updated') return 'replace_existing';
  return 'publish';
}
