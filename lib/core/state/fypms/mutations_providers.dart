import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/fypms_exhibition_evaluation.dart';
import '../../domain/fypms_users.dart';
import '../../supabase/fypms_rpc_service.dart';
import '../expo/service_providers.dart';
import 'coordinator_providers.dart';
import 'reference_data_providers.dart';
import 'record_resources_providers.dart';
import 'records_providers.dart';

// ==============================================================================
// MUTATION PROVIDERS (wrap SECURITY DEFINER RPCs; invalidate reads on success)
// ==============================================================================
// Each provider returns a callable closure. Tests override these with
// `overrideWithValue((...) async {})` to stub the RPC layer.

/// Decides a pending supervision request (approve/reject).
final decideSupervisionRequestProvider = Provider<
    Future<void> Function(String requestId, String decision, String? decisionReason)>(
  (ref) {
    return (requestId, decision, decisionReason) async {
      final rpc = ref.read(supabaseRpcServiceProvider);
      await rpc.decideSupervisionRequest(
        requestId: requestId,
        decision: decision,
        decisionReason: decisionReason,
      );
      ref.invalidate(fypPendingSupervisionRequestsProvider);
      ref.invalidate(mySupervisionRequestsProvider);
      ref.invalidate(fypRecordsProvider);
    };
  },
);

/// Validates (or rejects) a submitted progress log for a record.
final validateProgressLogProvider = Provider<
    Future<void> Function(
        String progressLogId, String status, String? validationComment, String recordId)>(
  (ref) {
    return (progressLogId, status, validationComment, recordId) async {
      final rpc = ref.read(supabaseRpcServiceProvider);
      await rpc.validateProgressLog(
        progressLogId: progressLogId,
        status: status,
        validationComment: validationComment,
      );
      ref.invalidate(fypProgressLogsProvider(recordId));
      ref.invalidate(fypRecordsProvider);
    };
  },
);

/// Assigns a supervisor/co-supervisor to a record (coordinator flow).
final assignSupervisorToFypRecordProvider = Provider<
    Future<void> Function(String fypRecordId, String supervisorId, String role)>(
  (ref) {
    return (fypRecordId, supervisorId, role) async {
      final rpc = ref.read(supabaseRpcServiceProvider);
      await rpc.assignSupervisorToFypRecord(
        fypRecordId: fypRecordId,
        supervisorId: supervisorId,
        role: role,
      );
      ref.invalidate(fypRecordAssignmentsProvider(fypRecordId));
      ref.invalidate(fypRecordsProvider);
    };
  },
);

/// Assigns an examiner to a record (CSP lecturer / coordinator flow).
final assignExaminerProvider =
    Provider<Future<void> Function(String fypRecordId, String examinerId)>(
  (ref) {
    return (fypRecordId, examinerId) async {
      final rpc = ref.read(supabaseRpcServiceProvider);
      await rpc.assignExaminer(fypRecordId: fypRecordId, examinerId: examinerId);
      ref.invalidate(fypRecordAssignmentsProvider(fypRecordId));
      ref.invalidate(fypRecordsProvider);
    };
  },
);

/// Submits a form evaluation with a decision for a record.
final submitFormEvaluationProvider = Provider<
    Future<void> Function(String formSubmissionId, Map<String, dynamic> scores,
        String? comments, String decision, String recordId)>(
  (ref) {
    return (formSubmissionId, scores, comments, decision, recordId) async {
      final rpc = ref.read(supabaseRpcServiceProvider);
      await rpc.submitFormEvaluation(
        formSubmissionId: formSubmissionId,
        scores: scores,
        comments: comments,
        decision: decision,
      );
      ref.invalidate(fypFormSubmissionsProvider(recordId));
    };
  },
);

/// Creates a correction item for a record (optionally linked to a submission).
final createCorrectionItemProvider = Provider<
    Future<void> Function(
        String fypRecordId, String? formSubmissionId, String correctionText, String severity)>(
  (ref) {
    return (fypRecordId, formSubmissionId, correctionText, severity) async {
      final rpc = ref.read(supabaseRpcServiceProvider);
      await rpc.createCorrectionItem(
        fypRecordId: fypRecordId,
        formSubmissionId: formSubmissionId,
        correctionText: correctionText,
        severity: severity,
      );
      ref.invalidate(fypCorrectionItemsProvider(fypRecordId));
    };
  },
);

