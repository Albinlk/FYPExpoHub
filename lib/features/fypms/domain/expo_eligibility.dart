import '../../../core/domain/models/fypms/fyp_record.dart';

/// Records that may be published to an exhibition: CSP650 only (the
/// exhibition is the CSP650 final presentation in the FSKM handbook) and, when
/// the exhibition is linked to a semester, only that semester's cohort. The
/// server applies the same rule in `publish_fyp_record_to_expo`.
List<FypRecord> exhibitableRecords(List<FypRecord> records, {String? eventSemesterId}) => [
      for (final r in records)
        if (r.currentCourseCode == 'CSP650' && (eventSemesterId == null || r.academicSemesterId == eventSemesterId)) r,
    ];
