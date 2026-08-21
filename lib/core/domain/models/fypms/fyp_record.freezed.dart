// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fyp_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FypRecord {

 String get id; String get academicSemesterId; String get studentId; String get currentCourseCode; String get programmeCode; String? get matricId; String? get projectTitle; String? get projectDescription; String? get projectType; String? get externalIndustryPartner; String? get mainSupervisorId; String? get coSupervisorId; String? get examinerId; String? get previousRecordId; String get workflowStatus; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of FypRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FypRecordCopyWith<FypRecord> get copyWith => _$FypRecordCopyWithImpl<FypRecord>(this as FypRecord, _$identity);

  /// Serializes this FypRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FypRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.academicSemesterId, academicSemesterId) || other.academicSemesterId == academicSemesterId)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.currentCourseCode, currentCourseCode) || other.currentCourseCode == currentCourseCode)&&(identical(other.programmeCode, programmeCode) || other.programmeCode == programmeCode)&&(identical(other.matricId, matricId) || other.matricId == matricId)&&(identical(other.projectTitle, projectTitle) || other.projectTitle == projectTitle)&&(identical(other.projectDescription, projectDescription) || other.projectDescription == projectDescription)&&(identical(other.projectType, projectType) || other.projectType == projectType)&&(identical(other.externalIndustryPartner, externalIndustryPartner) || other.externalIndustryPartner == externalIndustryPartner)&&(identical(other.mainSupervisorId, mainSupervisorId) || other.mainSupervisorId == mainSupervisorId)&&(identical(other.coSupervisorId, coSupervisorId) || other.coSupervisorId == coSupervisorId)&&(identical(other.examinerId, examinerId) || other.examinerId == examinerId)&&(identical(other.previousRecordId, previousRecordId) || other.previousRecordId == previousRecordId)&&(identical(other.workflowStatus, workflowStatus) || other.workflowStatus == workflowStatus)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,academicSemesterId,studentId,currentCourseCode,programmeCode,matricId,projectTitle,projectDescription,projectType,externalIndustryPartner,mainSupervisorId,coSupervisorId,examinerId,previousRecordId,workflowStatus,createdAt,updatedAt);

