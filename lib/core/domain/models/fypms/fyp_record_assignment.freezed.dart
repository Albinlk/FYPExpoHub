// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fyp_record_assignment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FypRecordAssignment {

 String get id; String get fypRecordId; String get academicRole;// 'supervisor', 'co_supervisor', 'examiner'
 String get lecturerId; bool get isActive; String? get assignedBy; DateTime get assignedAt; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of FypRecordAssignment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FypRecordAssignmentCopyWith<FypRecordAssignment> get copyWith => _$FypRecordAssignmentCopyWithImpl<FypRecordAssignment>(this as FypRecordAssignment, _$identity);

  /// Serializes this FypRecordAssignment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FypRecordAssignment&&(identical(other.id, id) || other.id == id)&&(identical(other.fypRecordId, fypRecordId) || other.fypRecordId == fypRecordId)&&(identical(other.academicRole, academicRole) || other.academicRole == academicRole)&&(identical(other.lecturerId, lecturerId) || other.lecturerId == lecturerId)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.assignedBy, assignedBy) || other.assignedBy == assignedBy)&&(identical(other.assignedAt, assignedAt) || other.assignedAt == assignedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fypRecordId,academicRole,lecturerId,isActive,assignedBy,assignedAt,createdAt,updatedAt);

@override
String toString() {
  return 'FypRecordAssignment(id: $id, fypRecordId: $fypRecordId, academicRole: $academicRole, lecturerId: $lecturerId, isActive: $isActive, assignedBy: $assignedBy, assignedAt: $assignedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $FypRecordAssignmentCopyWith<$Res>  {
  factory $FypRecordAssignmentCopyWith(FypRecordAssignment value, $Res Function(FypRecordAssignment) _then) = _$FypRecordAssignmentCopyWithImpl;
@useResult
$Res call({
 String id, String fypRecordId, String academicRole, String lecturerId, bool isActive, String? assignedBy, DateTime assignedAt, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$FypRecordAssignmentCopyWithImpl<$Res>
    implements $FypRecordAssignmentCopyWith<$Res> {
  _$FypRecordAssignmentCopyWithImpl(this._self, this._then);

  final FypRecordAssignment _self;
  final $Res Function(FypRecordAssignment) _then;

/// Create a copy of FypRecordAssignment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fypRecordId = null,Object? academicRole = null,Object? lecturerId = null,Object? isActive = null,Object? assignedBy = freezed,Object? assignedAt = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fypRecordId: null == fypRecordId ? _self.fypRecordId : fypRecordId // ignore: cast_nullable_to_non_nullable
as String,academicRole: null == academicRole ? _self.academicRole : academicRole // ignore: cast_nullable_to_non_nullable
as String,lecturerId: null == lecturerId ? _self.lecturerId : lecturerId // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,assignedBy: freezed == assignedBy ? _self.assignedBy : assignedBy // ignore: cast_nullable_to_non_nullable
as String?,assignedAt: null == assignedAt ? _self.assignedAt : assignedAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [FypRecordAssignment].
extension FypRecordAssignmentPatterns on FypRecordAssignment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FypRecordAssignment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FypRecordAssignment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FypRecordAssignment value)  $default,){
final _that = this;
switch (_that) {
case _FypRecordAssignment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FypRecordAssignment value)?  $default,){
final _that = this;
switch (_that) {
case _FypRecordAssignment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fypRecordId,  String academicRole,  String lecturerId,  bool isActive,  String? assignedBy,  DateTime assignedAt,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FypRecordAssignment() when $default != null:
return $default(_that.id,_that.fypRecordId,_that.academicRole,_that.lecturerId,_that.isActive,_that.assignedBy,_that.assignedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fypRecordId,  String academicRole,  String lecturerId,  bool isActive,  String? assignedBy,  DateTime assignedAt,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _FypRecordAssignment():
return $default(_that.id,_that.fypRecordId,_that.academicRole,_that.lecturerId,_that.isActive,_that.assignedBy,_that.assignedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fypRecordId,  String academicRole,  String lecturerId,  bool isActive,  String? assignedBy,  DateTime assignedAt,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _FypRecordAssignment() when $default != null:
return $default(_that.id,_that.fypRecordId,_that.academicRole,_that.lecturerId,_that.isActive,_that.assignedBy,_that.assignedAt,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FypRecordAssignment implements FypRecordAssignment {
  const _FypRecordAssignment({required this.id, required this.fypRecordId, required this.academicRole, required this.lecturerId, required this.isActive, this.assignedBy, required this.assignedAt, required this.createdAt, required this.updatedAt});
  factory _FypRecordAssignment.fromJson(Map<String, dynamic> json) => _$FypRecordAssignmentFromJson(json);

@override final  String id;
@override final  String fypRecordId;
@override final  String academicRole;
// 'supervisor', 'co_supervisor', 'examiner'
@override final  String lecturerId;
@override final  bool isActive;
@override final  String? assignedBy;
@override final  DateTime assignedAt;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of FypRecordAssignment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FypRecordAssignmentCopyWith<_FypRecordAssignment> get copyWith => __$FypRecordAssignmentCopyWithImpl<_FypRecordAssignment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FypRecordAssignmentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FypRecordAssignment&&(identical(other.id, id) || other.id == id)&&(identical(other.fypRecordId, fypRecordId) || other.fypRecordId == fypRecordId)&&(identical(other.academicRole, academicRole) || other.academicRole == academicRole)&&(identical(other.lecturerId, lecturerId) || other.lecturerId == lecturerId)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.assignedBy, assignedBy) || other.assignedBy == assignedBy)&&(identical(other.assignedAt, assignedAt) || other.assignedAt == assignedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fypRecordId,academicRole,lecturerId,isActive,assignedBy,assignedAt,createdAt,updatedAt);

@override
String toString() {
  return 'FypRecordAssignment(id: $id, fypRecordId: $fypRecordId, academicRole: $academicRole, lecturerId: $lecturerId, isActive: $isActive, assignedBy: $assignedBy, assignedAt: $assignedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$FypRecordAssignmentCopyWith<$Res> implements $FypRecordAssignmentCopyWith<$Res> {
  factory _$FypRecordAssignmentCopyWith(_FypRecordAssignment value, $Res Function(_FypRecordAssignment) _then) = __$FypRecordAssignmentCopyWithImpl;
@override @useResult
$Res call({
 String id, String fypRecordId, String academicRole, String lecturerId, bool isActive, String? assignedBy, DateTime assignedAt, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$FypRecordAssignmentCopyWithImpl<$Res>
    implements _$FypRecordAssignmentCopyWith<$Res> {
  __$FypRecordAssignmentCopyWithImpl(this._self, this._then);

  final _FypRecordAssignment _self;
  final $Res Function(_FypRecordAssignment) _then;

/// Create a copy of FypRecordAssignment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fypRecordId = null,Object? academicRole = null,Object? lecturerId = null,Object? isActive = null,Object? assignedBy = freezed,Object? assignedAt = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_FypRecordAssignment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fypRecordId: null == fypRecordId ? _self.fypRecordId : fypRecordId // ignore: cast_nullable_to_non_nullable
as String,academicRole: null == academicRole ? _self.academicRole : academicRole // ignore: cast_nullable_to_non_nullable
as String,lecturerId: null == lecturerId ? _self.lecturerId : lecturerId // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,assignedBy: freezed == assignedBy ? _self.assignedBy : assignedBy // ignore: cast_nullable_to_non_nullable
as String?,assignedAt: null == assignedAt ? _self.assignedAt : assignedAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
