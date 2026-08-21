// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_academic_role.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProfileAcademicRole {

 String get id; String get profileId; String get roleCode;// 'student', 'supervisor', 'co_supervisor', 'examiner', 'csp600_lecturer', 'csp650_lecturer', 'fyp_coordinator'
 String get programmeCode; bool get isActive; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of ProfileAcademicRole
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileAcademicRoleCopyWith<ProfileAcademicRole> get copyWith => _$ProfileAcademicRoleCopyWithImpl<ProfileAcademicRole>(this as ProfileAcademicRole, _$identity);

  /// Serializes this ProfileAcademicRole to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileAcademicRole&&(identical(other.id, id) || other.id == id)&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.roleCode, roleCode) || other.roleCode == roleCode)&&(identical(other.programmeCode, programmeCode) || other.programmeCode == programmeCode)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,profileId,roleCode,programmeCode,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'ProfileAcademicRole(id: $id, profileId: $profileId, roleCode: $roleCode, programmeCode: $programmeCode, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ProfileAcademicRoleCopyWith<$Res>  {
  factory $ProfileAcademicRoleCopyWith(ProfileAcademicRole value, $Res Function(ProfileAcademicRole) _then) = _$ProfileAcademicRoleCopyWithImpl;
@useResult
$Res call({
 String id, String profileId, String roleCode, String programmeCode, bool isActive, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$ProfileAcademicRoleCopyWithImpl<$Res>
    implements $ProfileAcademicRoleCopyWith<$Res> {
  _$ProfileAcademicRoleCopyWithImpl(this._self, this._then);

  final ProfileAcademicRole _self;
  final $Res Function(ProfileAcademicRole) _then;

/// Create a copy of ProfileAcademicRole
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? profileId = null,Object? roleCode = null,Object? programmeCode = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String,roleCode: null == roleCode ? _self.roleCode : roleCode // ignore: cast_nullable_to_non_nullable
as String,programmeCode: null == programmeCode ? _self.programmeCode : programmeCode // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfileAcademicRole].
extension ProfileAcademicRolePatterns on ProfileAcademicRole {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileAcademicRole value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileAcademicRole() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileAcademicRole value)  $default,){
final _that = this;
switch (_that) {
case _ProfileAcademicRole():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileAcademicRole value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileAcademicRole() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String profileId,  String roleCode,  String programmeCode,  bool isActive,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileAcademicRole() when $default != null:
return $default(_that.id,_that.profileId,_that.roleCode,_that.programmeCode,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String profileId,  String roleCode,  String programmeCode,  bool isActive,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ProfileAcademicRole():
return $default(_that.id,_that.profileId,_that.roleCode,_that.programmeCode,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String profileId,  String roleCode,  String programmeCode,  bool isActive,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ProfileAcademicRole() when $default != null:
return $default(_that.id,_that.profileId,_that.roleCode,_that.programmeCode,_that.isActive,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProfileAcademicRole implements ProfileAcademicRole {
  const _ProfileAcademicRole({required this.id, required this.profileId, required this.roleCode, required this.programmeCode, required this.isActive, required this.createdAt, required this.updatedAt});
  factory _ProfileAcademicRole.fromJson(Map<String, dynamic> json) => _$ProfileAcademicRoleFromJson(json);

@override final  String id;
@override final  String profileId;
@override final  String roleCode;
// 'student', 'supervisor', 'co_supervisor', 'examiner', 'csp600_lecturer', 'csp650_lecturer', 'fyp_coordinator'
@override final  String programmeCode;
@override final  bool isActive;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of ProfileAcademicRole
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileAcademicRoleCopyWith<_ProfileAcademicRole> get copyWith => __$ProfileAcademicRoleCopyWithImpl<_ProfileAcademicRole>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileAcademicRoleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileAcademicRole&&(identical(other.id, id) || other.id == id)&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.roleCode, roleCode) || other.roleCode == roleCode)&&(identical(other.programmeCode, programmeCode) || other.programmeCode == programmeCode)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,profileId,roleCode,programmeCode,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'ProfileAcademicRole(id: $id, profileId: $profileId, roleCode: $roleCode, programmeCode: $programmeCode, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ProfileAcademicRoleCopyWith<$Res> implements $ProfileAcademicRoleCopyWith<$Res> {
  factory _$ProfileAcademicRoleCopyWith(_ProfileAcademicRole value, $Res Function(_ProfileAcademicRole) _then) = __$ProfileAcademicRoleCopyWithImpl;
@override @useResult
$Res call({
 String id, String profileId, String roleCode, String programmeCode, bool isActive, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$ProfileAcademicRoleCopyWithImpl<$Res>
    implements _$ProfileAcademicRoleCopyWith<$Res> {
  __$ProfileAcademicRoleCopyWithImpl(this._self, this._then);

  final _ProfileAcademicRole _self;
  final $Res Function(_ProfileAcademicRole) _then;

/// Create a copy of ProfileAcademicRole
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? profileId = null,Object? roleCode = null,Object? programmeCode = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_ProfileAcademicRole(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String,roleCode: null == roleCode ? _self.roleCode : roleCode // ignore: cast_nullable_to_non_nullable
as String,programmeCode: null == programmeCode ? _self.programmeCode : programmeCode // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
