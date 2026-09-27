import '../utils/external_link.dart';

/// Kinds of answer a form field takes.
enum FormFieldKind { text, longText, url, number }

/// One question on a student FYPMS form (backlog U1).
class FormFieldDef {
  const FormFieldDef(this.key, this.label, {this.kind = FormFieldKind.text, this.required = true, this.help});

  final String key;
  final String label;
  final FormFieldKind kind;
  final bool required;
  final String? help;
}

/// A student form: title, what it's for, and its questions.
class FormDefinition {
  const FormDefinition(this.code, this.title, this.purpose, this.fields);

  final String code;
  final String title;
  final String purpose;
  final List<FormFieldDef> fields;
}

const _title = FormFieldDef('title', 'Project title');
const _slides = FormFieldDef('slides_url', 'Slides link', kind: FormFieldKind.url, help: 'Google Drive / OneDrive share link');

/// The student-submitted forms (FSKM FYP Text Book, 4th ed.). F1, F5, F6
/// and F12 have their own pages; F13 is the Lean Canvas page.
const kStudentFormDefinitions = <String, FormDefinition>{
  'F2': FormDefinition('F2', 'Problem Identification', 'State the problem, its evidence and your proposed solution.', [
    _title,
    FormFieldDef('background', 'Problem background', kind: FormFieldKind.longText),
    FormFieldDef('problem_statement', 'Problem statement', kind: FormFieldKind.longText),
    FormFieldDef('evidence', 'Evidence of the problem', kind: FormFieldKind.longText,
        help: 'Statistics, surveys, interviews or literature that show the problem is real'),
    FormFieldDef('proposed_solution', 'Proposed solution', kind: FormFieldKind.longText),
  ]),
  'F3': FormDefinition('F3', 'Literature Review', 'Summarise the related work and the gap your project fills.', [
    _title,
    FormFieldDef('scope', 'Area and scope reviewed', kind: FormFieldKind.longText),
    FormFieldDef('key_findings', 'Key findings from the literature', kind: FormFieldKind.longText),
    FormFieldDef('research_gap', 'Research gap', kind: FormFieldKind.longText),
    FormFieldDef('reference_count', 'Number of references', kind: FormFieldKind.number),
  ]),
  'F4': FormDefinition('F4', 'Methodology', 'Describe how you will carry out the project.', [
    _title,
    FormFieldDef('approach', 'Methodology / model', kind: FormFieldKind.longText, help: 'e.g. Waterfall, Agile, design science'),
    FormFieldDef('phases', 'Phases and activities', kind: FormFieldKind.longText),
    FormFieldDef('tools', 'Techniques, tools and technologies', kind: FormFieldKind.longText),
    FormFieldDef('gantt_url', 'Gantt chart link', kind: FormFieldKind.url, required: false),
  ]),
  'F7': FormDefinition('F7', 'Proposal Presentation', 'Details of your proposal presentation.', [
    _title,
    _slides,
    FormFieldDef('summary', 'Presentation summary', kind: FormFieldKind.longText, required: false),
  ]),
  'F8': FormDefinition('F8', 'Proposal Report Evaluation', 'Ask for your proposal report (submitted on the Reports page) to be evaluated.', [
    _title,
    FormFieldDef('report_version', 'Proposal report version to evaluate', kind: FormFieldKind.number),
    FormFieldDef('changes', 'Changes since the last review', kind: FormFieldKind.longText, required: false),
  ]),
  'F9': FormDefinition('F9', 'Progress Presentation', 'Your progress against the Gantt chart and milestones.', [
    _title,
    FormFieldDef('progress_summary', 'Progress so far', kind: FormFieldKind.longText),
    FormFieldDef('completed_milestones', 'Milestones completed', kind: FormFieldKind.longText),
    FormFieldDef('next_steps', 'Next steps', kind: FormFieldKind.longText),
    _slides,
  ]),
  'F10': FormDefinition('F10', 'Final Presentation', 'Materials for your final presentation at the exhibition.', [
    _title,
    _slides,
    FormFieldDef('poster_url', 'Poster link', kind: FormFieldKind.url),
    FormFieldDef('demo_url', 'Demo video link', kind: FormFieldKind.url, required: false),
  ]),
  'F11': FormDefinition('F11', 'Project Report Evaluation', 'Ask for your final report (submitted on the Reports page) to be evaluated.', [
    _title,
    FormFieldDef('abstract', 'Abstract', kind: FormFieldKind.longText),
    FormFieldDef('report_version', 'Final report version to evaluate', kind: FormFieldKind.number),
  ]),
  'F14': FormDefinition('F14', 'Special Evaluation Application', 'Apply for special evaluation (the CSP650 lecturer checks your eligibility).', [
    _title,
    FormFieldDef('reason', 'Why you are applying', kind: FormFieldKind.longText),
    FormFieldDef('chapters_status', 'Status of chapters 1–5', kind: FormFieldKind.longText),
  ]),
  'F15': FormDefinition('F15', 'Special Evaluation Presentation', 'Materials for your special-evaluation presentation.', [
    _title,
    _slides,
    FormFieldDef('poster_url', 'Poster link', kind: FormFieldKind.url, required: false),
  ]),
  'F16': FormDefinition('F16', 'Special Evaluation Report', 'Ask for your report to be evaluated under special evaluation.', [
    _title,
    FormFieldDef('abstract', 'Abstract', kind: FormFieldKind.longText),
    FormFieldDef('report_version', 'Final report version to evaluate', kind: FormFieldKind.number),
  ]),
};

/// Forms submitted elsewhere, and where.
const kFormsWithOwnPage = {
  'F6a': 'Reports page',
  'F13': 'Lean Canvas page',
};

/// Why an answer can't be submitted, or null.
String? formFieldProblem(FormFieldDef f, String raw) {
  final v = raw.trim();
  if (v.isEmpty) return f.required ? '${f.label} is required.' : null;
  switch (f.kind) {
    case FormFieldKind.url:
      return safeExternalUri(v) == null ? '${f.label} must be an http(s) link.' : null;
    case FormFieldKind.number:
      final n = int.tryParse(v);
      return n == null || n < 0 ? '${f.label} must be a whole number.' : null;
    case FormFieldKind.text:
    case FormFieldKind.longText:
      return v.length > 5000 ? '${f.label} is too long (5000 characters at most).' : null;
  }
}

/// The payload saved for a form: answers keyed by field (numbers as ints,
/// blank optional answers left out).
Map<String, dynamic> formPayload(FormDefinition def, Map<String, String> answers) => {
      for (final f in def.fields)
        if ((answers[f.key] ?? '').trim().isNotEmpty)
          f.key: f.kind == FormFieldKind.number ? int.parse(answers[f.key]!.trim()) : answers[f.key]!.trim(),
    };

/// Readable (label, answer) pairs for a submitted payload; unknown keys
/// (older free-form submissions) are shown with their raw key.
List<(String, String)> formAnswers(String formCode, Map<String, dynamic> payload) {
  final def = kStudentFormDefinitions[formCode];
  final labels = {for (final f in def?.fields ?? const <FormFieldDef>[]) f.key: f.label};
  return [
    for (final e in payload.entries)
      if (e.value != null && '${e.value}'.trim().isNotEmpty) (labels[e.key] ?? e.key.replaceAll('_', ' '), '${e.value}'),
  ];
}
