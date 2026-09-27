/// Project / booth import from the Master File or a CSV (backlog F5).
///
/// The sheet's first row is a header; columns are matched by name (English
/// or Malay), so the order does not matter. Rows become the payload of
/// `import_event_projects`, which re-checks duplicates in the database.
library;

String _norm(String s) => s.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();

/// Header aliases per payload field (compared lower-cased, spaces collapsed,
/// punctuation dropped).
const Map<String, List<String>> kProjectImportColumns = {
  'title': ['title', 'project title', 'tajuk', 'tajuk projek', 'project'],
  'student_team': ['students', 'student', 'team', 'team members', 'nama pelajar', 'pelajar', 'student name', 'name'],
  'team_display_name': ['team name', 'nama kumpulan'],
  'matric_id': ['matric', 'matric id', 'matric no', 'no matrik', 'student id'],
  'programme_code': ['programme', 'programme code', 'program', 'kod program', 'code'],
  'programme_name': ['programme name', 'nama program'],
  'supervisor_display_name': ['supervisor', 'penyelia', 'sv'],
  'examiner_display_name': ['examiner', 'pemeriksa', 'penilai'],
  'booth_number': ['booth', 'booth no', 'booth number', 'no booth', 'gerai', 'no gerai', 'booth id'],
  'booth_zone': ['zone', 'zon', 'booth zone'],
  'category': ['category', 'kategori', 'track'],
  'tech_tags': ['tags', 'technology', 'technologies', 'tech', 'tech stack'],
  'short_description': ['description', 'abstract', 'summary', 'ringkasan', 'short description'],
  'presentation_day': ['day', 'hari', 'presentation day'],
};

const _listFields = {'student_team', 'tech_tags'};

String _headerKey(String h) => _norm(h.replaceAll(RegExp(r'[^A-Za-z0-9 ]'), ' '));

/// Splits CSV text into rows, honouring quoted cells (commas, quotes and
/// line breaks inside quotes). The delimiter (comma, semicolon or tab) is
/// the one the header line uses most.
List<List<String>> parseCsvRows(String text) {
  final headerLine = text.split(RegExp(r'\r?\n')).first.replaceAll(RegExp(r'"[^"]*"'), '');
  final delimiter = [',', ';', '\t']
      .reduce((a, b) => b.allMatches(headerLine).length > a.allMatches(headerLine).length ? b : a);
  final rows = <List<String>>[];
  var row = <String>[];
  final cell = StringBuffer();
  var quoted = false;
  for (var i = 0; i < text.length; i++) {
    final ch = text[i];
    if (quoted) {
      if (ch == '"') {
        if (i + 1 < text.length && text[i + 1] == '"') {
          cell.write('"');
          i++;
        } else {
          quoted = false;
        }
      } else {
        cell.write(ch);
      }
    } else if (ch == '"') {
      quoted = true;
    } else if (ch == delimiter) {
      row.add(cell.toString());
      cell.clear();
    } else if (ch == '\n' || ch == '\r') {
      if (ch == '\r' && i + 1 < text.length && text[i + 1] == '\n') i++;
      row.add(cell.toString());
      cell.clear();
      if (row.any((c) => c.trim().isNotEmpty)) rows.add(row);
      row = <String>[];
    } else {
      cell.write(ch);
    }
  }
  row.add(cell.toString());
  if (row.any((c) => c.trim().isNotEmpty)) rows.add(row);
  return rows;
}

class ProjectImportRow {
  ProjectImportRow(this.rowNumber, this.values);

  /// 1-based row in the sheet (the header is row 1).
  final int rowNumber;

  /// Payload fields; list fields hold `List<String>`.
  final Map<String, Object> values;

  String get title => (values['title'] as String?) ?? '';
  String? get boothNumber => values['booth_number'] as String?;

  /// Set by [checkProjectImport].
  String? problem;

  /// Already in the exhibition (same title).
  bool existing = false;

  Map<String, Object> toPayload() => {'row': rowNumber, ...values};
}

class ProjectImportParse {
  ProjectImportParse(this.rows, this.unmatchedHeaders, this.error);

  final List<ProjectImportRow> rows;
  final List<String> unmatchedHeaders;

  /// Set when the sheet cannot be imported at all.
  final String? error;
}

/// Reads a header + rows grid (from CSV or an XLSX sheet).
ProjectImportParse parseProjectSheet(List<List<String>> grid) {
  if (grid.isEmpty) return ProjectImportParse(const [], const [], 'The file is empty.');
  final header = grid.first;
  final columns = <int, String>{};
  final unmatched = <String>[];
  for (var i = 0; i < header.length; i++) {
    final key = _headerKey(header[i]);
    if (key.isEmpty) continue;
    String? field;
    for (final e in kProjectImportColumns.entries) {
      if (e.value.contains(key) && !columns.containsValue(e.key)) {
        field = e.key;
        break;
      }
    }
    if (field == null) {
      unmatched.add(header[i].trim());
    } else {
      columns[i] = field;
    }
  }
  if (!columns.containsValue('title')) {
    return ProjectImportParse(const [], unmatched, 'No project title column (e.g. "Title" or "Tajuk").');
  }

  final rows = <ProjectImportRow>[];
  for (var r = 1; r < grid.length; r++) {
    final values = <String, Object>{};
    columns.forEach((i, field) {
      final raw = i < grid[r].length ? grid[r][i].trim() : '';
      if (raw.isEmpty) return;
      if (_listFields.contains(field)) {
        final parts = [for (final p in raw.split(RegExp(r'[;,\n/]'))) p.trim()]..removeWhere((p) => p.isEmpty);
        if (parts.isNotEmpty) values[field] = parts;
      } else {
        values[field] = raw.replaceAll(RegExp(r'\s+'), ' ');
      }
    });
    if (values.isEmpty) continue;
    rows.add(ProjectImportRow(r + 1, values));
  }
  return ProjectImportParse(rows, unmatched, rows.isEmpty ? 'No project rows under the header.' : null);
}

/// Flags rows with no title, titles repeated in the file, titles already in
/// the exhibition, and booth numbers used twice in the file or taken by a
/// different live project. Returns the number of rows with a problem.
int checkProjectImport(
  List<ProjectImportRow> rows, {
  required Iterable<String> existingTitles,
  Map<String, String> existingBooths = const {},
}) {
  final live = {for (final t in existingTitles) _norm(t)};
  final booths = {for (final e in existingBooths.entries) e.key.trim().toUpperCase(): _norm(e.value)};
  final seenTitles = <String, int>{};
  final seenBooths = <String, int>{};
  var problems = 0;
  for (final row in rows) {
    row.problem = null;
    row.existing = false;
    final title = _norm(row.title);
    if (title.isEmpty) {
      row.problem = 'No title.';
    } else if (seenTitles.containsKey(title)) {
      row.problem = 'Same title as row ${seenTitles[title]}.';
    } else {
      seenTitles[title] = row.rowNumber;
      row.existing = live.contains(title);
      final booth = row.boothNumber?.trim().toUpperCase();
      if (booth != null && booth.isNotEmpty) {
        if (seenBooths.containsKey(booth)) {
          row.problem = 'Booth $booth is also on row ${seenBooths[booth]}.';
        } else {
          seenBooths[booth] = row.rowNumber;
          final holder = booths[booth];
          if (holder != null && holder != title) row.problem = 'Booth $booth already belongs to another project.';
        }
      }
    }
    if (row.problem != null) problems++;
  }
  return problems;
}
