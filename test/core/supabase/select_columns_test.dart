import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/supabase/select_columns.dart';
import 'package:fyp_expo_hub/core/utils/fypms_key_normalizer.dart';

/// Guards the explicit column lists in `SelectColumns`: a misspelt or
/// dropped column makes PostgREST reject the whole query with a 400 in
/// production, so it must fail here first.

/// Table -> columns, from every `create table` and `alter table … add
/// column` in supabase/migrations/*.sql.
Map<String, Set<String>> _schemaFromMigrations() {
  const notColumns = {'constraint', 'primary', 'unique', 'check', 'foreign', 'exclude', 'like'};
  final files = Directory('supabase/migrations')
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.sql'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  final tables = <String, Set<String>>{};
  final createTable = RegExp(r'create\s+table\s+(?:if\s+not\s+exists\s+)?(?:public\.)?"?(\w+)"?\s*\(', caseSensitive: false);
  final alterTable = RegExp(r'alter\s+table\s+(?:if\s+exists\s+)?(?:only\s+)?(?:public\.)?"?(\w+)"?([^;]*);', caseSensitive: false);
  final addColumn = RegExp(r'add\s+column\s+(?:if\s+not\s+exists\s+)?"?(\w+)"?', caseSensitive: false);
  final leadingWord = RegExp(r'^\s*"?(\w+)"?');

  for (final file in files) {
    final sql = file.readAsStringSync().replaceAll(RegExp(r'--[^\n]*'), '');
    for (final m in createTable.allMatches(sql)) {
      final cols = tables.putIfAbsent(m.group(1)!.toLowerCase(), () => <String>{});
      // The body runs to the parenthesis that closes the one matched above.
      var depth = 1;
      var i = m.end;
      final parts = <String>[];
      final current = StringBuffer();
      while (depth > 0) {
        final c = sql[i++];
        if (c == '(') depth++;
        if (c == ')') depth--;
        if (depth == 0) break;
        if (c == ',' && depth == 1) {
          parts.add(current.toString());
          current.clear();
        } else {
          current.write(c);
        }
      }
      parts.add(current.toString());
      for (final part in parts) {
        final word = leadingWord.firstMatch(part)?.group(1)?.toLowerCase();
        if (word != null && !notColumns.contains(word)) cols.add(word);
      }
    }
    for (final m in alterTable.allMatches(sql)) {
      for (final a in addColumn.allMatches(m.group(2)!)) {
        tables.putIfAbsent(m.group(1)!.toLowerCase(), () => <String>{}).add(a.group(1)!.toLowerCase());
      }
    }
  }
  return tables;
}

/// Splits [select] at top-level commas into plain columns and embedded
/// resources (`table!hint(cols)`), returning (table, column) pairs.
List<(String, String)> _selectedColumns(String table, String select) {
  final out = <(String, String)>[];
  final parts = <String>[];
  var depth = 0;
  final current = StringBuffer();
  for (final c in select.split('')) {
    if (c == '(') depth++;
    if (c == ')') depth--;
    if (c == ',' && depth == 0) {
      parts.add(current.toString().trim());
      current.clear();
    } else {
      current.write(c);
    }
  }
  parts.add(current.toString().trim());
  for (final part in parts) {
    final open = part.indexOf('(');
    if (open == -1) {
      out.add((table, part));
    } else {
      final embedded = part.substring(0, open).split('!').first.trim();
      out.addAll(_selectedColumns(embedded, part.substring(open + 1, part.lastIndexOf(')'))));
    }
  }
  return out;
}

/// Model class -> the JSON keys its generated `fromJson` reads.
Map<String, Set<String>> _modelKeys() {
  final fromJson = RegExp(r'_\$(\w+)FromJson\(\s*Map<String, dynamic> json,?\s*\) =>(.*?)\n\nMap<String, dynamic>', dotAll: true);
  final key = RegExp(r"json\['(\w+)'\]");
  final out = <String, Set<String>>{};
  for (final f in Directory('lib/core/domain/models').listSync(recursive: true).whereType<File>()) {
    if (!f.path.endsWith('.g.dart')) continue;
    final src = f.readAsStringSync().replaceAll('\r\n', '\n');
    for (final m in fromJson.allMatches(src)) {
      out[m.group(1)!] = {for (final k in key.allMatches(m.group(2)!)) k.group(1)!};
    }
  }
  return out;
}

/// The model key a column lands under after `normalizeKeys`.
String _normalizedKey(String column) {
  final m = normalizeKeys({column: 0});
  for (final e in m.entries) {
    if (e.value == 0) return e.key;
  }
  return 'teamDisplayNames';
}

String _camel(String column) {
  final p = column.split('_');
  return p.first + p.skip(1).map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1)).join();
}

