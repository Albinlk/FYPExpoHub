// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'project_lecturer_assignment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProjectLecturerAssignment {

 String get id; String get eventId; String get projectId; String get lecturerDisplayName; String? get lecturerId; String get role; String get status; DateTime get assignedAt; DateTime get updatedAt;
/// Create a copy of ProjectLecturerAssignment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectLecturerAssignmentCopyWith<ProjectLecturerAssignment> get copyWith => _$ProjectLecturerAssignmentCopyWithImpl<ProjectLecturerAssignment>(this as ProjectLecturerAssignment, _$identity);

  /// Serializes this ProjectLecturerAssignment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectLecturerAssignment&&(identical(other.id, id) || other.id == id)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.lecturerDisplayName, lecturerDisplayName) || other.lecturerDisplayName == lecturerDisplayName)&&(identical(other.lecturerId, lecturerId) || other.lecturerId == lecturerId)&&(identical(other.role, role) || other.role == role)&&(identical(other.status, status) || other.status == status)&&(identical(other.assignedAt, assignedAt) || other.assignedAt == assignedAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,eventId,projectId,lecturerDisplayName,lecturerId,role,status,assignedAt,updatedAt);

@override
String toString() {
  return 'ProjectLecturerAssignment(id: $id, eventId: $eventId, projectId: $projectId, lecturerDisplayName: $lecturerDisplayName, lecturerId: $lecturerId, role: $role, status: $status, assignedAt: $assignedAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ProjectLecturerAssignmentCopyWith<$Res>  {
  factory $ProjectLecturerAssignmentCopyWith(ProjectLecturerAssignment value, $Res Function(ProjectLecturerAssignment) _then) = _$ProjectLecturerAssignmentCopyWithImpl;
@useResult
$Res call({
 String id, String eventId, String projectId, String lecturerDisplayName, String? lecturerId, String role, String status, DateTime assignedAt, DateTime updatedAt
});




}
/// @nodoc
class _$ProjectLecturerAssignmentCopyWithImpl<$Res>
    implements $ProjectLecturerAssignmentCopyWith<$Res> {
  _$ProjectLecturerAssignmentCopyWithImpl(this._self, this._then);

  final ProjectLecturerAssignment _self;
  final $Res Function(ProjectLecturerAssignment) _then;

/// Create a copy of ProjectLecturerAssignment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? eventId = null,Object? projectId = null,Object? lecturerDisplayName = null,Object? lecturerId = freezed,Object? role = null,Object? status = null,Object? assignedAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,lecturerDisplayName: null == lecturerDisplayName ? _self.lecturerDisplayName : lecturerDisplayName // ignore: cast_nullable_to_non_nullable
as String,lecturerId: freezed == lecturerId ? _self.lecturerId : lecturerId // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,assignedAt: null == assignedAt ? _self.assignedAt : assignedAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ProjectLecturerAssignment].
extension ProjectLecturerAssignmentPatterns on ProjectLecturerAssignment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProjectLecturerAssignment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProjectLecturerAssignment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProjectLecturerAssignment value)  $default,){
final _that = this;
switch (_that) {
case _ProjectLecturerAssignment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProjectLecturerAssignment value)?  $default,){
final _that = this;
switch (_that) {
case _ProjectLecturerAssignment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String eventId,  String projectId,  String lecturerDisplayName,  String? lecturerId,  String role,  String status,  DateTime assignedAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProjectLecturerAssignment() when $default != null:
return $default(_that.id,_that.eventId,_that.projectId,_that.lecturerDisplayName,_that.lecturerId,_that.role,_that.status,_that.assignedAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String eventId,  String projectId,  String lecturerDisplayName,  String? lecturerId,  String role,  String status,  DateTime assignedAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ProjectLecturerAssignment():
return $default(_that.id,_that.eventId,_that.projectId,_that.lecturerDisplayName,_that.lecturerId,_that.role,_that.status,_that.assignedAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String eventId,  String projectId,  String lecturerDisplayName,  String? lecturerId,  String role,  String status,  DateTime assignedAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ProjectLecturerAssignment() when $default != null:
return $default(_that.id,_that.eventId,_that.projectId,_that.lecturerDisplayName,_that.lecturerId,_that.role,_that.status,_that.assignedAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProjectLecturerAssignment implements ProjectLecturerAssignment {
  const _ProjectLecturerAssignment({required this.id, required this.eventId, required this.projectId, required this.lecturerDisplayName, this.lecturerId, required this.role, this.status = 'active', required this.assignedAt, required this.updatedAt});
  factory _ProjectLecturerAssignment.fromJson(Map<String, dynamic> json) => _$ProjectLecturerAssignmentFromJson(json);

@override final  String id;
@override final  String eventId;
@override final  String projectId;
@override final  String lecturerDisplayName;
@override final  String? lecturerId;
@override final  String role;
@override@JsonKey() final  String status;
@override final  DateTime assignedAt;
@override final  DateTime updatedAt;

/// Create a copy of ProjectLecturerAssignment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProjectLecturerAssignmentCopyWith<_ProjectLecturerAssignment> get copyWith => __$ProjectLecturerAssignmentCopyWithImpl<_ProjectLecturerAssignment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProjectLecturerAssignmentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProjectLecturerAssignment&&(identical(other.id, id) || other.id == id)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.lecturerDisplayName, lecturerDisplayName) || other.lecturerDisplayName == lecturerDisplayName)&&(identical(other.lecturerId, lecturerId) || other.lecturerId == lecturerId)&&(identical(other.role, role) || other.role == role)&&(identical(other.status, status) || other.status == status)&&(identical(other.assignedAt, assignedAt) || other.assignedAt == assignedAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,eventId,projectId,lecturerDisplayName,lecturerId,role,status,assignedAt,updatedAt);

@override
String toString() {
  return 'ProjectLecturerAssignment(id: $id, eventId: $eventId, projectId: $projectId, lecturerDisplayName: $lecturerDisplayName, lecturerId: $lecturerId, role: $role, status: $status, assignedAt: $assignedAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ProjectLecturerAssignmentCopyWith<$Res> implements $ProjectLecturerAssignmentCopyWith<$Res> {
  factory _$ProjectLecturerAssignmentCopyWith(_ProjectLecturerAssignment value, $Res Function(_ProjectLecturerAssignment) _then) = __$ProjectLecturerAssignmentCopyWithImpl;
@override @useResult
$Res call({
 String id, String eventId, String projectId, String lecturerDisplayName, String? lecturerId, String role, String status, DateTime assignedAt, DateTime updatedAt
});




}
/// @nodoc
class __$ProjectLecturerAssignmentCopyWithImpl<$Res>
    implements _$ProjectLecturerAssignmentCopyWith<$Res> {
  __$ProjectLecturerAssignmentCopyWithImpl(this._self, this._then);

  final _ProjectLecturerAssignment _self;
  final $Res Function(_ProjectLecturerAssignment) _then;

/// Create a copy of ProjectLecturerAssignment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? eventId = null,Object? projectId = null,Object? lecturerDisplayName = null,Object? lecturerId = freezed,Object? role = null,Object? status = null,Object? assignedAt = null,Object? updatedAt = null,}) {
  return _then(_ProjectLecturerAssignment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,lecturerDisplayName: null == lecturerDisplayName ? _self.lecturerDisplayName : lecturerDisplayName // ignore: cast_nullable_to_non_nullable
as String,lecturerId: freezed == lecturerId ? _self.lecturerId : lecturerId // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,assignedAt: null == assignedAt ? _self.assignedAt : assignedAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
