// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fyp_progress_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FypProgressLog {

 String get id; String get fypRecordId; int get weekNumber; DateTime get progressDate; String get summary; String? get challenges; String? get nextPlan; String get status;// 'draft', 'submitted', 'validated', 'rejected'
 String? get submittedBy; DateTime? get submittedAt; String? get validatedBy; DateTime? get validatedAt; String? get validationComment; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of FypProgressLog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FypProgressLogCopyWith<FypProgressLog> get copyWith => _$FypProgressLogCopyWithImpl<FypProgressLog>(this as FypProgressLog, _$identity);

  /// Serializes this FypProgressLog to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FypProgressLog&&(identical(other.id, id) || other.id == id)&&(identical(other.fypRecordId, fypRecordId) || other.fypRecordId == fypRecordId)&&(identical(other.weekNumber, weekNumber) || other.weekNumber == weekNumber)&&(identical(other.progressDate, progressDate) || other.progressDate == progressDate)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.challenges, challenges) || other.challenges == challenges)&&(identical(other.nextPlan, nextPlan) || other.nextPlan == nextPlan)&&(identical(other.status, status) || other.status == status)&&(identical(other.submittedBy, submittedBy) || other.submittedBy == submittedBy)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.validatedBy, validatedBy) || other.validatedBy == validatedBy)&&(identical(other.validatedAt, validatedAt) || other.validatedAt == validatedAt)&&(identical(other.validationComment, validationComment) || other.validationComment == validationComment)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fypRecordId,weekNumber,progressDate,summary,challenges,nextPlan,status,submittedBy,submittedAt,validatedBy,validatedAt,validationComment,createdAt,updatedAt);

