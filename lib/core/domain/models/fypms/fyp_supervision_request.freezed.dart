// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fyp_supervision_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FypSupervisionRequest {

 String get id; String get fypRecordId; String? get preferredSupervisorId; String? get rationale; String get status;// 'pending', 'approved', 'rejected', 'withdrawn'
 String? get decidedBy; DateTime? get decidedAt; String? get decisionReason; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of FypSupervisionRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FypSupervisionRequestCopyWith<FypSupervisionRequest> get copyWith => _$FypSupervisionRequestCopyWithImpl<FypSupervisionRequest>(this as FypSupervisionRequest, _$identity);

  /// Serializes this FypSupervisionRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FypSupervisionRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.fypRecordId, fypRecordId) || other.fypRecordId == fypRecordId)&&(identical(other.preferredSupervisorId, preferredSupervisorId) || other.preferredSupervisorId == preferredSupervisorId)&&(identical(other.rationale, rationale) || other.rationale == rationale)&&(identical(other.status, status) || other.status == status)&&(identical(other.decidedBy, decidedBy) || other.decidedBy == decidedBy)&&(identical(other.decidedAt, decidedAt) || other.decidedAt == decidedAt)&&(identical(other.decisionReason, decisionReason) || other.decisionReason == decisionReason)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fypRecordId,preferredSupervisorId,rationale,status,decidedBy,decidedAt,decisionReason,createdAt,updatedAt);

