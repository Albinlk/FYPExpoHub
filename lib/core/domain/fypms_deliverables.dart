import 'models/fypms/fyp_deliverable.dart';

/// One CSP650 deliverable from the FSKM FYP Text Book (4th ed., Table 2.1
/// item 51 / Table 2.3 item 32). Mirrors `submit_deliverable`, which enforces
/// the type list, the required flag and the link rule.
class DeliverableSpec {
  const DeliverableSpec({
    required this.type,
    required this.title,
    required this.required,
    required this.extensions,
    this.hint,
  });

  /// `fyp_deliverables.deliverable_type`
  final String type;
  final String title;

  /// Always required; the others are "if relevant".
  final bool required;

  /// Allowed file extensions (empty = any file).
  final List<String> extensions;
  final String? hint;

  /// "If relevant" items may be an https link instead of an upload (large
  /// systems, repositories, datasets).
  bool get linkAllowed => !required;
}

const List<DeliverableSpec> fypmsDeliverableChecklist = [
  DeliverableSpec(
    type: 'final_report_pdf',
    title: 'FYP report (PDF)',
    required: true,
    extensions: ['pdf'],
    hint: 'Including abstract and appendices',
  ),
  DeliverableSpec(
    type: 'final_report_doc',
    title: 'FYP report (Word)',
    required: true,
    extensions: ['doc', 'docx'],
    hint: 'Same report as a .doc / .docx',
  ),
  DeliverableSpec(type: 'presentation_slides', title: 'Presentation slides', required: true, extensions: ['pdf', 'ppt', 'pptx']),
  DeliverableSpec(type: 'poster', title: 'Poster', required: true, extensions: ['pdf', 'png', 'jpg', 'jpeg']),
  DeliverableSpec(type: 'raw_data', title: 'Raw data', required: false, extensions: []),
  DeliverableSpec(type: 'system_test_data', title: 'System with test data', required: false, extensions: []),
  DeliverableSpec(
    type: 'setup_instructions',
    title: 'Instructions on system setup',
    required: false,
    extensions: ['pdf', 'doc', 'docx', 'txt', 'md'],
  ),
  DeliverableSpec(type: 'executable', title: '.apk / .exe file', required: false, extensions: []),
];

final Set<String> _checklistTypes = {for (final s in fypmsDeliverableChecklist) s.type};

/// Required deliverables submitted with a file, out of the required total.
({int done, int total}) deliverableReadiness(List<FypDeliverable> items) {
  final required = [for (final s in fypmsDeliverableChecklist) if (s.required) s.type];
  final submitted = {
    for (final d in items)
      if (d.fileUrl != null && d.fileUrl!.isNotEmpty) d.deliverableType,
  };
  return (done: required.where(submitted.contains).length, total: required.length);
}

/// Submitted items that are not on the textbook checklist (e.g. older
/// "demo" / "video" entries), still shown so nothing disappears.
List<FypDeliverable> otherDeliverables(List<FypDeliverable> items) =>
    [for (final d in items) if (!_checklistTypes.contains(d.deliverableType)) d];
