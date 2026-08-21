// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fyp_report_submission.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FypReportSubmission {

 String get id; String get fypRecordId; String get reportType;// 'proposal', 'final'
 int get version; String get fileUrl; double? get similarityIndex; String get status;// 'submitted', 'under_review', 'approved', 'rejected'
 String? get submittedBy; DateTime get submittedAt; String? get reviewedBy; DateTime? get reviewedAt; String? get reviewComment; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of FypReportSubmission
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FypReportSubmissionCopyWith<FypReportSubmission> get copyWith => _$FypReportSubmissionCopyWithImpl<FypReportSubmission>(this as FypReportSubmission, _$identity);

  /// Serializes this FypReportSubmission to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FypReportSubmission&&(identical(other.id, id) || other.id == id)&&(identical(other.fypRecordId, fypRecordId) || other.fypRecordId == fypRecordId)&&(identical(other.reportType, reportType) || other.reportType == reportType)&&(identical(other.version, version) || other.version == version)&&(identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl)&&(identical(other.similarityIndex, similarityIndex) || other.similarityIndex == similarityIndex)&&(identical(other.status, status) || other.status == status)&&(identical(other.submittedBy, submittedBy) || other.submittedBy == submittedBy)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.reviewedBy, reviewedBy) || other.reviewedBy == reviewedBy)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.reviewComment, reviewComment) || other.reviewComment == reviewComment)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fypRecordId,reportType,version,fileUrl,similarityIndex,status,submittedBy,submittedAt,reviewedBy,reviewedAt,reviewComment,createdAt,updatedAt);

