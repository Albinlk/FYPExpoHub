// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fyp_form_submission.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FypFormSubmission {

 String get id; String get fypRecordId; String get formCode;// F1-F16
 int get formVersion; Map<String, dynamic> get payload; String get status;// 'draft', 'submitted', 'under_review', 'approved', 'rejected', 'resubmission_required'
 String? get submittedBy; DateTime? get submittedAt; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of FypFormSubmission
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FypFormSubmissionCopyWith<FypFormSubmission> get copyWith => _$FypFormSubmissionCopyWithImpl<FypFormSubmission>(this as FypFormSubmission, _$identity);

  /// Serializes this FypFormSubmission to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FypFormSubmission&&(identical(other.id, id) || other.id == id)&&(identical(other.fypRecordId, fypRecordId) || other.fypRecordId == fypRecordId)&&(identical(other.formCode, formCode) || other.formCode == formCode)&&(identical(other.formVersion, formVersion) || other.formVersion == formVersion)&&const DeepCollectionEquality().equals(other.payload, payload)&&(identical(other.status, status) || other.status == status)&&(identical(other.submittedBy, submittedBy) || other.submittedBy == submittedBy)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fypRecordId,formCode,formVersion,const DeepCollectionEquality().hash(payload),status,submittedBy,submittedAt,createdAt,updatedAt);

