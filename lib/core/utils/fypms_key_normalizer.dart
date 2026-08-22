const _snakeToCamel = <String, String>{
  // FYPMS
  'profile_id': 'profileId',
  'role_code': 'roleCode',
  'is_active': 'isActive',
  'start_date': 'startDate',
  'end_date': 'endDate',
  'credit_hours': 'creditHours',
  'academic_semester_id': 'academicSemesterId',
  'course_code': 'courseCode',
  'current_course_code': 'currentCourseCode',
  'max_students': 'maxStudents',
  'student_id': 'studentId',
  'project_title': 'projectTitle',
  'project_description': 'projectDescription',
  'project_type': 'projectType',
  'external_industry_partner': 'externalIndustryPartner',
  'main_supervisor_id': 'mainSupervisorId',
  'co_supervisor_id': 'coSupervisorId',
  'examiner_id': 'examinerId',
  'previous_record_id': 'previousRecordId',
  'workflow_status': 'workflowStatus',
  'fyp_record_id': 'fypRecordId',
  'academic_role': 'academicRole',
  'milestone_code': 'milestoneCode',
  'milestone_title': 'milestoneTitle',
  'target_date': 'targetDate',
  'completed_at': 'completedAt',
  'milestone_id': 'milestoneId',
  'requested_by': 'requestedBy',
  'requested_due_date': 'requestedDueDate',
  'decided_by': 'decidedBy',
  'decided_at': 'decidedAt',
  'decision_comment': 'decisionComment',
  'preferred_supervisor_id': 'preferredSupervisorId',
  'decision_reason': 'decisionReason',
  'week_number': 'weekNumber',
  'progress_date': 'progressDate',
  'next_plan': 'nextPlan',
  'submitted_by': 'submittedBy',
  'submitted_at': 'submittedAt',
  'validated_by': 'validatedBy',
  'validated_at': 'validatedAt',
  'validation_comment': 'validationComment',
  'form_code': 'formCode',
  'form_version': 'formVersion',
  'rubric_template_id': 'rubricTemplateId',
  'evaluator_id': 'evaluatorId',
  'weighted_total': 'weightedTotal',
  'evaluated_at': 'evaluatedAt',
  'rubric_code': 'rubricCode',
  'rubric_name': 'rubricName',
  'report_type': 'reportType',
  'file_url': 'fileUrl',
  'similarity_index': 'similarityIndex',
  'reviewed_by': 'reviewedBy',
  'reviewed_at': 'reviewedAt',
  'review_comment': 'reviewComment',
  'deliverable_type': 'deliverableType',
  'is_required': 'isRequired',
  'canvas_version': 'canvasVersion',
  'is_latest': 'isLatest',
  'item_code': 'itemCode',
  'created_by': 'createdBy',
  'correction_item_id': 'correctionItemId',
  'confirmed_by': 'confirmedBy',
  'confirmed_at': 'confirmedAt',
  'offering_id': 'offeringId',
  'session_code': 'sessionCode',
  'session_title': 'sessionTitle',
  'event_date': 'eventDate',
  'session_type': 'sessionType',
  'session_id': 'sessionId',
  'slot_number': 'slotNumber',
  'is_finalized': 'isFinalized',
  'finalized_by': 'finalizedBy',
  'finalized_at': 'finalizedAt',
  'export_payload': 'exportPayload',
  'published_project_id': 'publishedProjectId',
  'prepared_by': 'preparedBy',
  'prepared_at': 'preparedAt',
  'published_by': 'publishedBy',
  'actor_uid': 'actorUid',
  'actor_role': 'actorRole',
  'target_type': 'targetType',
  'target_id': 'targetId',
  'metadata_safe': 'metadataSafe',
  // Expo Hub (shared)
  'event_id': 'eventId',
  'matric_id': 'matricId',
  'programme_code': 'programmeCode',
  'programme_name': 'programmeName',
  'short_description': 'shortDescription',
  'tech_tags': 'technologyTags',
  'technology_tags': 'technologyTags',
  'booth_id': 'boothId',
  'booth_number': 'boothNumber',
  'booth_zone': 'boothZone',
  'presentation_day': 'presentationDay',
  'cover_image_url': 'coverImageUrl',
  'poster_url': 'posterUrl',
  'team_display_names': 'teamDisplayNames',
  'team_display_name': 'teamDisplayNames',
  'student_team': 'teamDisplayNames',
  'supervisor_display_name': 'supervisorDisplayName',
  'examiner_display_name': 'examinerDisplayName',
  'demo_url': 'demoUrl',
  'video_url': 'videoUrl',
  'repository_url': 'repositoryUrl',
  'calon_industri': 'calonIndustri',
  'industry_candidate': 'calonIndustri',
  'publication_status': 'publicationStatus',
  'created_at': 'createdAt',
  'updated_at': 'updatedAt',
  'published_at': 'publishedAt',
  'start_at': 'startAt',
  'end_at': 'endAt',
  'session_label': 'sessionLabel',
  'daily_hours': 'dailyHours',
  'location_details': 'locationDetails',
  'map_url': 'mapUrl',
  'hero_image_url': 'heroImageUrl',
  'public_contact_email': 'publicContactEmail',
  'faq_items': 'faqItems',
  'location_note': 'locationNote',
  'static_floor_plan_url': 'staticFloorPlanUrl',
  'floor_plan_url': 'staticFloorPlanUrl',
  'project_id': 'projectId',
  'linked_project_id': 'projectId',
  'is_pinned': 'pinned',
  'award_category_id': 'awardCategoryId',
  'category_id': 'awardCategoryId',
  'lecturer_id': 'lecturerId',
  'lecturer_display_name': 'lecturerDisplayName',
  'lecturer_email': 'lecturerEmail',
  'assigned_at': 'assignedAt',
  'visit_role': 'visitRole',
  'visited_at': 'visitedAt',
  'visit_note': 'visitNote',
  'voided_at': 'voidedAt',
  'voided_by': 'voidedBy',
  'void_reason': 'voidReason',
  'user_id': 'userId',
  'admin_note': 'adminNote',
  'source_file_name': 'sourceFileName',
  'file_name': 'sourceFileName',
  'file_size_bytes': 'fileSizeBytes',
  'uploaded_by': 'uploadedBy',
  'uploaded_at': 'uploadedAt',
};