/// Confirms/closes a correction item for a record.
final confirmCorrectionProvider = Provider<
    Future<void> Function(
        String correctionItemId, String confirmationStatus, String? notes, String recordId)>(
  (ref) {
    return (correctionItemId, confirmationStatus, notes, recordId) async {
      final rpc = ref.read(supabaseRpcServiceProvider);
      await rpc.confirmCorrection(
        correctionItemId: correctionItemId,
        confirmationStatus: confirmationStatus,
        notes: notes,
      );
      ref.invalidate(fypCorrectionItemsProvider(recordId));
    };
  },
);

/// Finalizes course marks for a record.
final finalizeMarksProvider = Provider<
    Future<void> Function(
        String fypRecordId, String courseCode, Map<String, dynamic> componentBreakdown)>(
  (ref) {
    return (fypRecordId, courseCode, componentBreakdown) async {
      final rpc = ref.read(supabaseRpcServiceProvider);
      await rpc.finalizeMarks(
        fypRecordId: fypRecordId,
        courseCode: courseCode,
        componentBreakdown: componentBreakdown,
      );
      ref.invalidate(fypMarksSummariesProvider(fypRecordId));
      ref.invalidate(fypRecordsProvider);
    };
  },
);

/// Finalizes a record's course marks from its evaluations.
final finalizeCourseMarksProvider = Provider<Future<void> Function(String fypRecordId)>(
  (ref) {
    return (fypRecordId) async {
      final rpc = ref.read(supabaseRpcServiceProvider);
      await rpc.finalizeFypCourseMarks(fypRecordId: fypRecordId);
      ref.invalidate(fypMarksSummariesProvider(fypRecordId));
      ref.invalidate(fypCourseMarksProvider(fypRecordId));
      ref.invalidate(fypRecordsProvider);
    };
  },
);

/// Opens (creating when needed) the F10 / F15 an evaluator scores at the
/// exhibition for an Expo project.
final openExhibitionEvaluationProvider = Provider<Future<ExhibitionEvaluation> Function(String projectId)>(
  (ref) {
    return (projectId) async {
      final rpc = ref.read(supabaseRpcServiceProvider);
      final result = ExhibitionEvaluation.fromJson(
        await rpc.getExhibitionEvaluation(projectId: projectId, create: true),
      );
      if (result.fypRecordId != null) {
        ref.invalidate(fypFormSubmissionsProvider(result.fypRecordId!));
      }
      return result;
    };
  },
);

/// Users & Roles and enrolment actions (backlog U2, U3).
final userAdminProvider = Provider<UserAdmin>((ref) => UserAdmin(ref));

class UserAdmin {
  UserAdmin(this._ref);
  final Ref _ref;

  Future<List<ManagedUser>> search(String query) async =>
      (await _ref.read(supabaseRpcServiceProvider).adminListUsers(search: query)).map(ManagedUser.fromJson).toList();

  Future<void> setRole(String profileId, String roleCode, {String programmeCode = '', required bool active}) =>
      _ref.read(supabaseRpcServiceProvider).setUserAcademicRole(
            profileId: profileId,
            roleCode: roleCode,
            programmeCode: programmeCode,
            active: active,
          );

  Future<void> setActive(String profileId, bool active) =>
      _ref.read(supabaseRpcServiceProvider).setProfileActive(profileId: profileId, active: active);

  Future<void> setAccountType(String profileId, String role) =>
      _ref.read(supabaseRpcServiceProvider).setProfileAccountRole(profileId: profileId, role: role);

  Future<List<Map<String, dynamic>>> enrol(String semesterId, String courseCode, List<EnrolmentRow> rows) async {
    final results = await _ref.read(supabaseRpcServiceProvider).enrollStudents(
          semesterId: semesterId,
          courseCode: courseCode,
          students: [for (final r in rows) r.toJson()],
        );
    _ref.invalidate(fypRecordsProvider);
    return results;
  }
}

/// Coordinator semester / course / offering management (backlog S1, S5).
final semesterAdminProvider = Provider<SemesterAdmin>((ref) => SemesterAdmin(ref));

class SemesterAdmin {
  SemesterAdmin(this._ref);
  final Ref _ref;