void main() {
  final schema = _schemaFromMigrations();

  test('the migrations parse into the tables the app reads', () {
    expect(schema['projects'], containsAll(['id', 'title', 'abstract', 'tech_tags']));
    expect(schema['events'], containsAll(['is_current', 'academic_semester_id']));
    expect(schema['fyp_record_assignments'], contains('pu_status'));
  });

  test('every SelectColumns column exists in the migrations', () {
    final problems = <String>[];
    for (final (table, select) in SelectColumns.all) {
      expect(select.contains('*'), isFalse, reason: '$table: lists must be explicit');
      final seen = <String>{};
      for (final (t, column) in _selectedColumns(table, select)) {
        final known = schema[t];
        if (known == null) {
          problems.add('$table: unknown table "$t"');
        } else if (!known.contains(column)) {
          problems.add('$table: "$t.$column" is not a column');
        }
        if (!seen.add('$t.$column')) problems.add('$table: "$t.$column" listed twice');
      }
    }
    expect(problems, isEmpty);
  });

  // Model-backed lists must fetch every column their model reads, or the
  // field silently comes back null/default.
  test('model-backed lists cover every column their model reads', () {
    final models = _modelKeys();
    const backedBy = <String, (String, String)>{
      'Project': ('projects', SelectColumns.projects),
      'ScheduleItem': ('schedule_items', SelectColumns.scheduleItems),
      'Booth': ('booths', SelectColumns.booths),
      'Announcement': ('announcements', SelectColumns.announcements),
      'PublishedAwardWinner': ('award_winners', SelectColumns.awardWinners),
      'Event': ('events', SelectColumns.events),
      'FeedbackEntry': ('feedback_entries', SelectColumns.feedbackEntries),
      'ProjectLecturerAssignment': ('lecturer_assignments', SelectColumns.lecturerAssignments),
      'StudentVisit': ('student_project_visits', SelectColumns.studentProjectVisits),
      'AcademicSemester': ('academic_semesters', SelectColumns.academicSemesters),
      'AcademicCourse': ('academic_courses', SelectColumns.academicCourses),
      'FypCourseOffering': ('fyp_course_offerings', SelectColumns.fypCourseOfferings),
      'FypRecord': ('fyp_records', SelectColumns.fypRecords),
      'FypRecordAssignment': ('fyp_record_assignments', SelectColumns.fypRecordAssignments),
      'FypSupervisionRequest': ('fyp_supervision_requests', SelectColumns.fypSupervisionRequests),
      'FypProgressLog': ('fyp_progress_logs', SelectColumns.fypProgressLogs),
      'FypFormSubmission': ('fyp_form_submissions', SelectColumns.fypFormSubmissions),
      'FypRubricTemplate': ('fyp_rubric_templates', SelectColumns.fypRubricTemplates),
      'FypReportSubmission': ('fyp_report_submissions', SelectColumns.fypReportSubmissions),
      'FypDeliverable': ('fyp_deliverables', SelectColumns.fypDeliverables),
      'FypLeanCanvas': ('fyp_lean_canvases', SelectColumns.fypLeanCanvases),
      'FypMilestone': ('fyp_milestones', SelectColumns.fypMilestones),
      'FypCorrectionItem': ('fyp_correction_items', SelectColumns.fypCorrectionItems),
      'FypPresentationSession': ('fyp_presentation_sessions', SelectColumns.fypPresentationSessions),
      'FypPresentationSlot': ('fyp_presentation_slots', SelectColumns.fypPresentationSlots),
      'FypMarksSummary': ('fyp_marks_summaries', SelectColumns.fypMarksSummaries),
      'FypExpoPublication': ('fyp_expo_publications', SelectColumns.fypExpoPublications),
      'FypAuditLog': ('fyp_audit_logs', SelectColumns.fypAuditLogs),
    };
    // Deliberately left out: nothing reads them, and they can be large.
    const intentionallyDropped = {'fyp_marks_summaries.export_payload'};

    final problems = <String>[];
    backedBy.forEach((model, spec) {
      final (table, select) = spec;
      final keys = models[model];
      if (keys == null) {
        problems.add('no generated fromJson for $model');
        return;
      }
      final listed = {for (final (t, c) in _selectedColumns(table, select)) if (t == table) c};
      for (final column in schema[table] ?? const <String>{}) {
        final readByModel = keys.contains(_normalizedKey(column)) || keys.contains(_camel(column));
        if (readByModel && !listed.contains(column) && !intentionallyDropped.contains('$table.$column')) {
          problems.add('$model reads "$table.$column" but SelectColumns does not fetch it');
        }
      }
    });
    expect(problems, isEmpty);
  });

  test('the parser catches a misspelt column', () {
    final pairs = _selectedColumns('fyp_milestone_extensions', 'id, fyp_milestones!inner(milestone_cod)');
    expect(pairs, [('fyp_milestone_extensions', 'id'), ('fyp_milestones', 'milestone_cod')]);
    expect(schema['fyp_milestones'], isNot(contains('milestone_cod')));
  });
}
