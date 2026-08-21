// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fyp_milestone.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FypMilestone {

 String get id; String get fypRecordId; String get milestoneCode; String get milestoneTitle; String? get description; DateTime? get targetDate; String get status;// 'pending', 'in_progress', 'completed', 'overdue'
 DateTime? get completedAt; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of FypMilestone
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FypMilestoneCopyWith<FypMilestone> get copyWith => _$FypMilestoneCopyWithImpl<FypMilestone>(this as FypMilestone, _$identity);

  /// Serializes this FypMilestone to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FypMilestone&&(identical(other.id, id) || other.id == id)&&(identical(other.fypRecordId, fypRecordId) || other.fypRecordId == fypRecordId)&&(identical(other.milestoneCode, milestoneCode) || other.milestoneCode == milestoneCode)&&(identical(other.milestoneTitle, milestoneTitle) || other.milestoneTitle == milestoneTitle)&&(identical(other.description, description) || other.description == description)&&(identical(other.targetDate, targetDate) || other.targetDate == targetDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fypRecordId,milestoneCode,milestoneTitle,description,targetDate,status,completedAt,createdAt,updatedAt);

@override
String toString() {
  return 'FypMilestone(id: $id, fypRecordId: $fypRecordId, milestoneCode: $milestoneCode, milestoneTitle: $milestoneTitle, description: $description, targetDate: $targetDate, status: $status, completedAt: $completedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $FypMilestoneCopyWith<$Res>  {
  factory $FypMilestoneCopyWith(FypMilestone value, $Res Function(FypMilestone) _then) = _$FypMilestoneCopyWithImpl;
@useResult
$Res call({
 String id, String fypRecordId, String milestoneCode, String milestoneTitle, String? description, DateTime? targetDate, String status, DateTime? completedAt, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$FypMilestoneCopyWithImpl<$Res>
    implements $FypMilestoneCopyWith<$Res> {
  _$FypMilestoneCopyWithImpl(this._self, this._then);

  final FypMilestone _self;
  final $Res Function(FypMilestone) _then;

/// Create a copy of FypMilestone
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fypRecordId = null,Object? milestoneCode = null,Object? milestoneTitle = null,Object? description = freezed,Object? targetDate = freezed,Object? status = null,Object? completedAt = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fypRecordId: null == fypRecordId ? _self.fypRecordId : fypRecordId // ignore: cast_nullable_to_non_nullable
as String,milestoneCode: null == milestoneCode ? _self.milestoneCode : milestoneCode // ignore: cast_nullable_to_non_nullable
as String,milestoneTitle: null == milestoneTitle ? _self.milestoneTitle : milestoneTitle // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,targetDate: freezed == targetDate ? _self.targetDate : targetDate // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [FypMilestone].
extension FypMilestonePatterns on FypMilestone {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FypMilestone value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FypMilestone() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FypMilestone value)  $default,){
final _that = this;
switch (_that) {
case _FypMilestone():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FypMilestone value)?  $default,){
final _that = this;
switch (_that) {
case _FypMilestone() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fypRecordId,  String milestoneCode,  String milestoneTitle,  String? description,  DateTime? targetDate,  String status,  DateTime? completedAt,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FypMilestone() when $default != null:
return $default(_that.id,_that.fypRecordId,_that.milestoneCode,_that.milestoneTitle,_that.description,_that.targetDate,_that.status,_that.completedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fypRecordId,  String milestoneCode,  String milestoneTitle,  String? description,  DateTime? targetDate,  String status,  DateTime? completedAt,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _FypMilestone():
return $default(_that.id,_that.fypRecordId,_that.milestoneCode,_that.milestoneTitle,_that.description,_that.targetDate,_that.status,_that.completedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fypRecordId,  String milestoneCode,  String milestoneTitle,  String? description,  DateTime? targetDate,  String status,  DateTime? completedAt,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _FypMilestone() when $default != null:
return $default(_that.id,_that.fypRecordId,_that.milestoneCode,_that.milestoneTitle,_that.description,_that.targetDate,_that.status,_that.completedAt,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FypMilestone implements FypMilestone {
  const _FypMilestone({required this.id, required this.fypRecordId, required this.milestoneCode, required this.milestoneTitle, this.description, this.targetDate, required this.status, this.completedAt, required this.createdAt, required this.updatedAt});
  factory _FypMilestone.fromJson(Map<String, dynamic> json) => _$FypMilestoneFromJson(json);

@override final  String id;
@override final  String fypRecordId;
@override final  String milestoneCode;
@override final  String milestoneTitle;
@override final  String? description;
@override final  DateTime? targetDate;
@override final  String status;
// 'pending', 'in_progress', 'completed', 'overdue'
@override final  DateTime? completedAt;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of FypMilestone
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FypMilestoneCopyWith<_FypMilestone> get copyWith => __$FypMilestoneCopyWithImpl<_FypMilestone>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FypMilestoneToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FypMilestone&&(identical(other.id, id) || other.id == id)&&(identical(other.fypRecordId, fypRecordId) || other.fypRecordId == fypRecordId)&&(identical(other.milestoneCode, milestoneCode) || other.milestoneCode == milestoneCode)&&(identical(other.milestoneTitle, milestoneTitle) || other.milestoneTitle == milestoneTitle)&&(identical(other.description, description) || other.description == description)&&(identical(other.targetDate, targetDate) || other.targetDate == targetDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fypRecordId,milestoneCode,milestoneTitle,description,targetDate,status,completedAt,createdAt,updatedAt);

@override
String toString() {
  return 'FypMilestone(id: $id, fypRecordId: $fypRecordId, milestoneCode: $milestoneCode, milestoneTitle: $milestoneTitle, description: $description, targetDate: $targetDate, status: $status, completedAt: $completedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$FypMilestoneCopyWith<$Res> implements $FypMilestoneCopyWith<$Res> {
  factory _$FypMilestoneCopyWith(_FypMilestone value, $Res Function(_FypMilestone) _then) = __$FypMilestoneCopyWithImpl;
@override @useResult
$Res call({
 String id, String fypRecordId, String milestoneCode, String milestoneTitle, String? description, DateTime? targetDate, String status, DateTime? completedAt, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$FypMilestoneCopyWithImpl<$Res>
    implements _$FypMilestoneCopyWith<$Res> {
  __$FypMilestoneCopyWithImpl(this._self, this._then);

  final _FypMilestone _self;
  final $Res Function(_FypMilestone) _then;

/// Create a copy of FypMilestone
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fypRecordId = null,Object? milestoneCode = null,Object? milestoneTitle = null,Object? description = freezed,Object? targetDate = freezed,Object? status = null,Object? completedAt = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_FypMilestone(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fypRecordId: null == fypRecordId ? _self.fypRecordId : fypRecordId // ignore: cast_nullable_to_non_nullable
as String,milestoneCode: null == milestoneCode ? _self.milestoneCode : milestoneCode // ignore: cast_nullable_to_non_nullable
as String,milestoneTitle: null == milestoneTitle ? _self.milestoneTitle : milestoneTitle // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,targetDate: freezed == targetDate ? _self.targetDate : targetDate // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