@override
String toString() {
  return 'FypProgressLog(id: $id, fypRecordId: $fypRecordId, weekNumber: $weekNumber, progressDate: $progressDate, summary: $summary, challenges: $challenges, nextPlan: $nextPlan, status: $status, submittedBy: $submittedBy, submittedAt: $submittedAt, validatedBy: $validatedBy, validatedAt: $validatedAt, validationComment: $validationComment, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $FypProgressLogCopyWith<$Res>  {
  factory $FypProgressLogCopyWith(FypProgressLog value, $Res Function(FypProgressLog) _then) = _$FypProgressLogCopyWithImpl;
@useResult
$Res call({
 String id, String fypRecordId, int weekNumber, DateTime progressDate, String summary, String? challenges, String? nextPlan, String status, String? submittedBy, DateTime? submittedAt, String? validatedBy, DateTime? validatedAt, String? validationComment, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$FypProgressLogCopyWithImpl<$Res>
    implements $FypProgressLogCopyWith<$Res> {
  _$FypProgressLogCopyWithImpl(this._self, this._then);

  final FypProgressLog _self;
  final $Res Function(FypProgressLog) _then;

/// Create a copy of FypProgressLog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fypRecordId = null,Object? weekNumber = null,Object? progressDate = null,Object? summary = null,Object? challenges = freezed,Object? nextPlan = freezed,Object? status = null,Object? submittedBy = freezed,Object? submittedAt = freezed,Object? validatedBy = freezed,Object? validatedAt = freezed,Object? validationComment = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fypRecordId: null == fypRecordId ? _self.fypRecordId : fypRecordId // ignore: cast_nullable_to_non_nullable
as String,weekNumber: null == weekNumber ? _self.weekNumber : weekNumber // ignore: cast_nullable_to_non_nullable
as int,progressDate: null == progressDate ? _self.progressDate : progressDate // ignore: cast_nullable_to_non_nullable
as DateTime,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,challenges: freezed == challenges ? _self.challenges : challenges // ignore: cast_nullable_to_non_nullable
as String?,nextPlan: freezed == nextPlan ? _self.nextPlan : nextPlan // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,submittedBy: freezed == submittedBy ? _self.submittedBy : submittedBy // ignore: cast_nullable_to_non_nullable
as String?,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,validatedBy: freezed == validatedBy ? _self.validatedBy : validatedBy // ignore: cast_nullable_to_non_nullable
as String?,validatedAt: freezed == validatedAt ? _self.validatedAt : validatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,validationComment: freezed == validationComment ? _self.validationComment : validationComment // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [FypProgressLog].
extension FypProgressLogPatterns on FypProgressLog {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FypProgressLog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FypProgressLog() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FypProgressLog value)  $default,){
final _that = this;
switch (_that) {
case _FypProgressLog():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FypProgressLog value)?  $default,){
final _that = this;
switch (_that) {
case _FypProgressLog() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fypRecordId,  int weekNumber,  DateTime progressDate,  String summary,  String? challenges,  String? nextPlan,  String status,  String? submittedBy,  DateTime? submittedAt,  String? validatedBy,  DateTime? validatedAt,  String? validationComment,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FypProgressLog() when $default != null:
return $default(_that.id,_that.fypRecordId,_that.weekNumber,_that.progressDate,_that.summary,_that.challenges,_that.nextPlan,_that.status,_that.submittedBy,_that.submittedAt,_that.validatedBy,_that.validatedAt,_that.validationComment,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fypRecordId,  int weekNumber,  DateTime progressDate,  String summary,  String? challenges,  String? nextPlan,  String status,  String? submittedBy,  DateTime? submittedAt,  String? validatedBy,  DateTime? validatedAt,  String? validationComment,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _FypProgressLog():
return $default(_that.id,_that.fypRecordId,_that.weekNumber,_that.progressDate,_that.summary,_that.challenges,_that.nextPlan,_that.status,_that.submittedBy,_that.submittedAt,_that.validatedBy,_that.validatedAt,_that.validationComment,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fypRecordId,  int weekNumber,  DateTime progressDate,  String summary,  String? challenges,  String? nextPlan,  String status,  String? submittedBy,  DateTime? submittedAt,  String? validatedBy,  DateTime? validatedAt,  String? validationComment,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _FypProgressLog() when $default != null:
return $default(_that.id,_that.fypRecordId,_that.weekNumber,_that.progressDate,_that.summary,_that.challenges,_that.nextPlan,_that.status,_that.submittedBy,_that.submittedAt,_that.validatedBy,_that.validatedAt,_that.validationComment,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FypProgressLog implements FypProgressLog {
  const _FypProgressLog({required this.id, required this.fypRecordId, required this.weekNumber, required this.progressDate, required this.summary, this.challenges, this.nextPlan, required this.status, this.submittedBy, this.submittedAt, this.validatedBy, this.validatedAt, this.validationComment, required this.createdAt, required this.updatedAt});
  factory _FypProgressLog.fromJson(Map<String, dynamic> json) => _$FypProgressLogFromJson(json);

@override final  String id;
@override final  String fypRecordId;
@override final  int weekNumber;
@override final  DateTime progressDate;
@override final  String summary;
@override final  String? challenges;
@override final  String? nextPlan;
@override final  String status;
// 'draft', 'submitted', 'validated', 'rejected'
@override final  String? submittedBy;
@override final  DateTime? submittedAt;
@override final  String? validatedBy;
@override final  DateTime? validatedAt;
@override final  String? validationComment;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of FypProgressLog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FypProgressLogCopyWith<_FypProgressLog> get copyWith => __$FypProgressLogCopyWithImpl<_FypProgressLog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FypProgressLogToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FypProgressLog&&(identical(other.id, id) || other.id == id)&&(identical(other.fypRecordId, fypRecordId) || other.fypRecordId == fypRecordId)&&(identical(other.weekNumber, weekNumber) || other.weekNumber == weekNumber)&&(identical(other.progressDate, progressDate) || other.progressDate == progressDate)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.challenges, challenges) || other.challenges == challenges)&&(identical(other.nextPlan, nextPlan) || other.nextPlan == nextPlan)&&(identical(other.status, status) || other.status == status)&&(identical(other.submittedBy, submittedBy) || other.submittedBy == submittedBy)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.validatedBy, validatedBy) || other.validatedBy == validatedBy)&&(identical(other.validatedAt, validatedAt) || other.validatedAt == validatedAt)&&(identical(other.validationComment, validationComment) || other.validationComment == validationComment)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fypRecordId,weekNumber,progressDate,summary,challenges,nextPlan,status,submittedBy,submittedAt,validatedBy,validatedAt,validationComment,createdAt,updatedAt);

@override
String toString() {
  return 'FypProgressLog(id: $id, fypRecordId: $fypRecordId, weekNumber: $weekNumber, progressDate: $progressDate, summary: $summary, challenges: $challenges, nextPlan: $nextPlan, status: $status, submittedBy: $submittedBy, submittedAt: $submittedAt, validatedBy: $validatedBy, validatedAt: $validatedAt, validationComment: $validationComment, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$FypProgressLogCopyWith<$Res> implements $FypProgressLogCopyWith<$Res> {
  factory _$FypProgressLogCopyWith(_FypProgressLog value, $Res Function(_FypProgressLog) _then) = __$FypProgressLogCopyWithImpl;
@override @useResult
$Res call({
 String id, String fypRecordId, int weekNumber, DateTime progressDate, String summary, String? challenges, String? nextPlan, String status, String? submittedBy, DateTime? submittedAt, String? validatedBy, DateTime? validatedAt, String? validationComment, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$FypProgressLogCopyWithImpl<$Res>
    implements _$FypProgressLogCopyWith<$Res> {
  __$FypProgressLogCopyWithImpl(this._self, this._then);

  final _FypProgressLog _self;
  final $Res Function(_FypProgressLog) _then;

/// Create a copy of FypProgressLog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fypRecordId = null,Object? weekNumber = null,Object? progressDate = null,Object? summary = null,Object? challenges = freezed,Object? nextPlan = freezed,Object? status = null,Object? submittedBy = freezed,Object? submittedAt = freezed,Object? validatedBy = freezed,Object? validatedAt = freezed,Object? validationComment = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_FypProgressLog(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fypRecordId: null == fypRecordId ? _self.fypRecordId : fypRecordId // ignore: cast_nullable_to_non_nullable
as String,weekNumber: null == weekNumber ? _self.weekNumber : weekNumber // ignore: cast_nullable_to_non_nullable
as int,progressDate: null == progressDate ? _self.progressDate : progressDate // ignore: cast_nullable_to_non_nullable
as DateTime,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,challenges: freezed == challenges ? _self.challenges : challenges // ignore: cast_nullable_to_non_nullable
as String?,nextPlan: freezed == nextPlan ? _self.nextPlan : nextPlan // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,submittedBy: freezed == submittedBy ? _self.submittedBy : submittedBy // ignore: cast_nullable_to_non_nullable
as String?,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,validatedBy: freezed == validatedBy ? _self.validatedBy : validatedBy // ignore: cast_nullable_to_non_nullable
as String?,validatedAt: freezed == validatedAt ? _self.validatedAt : validatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,validationComment: freezed == validationComment ? _self.validationComment : validationComment // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