@override
String toString() {
  return 'FypSupervisionRequest(id: $id, fypRecordId: $fypRecordId, preferredSupervisorId: $preferredSupervisorId, rationale: $rationale, status: $status, decidedBy: $decidedBy, decidedAt: $decidedAt, decisionReason: $decisionReason, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $FypSupervisionRequestCopyWith<$Res>  {
  factory $FypSupervisionRequestCopyWith(FypSupervisionRequest value, $Res Function(FypSupervisionRequest) _then) = _$FypSupervisionRequestCopyWithImpl;
@useResult
$Res call({
 String id, String fypRecordId, String? preferredSupervisorId, String? rationale, String status, String? decidedBy, DateTime? decidedAt, String? decisionReason, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$FypSupervisionRequestCopyWithImpl<$Res>
    implements $FypSupervisionRequestCopyWith<$Res> {
  _$FypSupervisionRequestCopyWithImpl(this._self, this._then);

  final FypSupervisionRequest _self;
  final $Res Function(FypSupervisionRequest) _then;

/// Create a copy of FypSupervisionRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fypRecordId = null,Object? preferredSupervisorId = freezed,Object? rationale = freezed,Object? status = null,Object? decidedBy = freezed,Object? decidedAt = freezed,Object? decisionReason = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fypRecordId: null == fypRecordId ? _self.fypRecordId : fypRecordId // ignore: cast_nullable_to_non_nullable
as String,preferredSupervisorId: freezed == preferredSupervisorId ? _self.preferredSupervisorId : preferredSupervisorId // ignore: cast_nullable_to_non_nullable
as String?,rationale: freezed == rationale ? _self.rationale : rationale // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,decidedBy: freezed == decidedBy ? _self.decidedBy : decidedBy // ignore: cast_nullable_to_non_nullable
as String?,decidedAt: freezed == decidedAt ? _self.decidedAt : decidedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,decisionReason: freezed == decisionReason ? _self.decisionReason : decisionReason // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [FypSupervisionRequest].
extension FypSupervisionRequestPatterns on FypSupervisionRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FypSupervisionRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FypSupervisionRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FypSupervisionRequest value)  $default,){
final _that = this;
switch (_that) {
case _FypSupervisionRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FypSupervisionRequest value)?  $default,){
final _that = this;
switch (_that) {
case _FypSupervisionRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fypRecordId,  String? preferredSupervisorId,  String? rationale,  String status,  String? decidedBy,  DateTime? decidedAt,  String? decisionReason,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FypSupervisionRequest() when $default != null:
return $default(_that.id,_that.fypRecordId,_that.preferredSupervisorId,_that.rationale,_that.status,_that.decidedBy,_that.decidedAt,_that.decisionReason,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fypRecordId,  String? preferredSupervisorId,  String? rationale,  String status,  String? decidedBy,  DateTime? decidedAt,  String? decisionReason,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _FypSupervisionRequest():
return $default(_that.id,_that.fypRecordId,_that.preferredSupervisorId,_that.rationale,_that.status,_that.decidedBy,_that.decidedAt,_that.decisionReason,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fypRecordId,  String? preferredSupervisorId,  String? rationale,  String status,  String? decidedBy,  DateTime? decidedAt,  String? decisionReason,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _FypSupervisionRequest() when $default != null:
return $default(_that.id,_that.fypRecordId,_that.preferredSupervisorId,_that.rationale,_that.status,_that.decidedBy,_that.decidedAt,_that.decisionReason,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FypSupervisionRequest implements FypSupervisionRequest {
  const _FypSupervisionRequest({required this.id, required this.fypRecordId, this.preferredSupervisorId, this.rationale, required this.status, this.decidedBy, this.decidedAt, this.decisionReason, required this.createdAt, required this.updatedAt});
  factory _FypSupervisionRequest.fromJson(Map<String, dynamic> json) => _$FypSupervisionRequestFromJson(json);

@override final  String id;
@override final  String fypRecordId;
@override final  String? preferredSupervisorId;
@override final  String? rationale;
@override final  String status;
// 'pending', 'approved', 'rejected', 'withdrawn'
@override final  String? decidedBy;
@override final  DateTime? decidedAt;
@override final  String? decisionReason;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of FypSupervisionRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FypSupervisionRequestCopyWith<_FypSupervisionRequest> get copyWith => __$FypSupervisionRequestCopyWithImpl<_FypSupervisionRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FypSupervisionRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FypSupervisionRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.fypRecordId, fypRecordId) || other.fypRecordId == fypRecordId)&&(identical(other.preferredSupervisorId, preferredSupervisorId) || other.preferredSupervisorId == preferredSupervisorId)&&(identical(other.rationale, rationale) || other.rationale == rationale)&&(identical(other.status, status) || other.status == status)&&(identical(other.decidedBy, decidedBy) || other.decidedBy == decidedBy)&&(identical(other.decidedAt, decidedAt) || other.decidedAt == decidedAt)&&(identical(other.decisionReason, decisionReason) || other.decisionReason == decisionReason)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fypRecordId,preferredSupervisorId,rationale,status,decidedBy,decidedAt,decisionReason,createdAt,updatedAt);

@override
String toString() {
  return 'FypSupervisionRequest(id: $id, fypRecordId: $fypRecordId, preferredSupervisorId: $preferredSupervisorId, rationale: $rationale, status: $status, decidedBy: $decidedBy, decidedAt: $decidedAt, decisionReason: $decisionReason, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$FypSupervisionRequestCopyWith<$Res> implements $FypSupervisionRequestCopyWith<$Res> {
  factory _$FypSupervisionRequestCopyWith(_FypSupervisionRequest value, $Res Function(_FypSupervisionRequest) _then) = __$FypSupervisionRequestCopyWithImpl;
@override @useResult
$Res call({
 String id, String fypRecordId, String? preferredSupervisorId, String? rationale, String status, String? decidedBy, DateTime? decidedAt, String? decisionReason, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$FypSupervisionRequestCopyWithImpl<$Res>
    implements _$FypSupervisionRequestCopyWith<$Res> {
  __$FypSupervisionRequestCopyWithImpl(this._self, this._then);

  final _FypSupervisionRequest _self;
  final $Res Function(_FypSupervisionRequest) _then;

/// Create a copy of FypSupervisionRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fypRecordId = null,Object? preferredSupervisorId = freezed,Object? rationale = freezed,Object? status = null,Object? decidedBy = freezed,Object? decidedAt = freezed,Object? decisionReason = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_FypSupervisionRequest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fypRecordId: null == fypRecordId ? _self.fypRecordId : fypRecordId // ignore: cast_nullable_to_non_nullable
as String,preferredSupervisorId: freezed == preferredSupervisorId ? _self.preferredSupervisorId : preferredSupervisorId // ignore: cast_nullable_to_non_nullable
as String?,rationale: freezed == rationale ? _self.rationale : rationale // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,decidedBy: freezed == decidedBy ? _self.decidedBy : decidedBy // ignore: cast_nullable_to_non_nullable
as String?,decidedAt: freezed == decidedAt ? _self.decidedAt : decidedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,decisionReason: freezed == decisionReason ? _self.decisionReason : decisionReason // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