  Future<void> create({required String code, required String label, required DateTime start, required DateTime end}) async {
    await _ref.read(supabaseRpcServiceProvider).createAcademicSemester(code: code, label: label, startDate: start, endDate: end);
    _ref.invalidate(fypmsSemestersProvider);
  }

  Future<void> setStatus(String semesterId, String status) async {
    await _ref.read(supabaseRpcServiceProvider).setAcademicSemesterStatus(semesterId: semesterId, status: status);
    _ref.invalidate(fypmsSemestersProvider);
  }

  Future<void> updateCourse({required String code, required String name, required int creditHours, required bool isActive}) async {
    await _ref
        .read(supabaseRpcServiceProvider)
        .updateAcademicCourse(code: code, name: name, creditHours: creditHours, isActive: isActive);
    _ref.invalidate(fypmsCoursesProvider);
  }

  Future<void> saveOffering({required String semesterId, required String courseCode, String? lecturerId, int? maxStudents}) async {
    await _ref.read(supabaseRpcServiceProvider).upsertCourseOffering(
          semesterId: semesterId,
          courseCode: courseCode,
          lecturerId: lecturerId,
          maxStudents: maxStudents,
        );
    _ref.invalidate(fypmsOfferingsProvider);
  }

  /// CSP600 -> CSP650 (backlog S3).
  Future<void> promote(String fypRecordId, String targetSemesterId) async {
    await _ref.read(supabaseRpcServiceProvider).promoteFypRecord(fypRecordId: fypRecordId, targetSemesterId: targetSemesterId);
    _ref.invalidate(fypRecordsProvider);
  }
}

/// Student asks for a supervisor change.
final requestSupervisorChangeProvider =
    Provider<Future<void> Function(String fypRecordId, String reason, String? proposedSupervisorId)>(
  (ref) {
    return (fypRecordId, reason, proposedSupervisorId) async {
      final rpc = ref.read(supabaseRpcServiceProvider);
      await rpc.requestSupervisorChange(
        fypRecordId: fypRecordId,
        reason: reason,
        proposedSupervisorId: proposedSupervisorId,
      );
      ref.invalidate(fypSupervisorChangesProvider(fypRecordId));
    };
  },
);

/// Coordinator decides a supervisor change.
final decideSupervisorChangeProvider = Provider<
    Future<void> Function({
      required String requestId,
      required String fypRecordId,
      required String decision,
      String? comment,
      String? newSupervisorId,
    })>(
  (ref) {
    return ({required requestId, required fypRecordId, required decision, comment, newSupervisorId}) async {
      final rpc = ref.read(supabaseRpcServiceProvider);
      await rpc.decideSupervisorChange(
        requestId: requestId,
        decision: decision,
        comment: comment,
        newSupervisorId: newSupervisorId,
      );
      ref.invalidate(pendingSupervisorChangesProvider);
      ref.invalidate(fypSupervisorChangesProvider(fypRecordId));
      ref.invalidate(fypRecordsProvider);
    };
  },
);

/// The PU approves or rejects a nomination.
final decideNominationProvider =
    Provider<Future<void> Function(String assignmentId, String decision, String? comment)>(
  (ref) {
    return (assignmentId, decision, comment) async {
      final rpc = ref.read(supabaseRpcServiceProvider);
      await rpc.decideNomination(assignmentId: assignmentId, decision: decision, comment: comment);
      ref.invalidate(pendingNominationsProvider);
    };
  },
);

/// Student requests a milestone extension.
final requestMilestoneExtensionProvider = Provider<
    Future<void> Function({
      required String fypRecordId,
      required String milestoneId,
      required String reason,
      required DateTime requestedDueDate,
    })>(
  (ref) {
    return ({required fypRecordId, required milestoneId, required reason, required requestedDueDate}) async {
      final rpc = ref.read(supabaseRpcServiceProvider);
      await rpc.requestMilestoneExtension(
        milestoneId: milestoneId,
        reason: reason,
        requestedDueDate: requestedDueDate,
      );
      ref.invalidate(fypMilestoneExtensionsProvider(fypRecordId));
    };
  },
);

