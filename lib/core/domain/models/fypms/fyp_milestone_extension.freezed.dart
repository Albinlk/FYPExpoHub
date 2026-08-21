// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fyp_milestone_extension.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FypMilestoneExtension {

 String get id; String get milestoneId; String get requestedBy; String? get reason; DateTime? get requestedDueDate; String get status;// 'pending', 'approved', 'rejected'
 String? get decidedBy; DateTime? get decidedAt; String? get decisionComment; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of FypMilestoneExtension
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FypMilestoneExtensionCopyWith<FypMilestoneExtension> get copyWith => _$FypMilestoneExtensionCopyWithImpl<FypMilestoneExtension>(this as FypMilestoneExtension, _$identity);

  /// Serializes this FypMilestoneExtension to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FypMilestoneExtension&&(identical(other.id, id) || other.id == id)&&(identical(other.milestoneId, milestoneId) || other.milestoneId == milestoneId)&&(identical(other.requestedBy, requestedBy) || other.requestedBy == requestedBy)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.requestedDueDate, requestedDueDate) || other.requestedDueDate == requestedDueDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.decidedBy, decidedBy) || other.decidedBy == decidedBy)&&(identical(other.decidedAt, decidedAt) || other.decidedAt == decidedAt)&&(identical(other.decisionComment, decisionComment) || other.decisionComment == decisionComment)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,milestoneId,requestedBy,reason,requestedDueDate,status,decidedBy,decidedAt,decisionComment,createdAt,updatedAt);

