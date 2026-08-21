import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_academic_role.freezed.dart';
part 'profile_academic_role.g.dart';

@freezed
abstract class ProfileAcademicRole with _$ProfileAcademicRole {
  const factory ProfileAcademicRole({
    required String id,
    required String profileId,
    required String roleCode, // 'student', 'supervisor', 'co_supervisor', 'examiner', 'csp600_lecturer', 'csp650_lecturer', 'fyp_coordinator'
    required String programmeCode,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ProfileAcademicRole;

  factory ProfileAcademicRole.fromJson(Map<String, dynamic> json) =>
      _$ProfileAcademicRoleFromJson(json);
}