@override
String toString() {
  return 'FypRecord(id: $id, academicSemesterId: $academicSemesterId, studentId: $studentId, currentCourseCode: $currentCourseCode, programmeCode: $programmeCode, matricId: $matricId, projectTitle: $projectTitle, projectDescription: $projectDescription, projectType: $projectType, externalIndustryPartner: $externalIndustryPartner, mainSupervisorId: $mainSupervisorId, coSupervisorId: $coSupervisorId, examinerId: $examinerId, previousRecordId: $previousRecordId, workflowStatus: $workflowStatus, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $FypRecordCopyWith<$Res>  {
  factory $FypRecordCopyWith(FypRecord value, $Res Function(FypRecord) _then) = _$FypRecordCopyWithImpl;
@useResult
$Res call({
 String id, String academicSemesterId, String studentId, String currentCourseCode, String programmeCode, String? matricId, String? projectTitle, String? projectDescription, String? projectType, String? externalIndustryPartner, String? mainSupervisorId, String? coSupervisorId, String? examinerId, String? previousRecordId, String workflowStatus, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$FypRecordCopyWithImpl<$Res>
    implements $FypRecordCopyWith<$Res> {
  _$FypRecordCopyWithImpl(this._self, this._then);

  final FypRecord _self;
  final $Res Function(FypRecord) _then;

/// Create a copy of FypRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? academicSemesterId = null,Object? studentId = null,Object? currentCourseCode = null,Object? programmeCode = null,Object? matricId = freezed,Object? projectTitle = freezed,Object? projectDescription = freezed,Object? projectType = freezed,Object? externalIndustryPartner = freezed,Object? mainSupervisorId = freezed,Object? coSupervisorId = freezed,Object? examinerId = freezed,Object? previousRecordId = freezed,Object? workflowStatus = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,academicSemesterId: null == academicSemesterId ? _self.academicSemesterId : academicSemesterId // ignore: cast_nullable_to_non_nullable
as String,studentId: null == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String,currentCourseCode: null == currentCourseCode ? _self.currentCourseCode : currentCourseCode // ignore: cast_nullable_to_non_nullable
as String,programmeCode: null == programmeCode ? _self.programmeCode : programmeCode // ignore: cast_nullable_to_non_nullable
as String,matricId: freezed == matricId ? _self.matricId : matricId // ignore: cast_nullable_to_non_nullable
as String?,projectTitle: freezed == projectTitle ? _self.projectTitle : projectTitle // ignore: cast_nullable_to_non_nullable
as String?,projectDescription: freezed == projectDescription ? _self.projectDescription : projectDescription // ignore: cast_nullable_to_non_nullable
as String?,projectType: freezed == projectType ? _self.projectType : projectType // ignore: cast_nullable_to_non_nullable
as String?,externalIndustryPartner: freezed == externalIndustryPartner ? _self.externalIndustryPartner : externalIndustryPartner // ignore: cast_nullable_to_non_nullable
as String?,mainSupervisorId: freezed == mainSupervisorId ? _self.mainSupervisorId : mainSupervisorId // ignore: cast_nullable_to_non_nullable
as String?,coSupervisorId: freezed == coSupervisorId ? _self.coSupervisorId : coSupervisorId // ignore: cast_nullable_to_non_nullable
as String?,examinerId: freezed == examinerId ? _self.examinerId : examinerId // ignore: cast_nullable_to_non_nullable
as String?,previousRecordId: freezed == previousRecordId ? _self.previousRecordId : previousRecordId // ignore: cast_nullable_to_non_nullable
as String?,workflowStatus: null == workflowStatus ? _self.workflowStatus : workflowStatus // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [FypRecord].
extension FypRecordPatterns on FypRecord {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FypRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FypRecord() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FypRecord value)  $default,){
final _that = this;
switch (_that) {
case _FypRecord():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FypRecord value)?  $default,){
final _that = this;
switch (_that) {
case _FypRecord() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String academicSemesterId,  String studentId,  String currentCourseCode,  String programmeCode,  String? matricId,  String? projectTitle,  String? projectDescription,  String? projectType,  String? externalIndustryPartner,  String? mainSupervisorId,  String? coSupervisorId,  String? examinerId,  String? previousRecordId,  String workflowStatus,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FypRecord() when $default != null:
return $default(_that.id,_that.academicSemesterId,_that.studentId,_that.currentCourseCode,_that.programmeCode,_that.matricId,_that.projectTitle,_that.projectDescription,_that.projectType,_that.externalIndustryPartner,_that.mainSupervisorId,_that.coSupervisorId,_that.examinerId,_that.previousRecordId,_that.workflowStatus,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String academicSemesterId,  String studentId,  String currentCourseCode,  String programmeCode,  String? matricId,  String? projectTitle,  String? projectDescription,  String? projectType,  String? externalIndustryPartner,  String? mainSupervisorId,  String? coSupervisorId,  String? examinerId,  String? previousRecordId,  String workflowStatus,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _FypRecord():
return $default(_that.id,_that.academicSemesterId,_that.studentId,_that.currentCourseCode,_that.programmeCode,_that.matricId,_that.projectTitle,_that.projectDescription,_that.projectType,_that.externalIndustryPartner,_that.mainSupervisorId,_that.coSupervisorId,_that.examinerId,_that.previousRecordId,_that.workflowStatus,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String academicSemesterId,  String studentId,  String currentCourseCode,  String programmeCode,  String? matricId,  String? projectTitle,  String? projectDescription,  String? projectType,  String? externalIndustryPartner,  String? mainSupervisorId,  String? coSupervisorId,  String? examinerId,  String? previousRecordId,  String workflowStatus,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _FypRecord() when $default != null:
return $default(_that.id,_that.academicSemesterId,_that.studentId,_that.currentCourseCode,_that.programmeCode,_that.matricId,_that.projectTitle,_that.projectDescription,_that.projectType,_that.externalIndustryPartner,_that.mainSupervisorId,_that.coSupervisorId,_that.examinerId,_that.previousRecordId,_that.workflowStatus,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FypRecord implements FypRecord {
  const _FypRecord({required this.id, required this.academicSemesterId, required this.studentId, required this.currentCourseCode, required this.programmeCode, this.matricId, this.projectTitle, this.projectDescription, this.projectType, this.externalIndustryPartner, this.mainSupervisorId, this.coSupervisorId, this.examinerId, this.previousRecordId, required this.workflowStatus, required this.createdAt, required this.updatedAt});
  factory _FypRecord.fromJson(Map<String, dynamic> json) => _$FypRecordFromJson(json);

@override final  String id;
@override final  String academicSemesterId;
@override final  String studentId;
@override final  String currentCourseCode;
@override final  String programmeCode;
@override final  String? matricId;
@override final  String? projectTitle;
@override final  String? projectDescription;
@override final  String? projectType;
@override final  String? externalIndustryPartner;
@override final  String? mainSupervisorId;
@override final  String? coSupervisorId;
@override final  String? examinerId;
@override final  String? previousRecordId;
@override final  String workflowStatus;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of FypRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FypRecordCopyWith<_FypRecord> get copyWith => __$FypRecordCopyWithImpl<_FypRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FypRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FypRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.academicSemesterId, academicSemesterId) || other.academicSemesterId == academicSemesterId)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.currentCourseCode, currentCourseCode) || other.currentCourseCode == currentCourseCode)&&(identical(other.programmeCode, programmeCode) || other.programmeCode == programmeCode)&&(identical(other.matricId, matricId) || other.matricId == matricId)&&(identical(other.projectTitle, projectTitle) || other.projectTitle == projectTitle)&&(identical(other.projectDescription, projectDescription) || other.projectDescription == projectDescription)&&(identical(other.projectType, projectType) || other.projectType == projectType)&&(identical(other.externalIndustryPartner, externalIndustryPartner) || other.externalIndustryPartner == externalIndustryPartner)&&(identical(other.mainSupervisorId, mainSupervisorId) || other.mainSupervisorId == mainSupervisorId)&&(identical(other.coSupervisorId, coSupervisorId) || other.coSupervisorId == coSupervisorId)&&(identical(other.examinerId, examinerId) || other.examinerId == examinerId)&&(identical(other.previousRecordId, previousRecordId) || other.previousRecordId == previousRecordId)&&(identical(other.workflowStatus, workflowStatus) || other.workflowStatus == workflowStatus)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,academicSemesterId,studentId,currentCourseCode,programmeCode,matricId,projectTitle,projectDescription,projectType,externalIndustryPartner,mainSupervisorId,coSupervisorId,examinerId,previousRecordId,workflowStatus,createdAt,updatedAt);

@override
String toString() {
  return 'FypRecord(id: $id, academicSemesterId: $academicSemesterId, studentId: $studentId, currentCourseCode: $currentCourseCode, programmeCode: $programmeCode, matricId: $matricId, projectTitle: $projectTitle, projectDescription: $projectDescription, projectType: $projectType, externalIndustryPartner: $externalIndustryPartner, mainSupervisorId: $mainSupervisorId, coSupervisorId: $coSupervisorId, examinerId: $examinerId, previousRecordId: $previousRecordId, workflowStatus: $workflowStatus, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$FypRecordCopyWith<$Res> implements $FypRecordCopyWith<$Res> {
  factory _$FypRecordCopyWith(_FypRecord value, $Res Function(_FypRecord) _then) = __$FypRecordCopyWithImpl;
@override @useResult
$Res call({
 String id, String academicSemesterId, String studentId, String currentCourseCode, String programmeCode, String? matricId, String? projectTitle, String? projectDescription, String? projectType, String? externalIndustryPartner, String? mainSupervisorId, String? coSupervisorId, String? examinerId, String? previousRecordId, String workflowStatus, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$FypRecordCopyWithImpl<$Res>
    implements _$FypRecordCopyWith<$Res> {
  __$FypRecordCopyWithImpl(this._self, this._then);

  final _FypRecord _self;
  final $Res Function(_FypRecord) _then;

/// Create a copy of FypRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? academicSemesterId = null,Object? studentId = null,Object? currentCourseCode = null,Object? programmeCode = null,Object? matricId = freezed,Object? projectTitle = freezed,Object? projectDescription = freezed,Object? projectType = freezed,Object? externalIndustryPartner = freezed,Object? mainSupervisorId = freezed,Object? coSupervisorId = freezed,Object? examinerId = freezed,Object? previousRecordId = freezed,Object? workflowStatus = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_FypRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,academicSemesterId: null == academicSemesterId ? _self.academicSemesterId : academicSemesterId // ignore: cast_nullable_to_non_nullable
as String,studentId: null == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String,currentCourseCode: null == currentCourseCode ? _self.currentCourseCode : currentCourseCode // ignore: cast_nullable_to_non_nullable
as String,programmeCode: null == programmeCode ? _self.programmeCode : programmeCode // ignore: cast_nullable_to_non_nullable
as String,matricId: freezed == matricId ? _self.matricId : matricId // ignore: cast_nullable_to_non_nullable
as String?,projectTitle: freezed == projectTitle ? _self.projectTitle : projectTitle // ignore: cast_nullable_to_non_nullable
as String?,projectDescription: freezed == projectDescription ? _self.projectDescription : projectDescription // ignore: cast_nullable_to_non_nullable
as String?,projectType: freezed == projectType ? _self.projectType : projectType // ignore: cast_nullable_to_non_nullable
as String?,externalIndustryPartner: freezed == externalIndustryPartner ? _self.externalIndustryPartner : externalIndustryPartner // ignore: cast_nullable_to_non_nullable
as String?,mainSupervisorId: freezed == mainSupervisorId ? _self.mainSupervisorId : mainSupervisorId // ignore: cast_nullable_to_non_nullable
as String?,coSupervisorId: freezed == coSupervisorId ? _self.coSupervisorId : coSupervisorId // ignore: cast_nullable_to_non_nullable
as String?,examinerId: freezed == examinerId ? _self.examinerId : examinerId // ignore: cast_nullable_to_non_nullable
as String?,previousRecordId: freezed == previousRecordId ? _self.previousRecordId : previousRecordId // ignore: cast_nullable_to_non_nullable
as String?,workflowStatus: null == workflowStatus ? _self.workflowStatus : workflowStatus // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