/// CSP lecturer / coordinator decides a pending extension request.
final decideMilestoneExtensionProvider = Provider<
    Future<void> Function({
      required String fypRecordId,
      required String extensionId,
      required String decision,
      String? comment,
    })>(
  (ref) {
    return ({required fypRecordId, required extensionId, required decision, comment}) async {
      final rpc = ref.read(supabaseRpcServiceProvider);
      await rpc.decideMilestoneExtension(extensionId: extensionId, decision: decision, comment: comment);
      ref.invalidate(fypMilestoneExtensionsProvider(fypRecordId));
      ref.invalidate(fypMilestonesProvider(fypRecordId));
    };
  },
);

/// Course lecturer / coordinator creates a presentation session.
final createPresentationSessionProvider = Provider<
    Future<void> Function({
      required String offeringId,
      required String sessionCode,
      required String sessionTitle,
      required DateTime startAt,
      required DateTime endAt,
      String? venue,
      String sessionType,
    })>(
  (ref) {
    return ({
      required offeringId,
      required sessionCode,
      required sessionTitle,
      required startAt,
      required endAt,
      venue,
      sessionType = 'defence',
    }) async {
      final rpc = ref.read(supabaseRpcServiceProvider);
      await rpc.createPresentationSession(
        offeringId: offeringId,
        sessionCode: sessionCode,
        sessionTitle: sessionTitle,
        startAt: startAt,
        endAt: endAt,
        venue: venue,
        sessionType: sessionType,
      );
      ref.invalidate(fypPresentationSessionsProvider);
    };
  },
);

/// Coordinator archives a record (reason kept in the audit log).
/// Withdraw / incomplete / reinstate a record and reopen finalized marks
/// (backlog F3, F4).
final recordStandingProvider = Provider<RecordStanding>((ref) => RecordStanding(ref));

class RecordStanding {
  RecordStanding(this._ref);
  final Ref _ref;

  /// [status] is 'withdrawn' or 'incomplete'.
  Future<void> hold(String fypRecordId, String status, String reason) async {
    await _ref.read(supabaseRpcServiceProvider).setFypRecordStanding(fypRecordId: fypRecordId, status: status, reason: reason);
    _ref.invalidate(fypRecordsProvider);
  }

  Future<void> reinstate(String fypRecordId, String reason) async {
    await _ref.read(supabaseRpcServiceProvider).reinstateFypRecord(fypRecordId: fypRecordId, reason: reason);
    _ref.invalidate(fypRecordsProvider);
  }

  Future<void> reopenMarks(String fypRecordId, String courseCode, String reason) async {
    await _ref
        .read(supabaseRpcServiceProvider)
        .reopenFypCourseMarks(fypRecordId: fypRecordId, courseCode: courseCode, reason: reason);
    _ref.invalidate(fypMarksSummariesProvider(fypRecordId));
  }
}

final archiveFypRecordProvider = Provider<Future<void> Function(String fypRecordId, String reason)>(
  (ref) {
    return (fypRecordId, reason) async {
      final rpc = ref.read(supabaseRpcServiceProvider);
      await rpc.archiveFypRecord(fypRecordId: fypRecordId, reason: reason);
      ref.invalidate(fypRecordsProvider);
    };
  },
);

/// Coordinator overrides one record field, with a mandatory reason.
final overrideFypRecordFieldProvider =
    Provider<Future<void> Function(String fypRecordId, String field, String value, String reason)>(
  (ref) {
    return (fypRecordId, field, value, reason) async {
      final rpc = ref.read(supabaseRpcServiceProvider);
      await rpc.adminOverrideFypRecordField(
        fypRecordId: fypRecordId,
        field: field,
        value: value,
        reason: reason,
      );
      ref.invalidate(fypRecordsProvider);
    };
  },
);

/// Records the CSP650 lecturer's F14 special-evaluation decision.
final assessSpecialEvaluationProvider = Provider<
    Future<void> Function({
      required String fypRecordId,
      required bool chaptersComplete,
      required bool presentedAtExhibition,
      required bool finalSemesterCoursesPassed,
      String? note,
    })>(
  (ref) {
    return ({
      required fypRecordId,
      required chaptersComplete,
      required presentedAtExhibition,
      required finalSemesterCoursesPassed,
      note,
    }) async {
      final rpc = ref.read(supabaseRpcServiceProvider);
      await rpc.assessSpecialEvaluation(
        fypRecordId: fypRecordId,
        chaptersComplete: chaptersComplete,
        presentedAtExhibition: presentedAtExhibition,
        finalSemesterCoursesPassed: finalSemesterCoursesPassed,
        note: note,
      );
      ref.invalidate(fypSpecialEvaluationProvider(fypRecordId));
      ref.invalidate(fypSpecialEvaluationChecksProvider(fypRecordId));
    };
  },
);

