/// Printable appointment letters for approved supervisor / examiner
/// nominations (backlog F7). The HTML opens in a browser and prints (or
/// saves as PDF) one letter per page.
library;

import 'fypms_supervisor_change.dart';

String _esc(String? s) => (s ?? '')
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;');

const _months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October',
  'November', 'December'];

String _date(DateTime? d) {
  if (d == null) return '';
  final l = d.toLocal();
  return '${l.day} ${_months[l.month - 1]} ${l.year}';
}

String _duty(PendingNomination n) => switch (n.academicRole) {
      'examiner' => 'evaluate the project’s proposal / final report and presentation using the faculty rubrics, '
          'and record the marks in FYPMS by the published deadlines',
      'co_supervisor' => 'assist the main supervisor in guiding the student and take part in the supervisor evaluations '
          'assigned to the co-supervisor',
      _ => 'guide the student through the project, hold regular consultations, endorse submissions and complete the '
          'supervisor evaluations in FYPMS by the published deadlines',
    };

String _letterBody(PendingNomination n) => '''
<section class="letter">
  <header>
    <div class="faculty">Faculty of Computer and Mathematical Sciences<br>Universiti Teknologi MARA</div>
    <div class="date">${_esc(_date(n.decidedAt))}</div>
  </header>
  <p class="to">${_esc(n.lecturerName)}${n.lecturerEmail == null ? '' : '<br>${_esc(n.lecturerEmail)}'}</p>
  <h1>Appointment as ${_esc(n.roleLabel)} — Final Year Project</h1>
  <p>We are pleased to appoint you as <strong>${_esc(n.roleLabel.toLowerCase())}</strong> for the final year project below${n.semesterLabel == null ? '' : ' in ${_esc(n.semesterLabel)}'}.</p>
  <table>
    <tr><th>Student</th><td>${_esc(n.studentName)}${n.matricId == null ? '' : ' (${_esc(n.matricId)})'}</td></tr>
    <tr><th>Programme</th><td>${_esc(n.programmeCode)}</td></tr>
    <tr><th>Course</th><td>${_esc(n.courseCode)}</td></tr>
    <tr><th>Project title</th><td>${_esc(n.projectTitle ?? 'To be confirmed')}</td></tr>
  </table>
  <p>In this role you are asked to ${_duty(n)}.</p>
  <p>Thank you for your commitment to our students.</p>
  <p class="sign">${_esc(n.decidedByName ?? 'Programme Head')}<br>Programme Head${n.programmeCode == null ? '' : ', ${_esc(n.programmeCode)}'}</p>
  <p class="note">Approved in FYPMS on ${_esc(_date(n.decidedAt))}. Reference ${_esc(n.assignmentId)}.</p>
</section>''';

/// One HTML document holding a letter per nomination.
String appointmentLettersHtml(List<PendingNomination> nominations) => '''
<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>Appointment letters</title>
<style>
  @page { size: A4; margin: 18mm; }
  body { font-family: Georgia, 'Times New Roman', serif; color: #111; margin: 0; overflow-wrap: anywhere; }
  .letter { max-width: 720px; margin: 40px auto; padding: 0 32px; page-break-after: always; }
  .letter:last-child { page-break-after: auto; }
  header { display: flex; justify-content: space-between; border-bottom: 2px solid #4b2e83; padding-bottom: 12px; }
  .faculty { font-weight: bold; }
  h1 { font-size: 20px; margin: 24px 0 12px; }
  table { border-collapse: collapse; width: 100%; margin: 12px 0; break-inside: avoid; }
  th, td { text-align: left; padding: 6px 8px; border: 1px solid #ccc; vertical-align: top; }
  th { width: 30%; background: #f4f1fa; }
  .sign { margin-top: 48px; break-inside: avoid; }
  .note { font-size: 12px; color: #555; margin-top: 32px; }
  th { -webkit-print-color-adjust: exact; print-color-adjust: exact; }
  header { -webkit-print-color-adjust: exact; print-color-adjust: exact; }
  @media print { .letter { margin: 0 auto; padding: 0; } }
</style></head><body>
${nominations.map(_letterBody).join('\n')}
</body></html>
''';

/// File name for one letter, e.g. `appointment_examiner_2026123456.html`.
String appointmentLetterFileName(PendingNomination n) =>
    'appointment_${n.academicRole}_${(n.matricId ?? n.assignmentId).replaceAll(RegExp(r'[^A-Za-z0-9]'), '')}.html';