@override
String toString() {
  return 'FypReportSubmission(id: $id, fypRecordId: $fypRecordId, reportType: $reportType, version: $version, fileUrl: $fileUrl, similarityIndex: $similarityIndex, status: $status, submittedBy: $submittedBy, submittedAt: $submittedAt, reviewedBy: $reviewedBy, reviewedAt: $reviewedAt, reviewComment: $reviewComment, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $FypReportSubmissionCopyWith<$Res>  {
  factory $FypReportSubmissionCopyWith(FypReportSubmission value, $Res Function(FypReportSubmission) _then) = _$FypReportSubmissionCopyWithImpl;
@useResult
$Res call({
 String id, String fypRecordId, String reportType, int version, String fileUrl, double? similarityIndex, String status, String? submittedBy, DateTime submittedAt, String? reviewedBy, DateTime? reviewedAt, String? reviewComment, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$FypReportSubmissionCopyWithImpl<$Res>
    implements $FypReportSubmissionCopyWith<$Res> {
  _$FypReportSubmissionCopyWithImpl(this._self, this._then);

  final FypReportSubmission _self;
  final $Res Function(FypReportSubmission) _then;

/// Create a copy of FypReportSubmission
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fypRecordId = null,Object? reportType = null,Object? version = null,Object? fileUrl = null,Object? similarityIndex = freezed,Object? status = null,Object? submittedBy = freezed,Object? submittedAt = null,Object? reviewedBy = freezed,Object? reviewedAt = freezed,Object? reviewComment = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fypRecordId: null == fypRecordId ? _self.fypRecordId : fypRecordId // ignore: cast_nullable_to_non_nullable
as String,reportType: null == reportType ? _self.reportType : reportType // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,fileUrl: null == fileUrl ? _self.fileUrl : fileUrl // ignore: cast_nullable_to_non_nullable
as String,similarityIndex: freezed == similarityIndex ? _self.similarityIndex : similarityIndex // ignore: cast_nullable_to_non_nullable
as double?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,submittedBy: freezed == submittedBy ? _self.submittedBy : submittedBy // ignore: cast_nullable_to_non_nullable
as String?,submittedAt: null == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime,reviewedBy: freezed == reviewedBy ? _self.reviewedBy : reviewedBy // ignore: cast_nullable_to_non_nullable
as String?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reviewComment: freezed == reviewComment ? _self.reviewComment : reviewComment // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [FypReportSubmission].
extension FypReportSubmissionPatterns on FypReportSubmission {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FypReportSubmission value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FypReportSubmission() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FypReportSubmission value)  $default,){
final _that = this;
switch (_that) {
case _FypReportSubmission():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FypReportSubmission value)?  $default,){
final _that = this;
switch (_that) {
case _FypReportSubmission() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fypRecordId,  String reportType,  int version,  String fileUrl,  double? similarityIndex,  String status,  String? submittedBy,  DateTime submittedAt,  String? reviewedBy,  DateTime? reviewedAt,  String? reviewComment,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FypReportSubmission() when $default != null:
return $default(_that.id,_that.fypRecordId,_that.reportType,_that.version,_that.fileUrl,_that.similarityIndex,_that.status,_that.submittedBy,_that.submittedAt,_that.reviewedBy,_that.reviewedAt,_that.reviewComment,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fypRecordId,  String reportType,  int version,  String fileUrl,  double? similarityIndex,  String status,  String? submittedBy,  DateTime submittedAt,  String? reviewedBy,  DateTime? reviewedAt,  String? reviewComment,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _FypReportSubmission():
return $default(_that.id,_that.fypRecordId,_that.reportType,_that.version,_that.fileUrl,_that.similarityIndex,_that.status,_that.submittedBy,_that.submittedAt,_that.reviewedBy,_that.reviewedAt,_that.reviewComment,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fypRecordId,  String reportType,  int version,  String fileUrl,  double? similarityIndex,  String status,  String? submittedBy,  DateTime submittedAt,  String? reviewedBy,  DateTime? reviewedAt,  String? reviewComment,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _FypReportSubmission() when $default != null:
return $default(_that.id,_that.fypRecordId,_that.reportType,_that.version,_that.fileUrl,_that.similarityIndex,_that.status,_that.submittedBy,_that.submittedAt,_that.reviewedBy,_that.reviewedAt,_that.reviewComment,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FypReportSubmission implements FypReportSubmission {
  const _FypReportSubmission({required this.id, required this.fypRecordId, required this.reportType, required this.version, required this.fileUrl, this.similarityIndex, required this.status, this.submittedBy, required this.submittedAt, this.reviewedBy, this.reviewedAt, this.reviewComment, required this.createdAt, required this.updatedAt});
  factory _FypReportSubmission.fromJson(Map<String, dynamic> json) => _$FypReportSubmissionFromJson(json);

@override final  String id;
@override final  String fypRecordId;
@override final  String reportType;
// 'proposal', 'final'
@override final  int version;
@override final  String fileUrl;
@override final  double? similarityIndex;
@override final  String status;
// 'submitted', 'under_review', 'approved', 'rejected'
@override final  String? submittedBy;
@override final  DateTime submittedAt;
@override final  String? reviewedBy;
@override final  DateTime? reviewedAt;
@override final  String? reviewComment;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of FypReportSubmission
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FypReportSubmissionCopyWith<_FypReportSubmission> get copyWith => __$FypReportSubmissionCopyWithImpl<_FypReportSubmission>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FypReportSubmissionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FypReportSubmission&&(identical(other.id, id) || other.id == id)&&(identical(other.fypRecordId, fypRecordId) || other.fypRecordId == fypRecordId)&&(identical(other.reportType, reportType) || other.reportType == reportType)&&(identical(other.version, version) || other.version == version)&&(identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl)&&(identical(other.similarityIndex, similarityIndex) || other.similarityIndex == similarityIndex)&&(identical(other.status, status) || other.status == status)&&(identical(other.submittedBy, submittedBy) || other.submittedBy == submittedBy)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.reviewedBy, reviewedBy) || other.reviewedBy == reviewedBy)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.reviewComment, reviewComment) || other.reviewComment == reviewComment)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fypRecordId,reportType,version,fileUrl,similarityIndex,status,submittedBy,submittedAt,reviewedBy,reviewedAt,reviewComment,createdAt,updatedAt);

@override
String toString() {
  return 'FypReportSubmission(id: $id, fypRecordId: $fypRecordId, reportType: $reportType, version: $version, fileUrl: $fileUrl, similarityIndex: $similarityIndex, status: $status, submittedBy: $submittedBy, submittedAt: $submittedAt, reviewedBy: $reviewedBy, reviewedAt: $reviewedAt, reviewComment: $reviewComment, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$FypReportSubmissionCopyWith<$Res> implements $FypReportSubmissionCopyWith<$Res> {
  factory _$FypReportSubmissionCopyWith(_FypReportSubmission value, $Res Function(_FypReportSubmission) _then) = __$FypReportSubmissionCopyWithImpl;
@override @useResult
$Res call({
 String id, String fypRecordId, String reportType, int version, String fileUrl, double? similarityIndex, String status, String? submittedBy, DateTime submittedAt, String? reviewedBy, DateTime? reviewedAt, String? reviewComment, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$FypReportSubmissionCopyWithImpl<$Res>
    implements _$FypReportSubmissionCopyWith<$Res> {
  __$FypReportSubmissionCopyWithImpl(this._self, this._then);

  final _FypReportSubmission _self;
  final $Res Function(_FypReportSubmission) _then;

/// Create a copy of FypReportSubmission
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fypRecordId = null,Object? reportType = null,Object? version = null,Object? fileUrl = null,Object? similarityIndex = freezed,Object? status = null,Object? submittedBy = freezed,Object? submittedAt = null,Object? reviewedBy = freezed,Object? reviewedAt = freezed,Object? reviewComment = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_FypReportSubmission(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fypRecordId: null == fypRecordId ? _self.fypRecordId : fypRecordId // ignore: cast_nullable_to_non_nullable
as String,reportType: null == reportType ? _self.reportType : reportType // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,fileUrl: null == fileUrl ? _self.fileUrl : fileUrl // ignore: cast_nullable_to_non_nullable
as String,similarityIndex: freezed == similarityIndex ? _self.similarityIndex : similarityIndex // ignore: cast_nullable_to_non_nullable
as double?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,submittedBy: freezed == submittedBy ? _self.submittedBy : submittedBy // ignore: cast_nullable_to_non_nullable
as String?,submittedAt: null == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime,reviewedBy: freezed == reviewedBy ? _self.reviewedBy : reviewedBy // ignore: cast_nullable_to_non_nullable
as String?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reviewComment: freezed == reviewComment ? _self.reviewComment : reviewComment // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