/// Generic normalizer for any Supabase row (FYPMS + Expo Hub).
Map<String, dynamic> normalizeKeys(Map<String, dynamic> data) {
  final res = <String, dynamic>{};
  data.forEach((k, v) {
    final key = _snakeToCamel[k] ?? k;
    if (key == 'teamDisplayNames') {
      if (v is String) {
        // Skip string if we already have a proper list from student_team
        if (res.containsKey(key) && res[key] is List && (res[key] as List).isNotEmpty) {
          // Keep existing list (student_team is authoritative)
        } else {
          final s = v.trim();
          // Fix malformed '["NAME"]' stored in team_display_name (legacy Supabase seed)
          if (s.startsWith('[') && s.endsWith(']')) {
            final cleaned = s
                .replaceAll('[', '')
                .replaceAll(']', '')
                .replaceAll('"', '')
                .replaceAll("'", '')
                .trim();
            if (cleaned.isEmpty) {
              res[key] = <String>[];
            } else {
              // comma-separated if multiple
              res[key] = cleaned.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
            }
          } else if (s.isEmpty) {
            res[key] = <String>[];
          } else {
            res[key] = [s];
          }
        }
      } else if (v is List) {
        // student_team jsonb array - preferred source, overwrites malformed string
        final list = v.cast<String>().map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        res[key] = list;
      } else if (v == null) {
        res[key] ??= <String>[];
      }
    } else if (key == 'technologyTags' && v is List) {
      res[key] = v.cast<String>();
    } else {
      res[key] = v;
    }
  });
  // Ensure teamDisplayNames always has a value (empty list if missing)
  res.putIfAbsent('teamDisplayNames', () => <String>[]);
  return res;
}

/// Normalizes PostgreSQL snake_case column names to Dart camelCase for all
/// FYPMS tables. Kept for backwards compatibility — delegates to [normalizeKeys].
Map<String, dynamic> normalizeFypmsKeys(Map<String, dynamic> data) {
  return normalizeKeys(data);
}