/// Coordinator re-splits the CSP600 formulation 30 % across F2 / F3 / F4.
final setCsp600FormulationSharesProvider = Provider<Future<void> Function(num f2, num f3, num f4)>(
  (ref) {
    return (f2, f3, f4) async {
      final rpc = ref.read(supabaseRpcServiceProvider);
      await rpc.setCsp600FormulationShares(f2: f2, f3: f3, f4: f4);
      ref.invalidate(fypRubricTemplatesProvider);
    };
  },
);

/// Supervisor endorses or returns an F6 report submission.
final endorseReportProvider = Provider<
    Future<void> Function(String reportId, String decision, String? comment, String recordId)>(
  (ref) {
    return (reportId, decision, comment, recordId) async {
      final rpc = ref.read(supabaseRpcServiceProvider);
      await rpc.endorseReportSubmission(reportId: reportId, decision: decision, comment: comment);
      ref.invalidate(fypReportSubmissionsProvider(recordId));
    };
  },
);

/// Schedules a presentation slot within a session.
final schedulePresentationSlotProvider = Provider<
    Future<void> Function(
        String sessionId, String fypRecordId, int slotNumber, DateTime startAt, DateTime endAt, String? room)>(
  (ref) {
    return (sessionId, fypRecordId, slotNumber, startAt, endAt, room) async {
      final rpc = ref.read(supabaseRpcServiceProvider);
      await rpc.schedulePresentationSlot(
        sessionId: sessionId,
        fypRecordId: fypRecordId,
        slotNumber: slotNumber,
        startAt: startAt,
        endAt: endAt,
        room: room,
      );
      ref.invalidate(fypPresentationSlotsProvider(sessionId));
      ref.invalidate(fypRecordsProvider);
    };
  },
);

/// Prepares an Expo publication for a record/event.
final prepareExpoPublicationProvider = Provider<
    Future<void> Function(
        String fypRecordId, String eventId, Map<String, dynamic>? payload)>(
  (ref) {
    return (fypRecordId, eventId, payload) async {
      final rpc = ref.read(supabaseRpcServiceProvider);
      await rpc.prepareExpoPublication(
        fypRecordId: fypRecordId,
        eventId: eventId,
        payload: payload,
      );
      ref.invalidate(fypExpoPublicationsProvider);
    };
  },
);

/// Publishes a prepared Expo publication.
final publishFypRecordToExpoProvider =
    Provider<Future<void> Function(String publicationId)>(
  (ref) {
    return (publicationId) async {
      final rpc = ref.read(supabaseRpcServiceProvider);
      await rpc.publishFypRecordToExpo(publicationId: publicationId);
      ref.invalidate(fypExpoPublicationsProvider);
    };
  },
);

// ==============================================================================
// REFRESH HELPER (call ref.invalidate after any successful RPC mutation)
// ==============================================================================

/// Invalidates every FYPMS provider tied to the given record so the UI
/// refreshes after a mutation. Call via `ref.invalidate(provider)` from widgets;
/// this helper is provided for convenience in tests.
void invalidateFypmsRecordProviders(Ref ref, String recordId) {
  ref.invalidate(fypRecordAssignmentsProvider(recordId));
  ref.invalidate(fypSupervisionRequestsProvider(recordId));
  ref.invalidate(fypProgressLogsProvider(recordId));
  ref.invalidate(fypFormSubmissionsProvider(recordId));
  ref.invalidate(fypReportSubmissionsProvider(recordId));
  ref.invalidate(fypDeliverablesProvider(recordId));
  ref.invalidate(fypLeanCanvasProvider(recordId));
  ref.invalidate(fypMilestonesProvider(recordId));
  ref.invalidate(fypCorrectionItemsProvider(recordId));
  ref.invalidate(fypMarksSummariesProvider(recordId));
  ref.invalidate(fypRecordsProvider);
  ref.invalidate(myFypRecordsProvider);
}