@override
String toString() {
  return 'FypFormSubmission(id: $id, fypRecordId: $fypRecordId, formCode: $formCode, formVersion: $formVersion, payload: $payload, status: $status, submittedBy: $submittedBy, submittedAt: $submittedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $FypFormSubmissionCopyWith<$Res>  {
  factory $FypFormSubmissionCopyWith(FypFormSubmission value, $Res Function(FypFormSubmission) _then) = _$FypFormSubmissionCopyWithImpl;
@useResult
$Res call({
 String id, String fypRecordId, String formCode, int formVersion, Map<String, dynamic> payload, String status, String? submittedBy, DateTime? submittedAt, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$FypFormSubmissionCopyWithImpl<$Res>
    implements $FypFormSubmissionCopyWith<$Res> {
  _$FypFormSubmissionCopyWithImpl(this._self, this._then);

  final FypFormSubmission _self;
  final $Res Function(FypFormSubmission) _then;

/// Create a copy of FypFormSubmission
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fypRecordId = null,Object? formCode = null,Object? formVersion = null,Object? payload = null,Object? status = null,Object? submittedBy = freezed,Object? submittedAt = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fypRecordId: null == fypRecordId ? _self.fypRecordId : fypRecordId // ignore: cast_nullable_to_non_nullable
as String,formCode: null == formCode ? _self.formCode : formCode // ignore: cast_nullable_to_non_nullable
as String,formVersion: null == formVersion ? _self.formVersion : formVersion // ignore: cast_nullable_to_non_nullable
as int,payload: null == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,submittedBy: freezed == submittedBy ? _self.submittedBy : submittedBy // ignore: cast_nullable_to_non_nullable
as String?,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [FypFormSubmission].
extension FypFormSubmissionPatterns on FypFormSubmission {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FypFormSubmission value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FypFormSubmission() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FypFormSubmission value)  $default,){
final _that = this;
switch (_that) {
case _FypFormSubmission():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FypFormSubmission value)?  $default,){
final _that = this;
switch (_that) {
case _FypFormSubmission() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fypRecordId,  String formCode,  int formVersion,  Map<String, dynamic> payload,  String status,  String? submittedBy,  DateTime? submittedAt,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FypFormSubmission() when $default != null:
return $default(_that.id,_that.fypRecordId,_that.formCode,_that.formVersion,_that.payload,_that.status,_that.submittedBy,_that.submittedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fypRecordId,  String formCode,  int formVersion,  Map<String, dynamic> payload,  String status,  String? submittedBy,  DateTime? submittedAt,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _FypFormSubmission():
return $default(_that.id,_that.fypRecordId,_that.formCode,_that.formVersion,_that.payload,_that.status,_that.submittedBy,_that.submittedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fypRecordId,  String formCode,  int formVersion,  Map<String, dynamic> payload,  String status,  String? submittedBy,  DateTime? submittedAt,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _FypFormSubmission() when $default != null:
return $default(_that.id,_that.fypRecordId,_that.formCode,_that.formVersion,_that.payload,_that.status,_that.submittedBy,_that.submittedAt,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FypFormSubmission implements FypFormSubmission {
  const _FypFormSubmission({required this.id, required this.fypRecordId, required this.formCode, required this.formVersion, required final  Map<String, dynamic> payload, required this.status, this.submittedBy, this.submittedAt, required this.createdAt, required this.updatedAt}): _payload = payload;
  factory _FypFormSubmission.fromJson(Map<String, dynamic> json) => _$FypFormSubmissionFromJson(json);

@override final  String id;
@override final  String fypRecordId;
@override final  String formCode;
// F1-F16
@override final  int formVersion;
 final  Map<String, dynamic> _payload;
@override Map<String, dynamic> get payload {
  if (_payload is EqualUnmodifiableMapView) return _payload;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_payload);
}

@override final  String status;
// 'draft', 'submitted', 'under_review', 'approved', 'rejected', 'resubmission_required'
@override final  String? submittedBy;
@override final  DateTime? submittedAt;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of FypFormSubmission
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FypFormSubmissionCopyWith<_FypFormSubmission> get copyWith => __$FypFormSubmissionCopyWithImpl<_FypFormSubmission>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FypFormSubmissionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FypFormSubmission&&(identical(other.id, id) || other.id == id)&&(identical(other.fypRecordId, fypRecordId) || other.fypRecordId == fypRecordId)&&(identical(other.formCode, formCode) || other.formCode == formCode)&&(identical(other.formVersion, formVersion) || other.formVersion == formVersion)&&const DeepCollectionEquality().equals(other._payload, _payload)&&(identical(other.status, status) || other.status == status)&&(identical(other.submittedBy, submittedBy) || other.submittedBy == submittedBy)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fypRecordId,formCode,formVersion,const DeepCollectionEquality().hash(_payload),status,submittedBy,submittedAt,createdAt,updatedAt);

@override
String toString() {
  return 'FypFormSubmission(id: $id, fypRecordId: $fypRecordId, formCode: $formCode, formVersion: $formVersion, payload: $payload, status: $status, submittedBy: $submittedBy, submittedAt: $submittedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$FypFormSubmissionCopyWith<$Res> implements $FypFormSubmissionCopyWith<$Res> {
  factory _$FypFormSubmissionCopyWith(_FypFormSubmission value, $Res Function(_FypFormSubmission) _then) = __$FypFormSubmissionCopyWithImpl;
@override @useResult
$Res call({
 String id, String fypRecordId, String formCode, int formVersion, Map<String, dynamic> payload, String status, String? submittedBy, DateTime? submittedAt, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$FypFormSubmissionCopyWithImpl<$Res>
    implements _$FypFormSubmissionCopyWith<$Res> {
  __$FypFormSubmissionCopyWithImpl(this._self, this._then);

  final _FypFormSubmission _self;
  final $Res Function(_FypFormSubmission) _then;

/// Create a copy of FypFormSubmission
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fypRecordId = null,Object? formCode = null,Object? formVersion = null,Object? payload = null,Object? status = null,Object? submittedBy = freezed,Object? submittedAt = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_FypFormSubmission(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fypRecordId: null == fypRecordId ? _self.fypRecordId : fypRecordId // ignore: cast_nullable_to_non_nullable
as String,formCode: null == formCode ? _self.formCode : formCode // ignore: cast_nullable_to_non_nullable
as String,formVersion: null == formVersion ? _self.formVersion : formVersion // ignore: cast_nullable_to_non_nullable
as int,payload: null == payload ? _self._payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,submittedBy: freezed == submittedBy ? _self.submittedBy : submittedBy // ignore: cast_nullable_to_non_nullable
as String?,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