@override
String toString() {
  return 'FypMilestoneExtension(id: $id, milestoneId: $milestoneId, requestedBy: $requestedBy, reason: $reason, requestedDueDate: $requestedDueDate, status: $status, decidedBy: $decidedBy, decidedAt: $decidedAt, decisionComment: $decisionComment, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $FypMilestoneExtensionCopyWith<$Res>  {
  factory $FypMilestoneExtensionCopyWith(FypMilestoneExtension value, $Res Function(FypMilestoneExtension) _then) = _$FypMilestoneExtensionCopyWithImpl;
@useResult
$Res call({
 String id, String milestoneId, String requestedBy, String? reason, DateTime? requestedDueDate, String status, String? decidedBy, DateTime? decidedAt, String? decisionComment, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$FypMilestoneExtensionCopyWithImpl<$Res>
    implements $FypMilestoneExtensionCopyWith<$Res> {
  _$FypMilestoneExtensionCopyWithImpl(this._self, this._then);

  final FypMilestoneExtension _self;
  final $Res Function(FypMilestoneExtension) _then;

/// Create a copy of FypMilestoneExtension
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? milestoneId = null,Object? requestedBy = null,Object? reason = freezed,Object? requestedDueDate = freezed,Object? status = null,Object? decidedBy = freezed,Object? decidedAt = freezed,Object? decisionComment = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,milestoneId: null == milestoneId ? _self.milestoneId : milestoneId // ignore: cast_nullable_to_non_nullable
as String,requestedBy: null == requestedBy ? _self.requestedBy : requestedBy // ignore: cast_nullable_to_non_nullable
as String,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,requestedDueDate: freezed == requestedDueDate ? _self.requestedDueDate : requestedDueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,decidedBy: freezed == decidedBy ? _self.decidedBy : decidedBy // ignore: cast_nullable_to_non_nullable
as String?,decidedAt: freezed == decidedAt ? _self.decidedAt : decidedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,decisionComment: freezed == decisionComment ? _self.decisionComment : decisionComment // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [FypMilestoneExtension].
extension FypMilestoneExtensionPatterns on FypMilestoneExtension {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FypMilestoneExtension value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FypMilestoneExtension() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FypMilestoneExtension value)  $default,){
final _that = this;
switch (_that) {
case _FypMilestoneExtension():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FypMilestoneExtension value)?  $default,){
final _that = this;
switch (_that) {
case _FypMilestoneExtension() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String milestoneId,  String requestedBy,  String? reason,  DateTime? requestedDueDate,  String status,  String? decidedBy,  DateTime? decidedAt,  String? decisionComment,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FypMilestoneExtension() when $default != null:
return $default(_that.id,_that.milestoneId,_that.requestedBy,_that.reason,_that.requestedDueDate,_that.status,_that.decidedBy,_that.decidedAt,_that.decisionComment,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String milestoneId,  String requestedBy,  String? reason,  DateTime? requestedDueDate,  String status,  String? decidedBy,  DateTime? decidedAt,  String? decisionComment,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _FypMilestoneExtension():
return $default(_that.id,_that.milestoneId,_that.requestedBy,_that.reason,_that.requestedDueDate,_that.status,_that.decidedBy,_that.decidedAt,_that.decisionComment,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String milestoneId,  String requestedBy,  String? reason,  DateTime? requestedDueDate,  String status,  String? decidedBy,  DateTime? decidedAt,  String? decisionComment,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _FypMilestoneExtension() when $default != null:
return $default(_that.id,_that.milestoneId,_that.requestedBy,_that.reason,_that.requestedDueDate,_that.status,_that.decidedBy,_that.decidedAt,_that.decisionComment,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FypMilestoneExtension implements FypMilestoneExtension {
  const _FypMilestoneExtension({required this.id, required this.milestoneId, required this.requestedBy, this.reason, this.requestedDueDate, required this.status, this.decidedBy, this.decidedAt, this.decisionComment, required this.createdAt, required this.updatedAt});
  factory _FypMilestoneExtension.fromJson(Map<String, dynamic> json) => _$FypMilestoneExtensionFromJson(json);

@override final  String id;
@override final  String milestoneId;
@override final  String requestedBy;
@override final  String? reason;
@override final  DateTime? requestedDueDate;
@override final  String status;
// 'pending', 'approved', 'rejected'
@override final  String? decidedBy;
@override final  DateTime? decidedAt;
@override final  String? decisionComment;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of FypMilestoneExtension
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FypMilestoneExtensionCopyWith<_FypMilestoneExtension> get copyWith => __$FypMilestoneExtensionCopyWithImpl<_FypMilestoneExtension>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FypMilestoneExtensionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FypMilestoneExtension&&(identical(other.id, id) || other.id == id)&&(identical(other.milestoneId, milestoneId) || other.milestoneId == milestoneId)&&(identical(other.requestedBy, requestedBy) || other.requestedBy == requestedBy)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.requestedDueDate, requestedDueDate) || other.requestedDueDate == requestedDueDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.decidedBy, decidedBy) || other.decidedBy == decidedBy)&&(identical(other.decidedAt, decidedAt) || other.decidedAt == decidedAt)&&(identical(other.decisionComment, decisionComment) || other.decisionComment == decisionComment)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,milestoneId,requestedBy,reason,requestedDueDate,status,decidedBy,decidedAt,decisionComment,createdAt,updatedAt);

@override
String toString() {
  return 'FypMilestoneExtension(id: $id, milestoneId: $milestoneId, requestedBy: $requestedBy, reason: $reason, requestedDueDate: $requestedDueDate, status: $status, decidedBy: $decidedBy, decidedAt: $decidedAt, decisionComment: $decisionComment, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$FypMilestoneExtensionCopyWith<$Res> implements $FypMilestoneExtensionCopyWith<$Res> {
  factory _$FypMilestoneExtensionCopyWith(_FypMilestoneExtension value, $Res Function(_FypMilestoneExtension) _then) = __$FypMilestoneExtensionCopyWithImpl;
@override @useResult
$Res call({
 String id, String milestoneId, String requestedBy, String? reason, DateTime? requestedDueDate, String status, String? decidedBy, DateTime? decidedAt, String? decisionComment, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$FypMilestoneExtensionCopyWithImpl<$Res>
    implements _$FypMilestoneExtensionCopyWith<$Res> {
  __$FypMilestoneExtensionCopyWithImpl(this._self, this._then);

  final _FypMilestoneExtension _self;
  final $Res Function(_FypMilestoneExtension) _then;

/// Create a copy of FypMilestoneExtension
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? milestoneId = null,Object? requestedBy = null,Object? reason = freezed,Object? requestedDueDate = freezed,Object? status = null,Object? decidedBy = freezed,Object? decidedAt = freezed,Object? decisionComment = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_FypMilestoneExtension(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,milestoneId: null == milestoneId ? _self.milestoneId : milestoneId // ignore: cast_nullable_to_non_nullable
as String,requestedBy: null == requestedBy ? _self.requestedBy : requestedBy // ignore: cast_nullable_to_non_nullable
as String,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,requestedDueDate: freezed == requestedDueDate ? _self.requestedDueDate : requestedDueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,decidedBy: freezed == decidedBy ? _self.decidedBy : decidedBy // ignore: cast_nullable_to_non_nullable
as String?,decidedAt: freezed == decidedAt ? _self.decidedAt : decidedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,decisionComment: freezed == decisionComment ? _self.decisionComment : decisionComment // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
