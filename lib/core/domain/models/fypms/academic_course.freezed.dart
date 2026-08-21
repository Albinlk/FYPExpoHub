// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'academic_course.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AcademicCourse {

 String get code; String get name; String get stage;// 'formulation', 'project'
 int get creditHours; bool get isActive; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of AcademicCourse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AcademicCourseCopyWith<AcademicCourse> get copyWith => _$AcademicCourseCopyWithImpl<AcademicCourse>(this as AcademicCourse, _$identity);

  /// Serializes this AcademicCourse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AcademicCourse&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.stage, stage) || other.stage == stage)&&(identical(other.creditHours, creditHours) || other.creditHours == creditHours)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,name,stage,creditHours,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'AcademicCourse(code: $code, name: $name, stage: $stage, creditHours: $creditHours, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $AcademicCourseCopyWith<$Res>  {
  factory $AcademicCourseCopyWith(AcademicCourse value, $Res Function(AcademicCourse) _then) = _$AcademicCourseCopyWithImpl;
@useResult
$Res call({
 String code, String name, String stage, int creditHours, bool isActive, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$AcademicCourseCopyWithImpl<$Res>
    implements $AcademicCourseCopyWith<$Res> {
  _$AcademicCourseCopyWithImpl(this._self, this._then);

  final AcademicCourse _self;
  final $Res Function(AcademicCourse) _then;

/// Create a copy of AcademicCourse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? name = null,Object? stage = null,Object? creditHours = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as String,creditHours: null == creditHours ? _self.creditHours : creditHours // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AcademicCourse].
extension AcademicCoursePatterns on AcademicCourse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AcademicCourse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AcademicCourse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AcademicCourse value)  $default,){
final _that = this;
switch (_that) {
case _AcademicCourse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AcademicCourse value)?  $default,){
final _that = this;
switch (_that) {
case _AcademicCourse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  String name,  String stage,  int creditHours,  bool isActive,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AcademicCourse() when $default != null:
return $default(_that.code,_that.name,_that.stage,_that.creditHours,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  String name,  String stage,  int creditHours,  bool isActive,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _AcademicCourse():
return $default(_that.code,_that.name,_that.stage,_that.creditHours,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  String name,  String stage,  int creditHours,  bool isActive,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _AcademicCourse() when $default != null:
return $default(_that.code,_that.name,_that.stage,_that.creditHours,_that.isActive,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AcademicCourse implements AcademicCourse {
  const _AcademicCourse({required this.code, required this.name, required this.stage, required this.creditHours, required this.isActive, required this.createdAt, required this.updatedAt});
  factory _AcademicCourse.fromJson(Map<String, dynamic> json) => _$AcademicCourseFromJson(json);

@override final  String code;
@override final  String name;
@override final  String stage;
// 'formulation', 'project'
@override final  int creditHours;
@override final  bool isActive;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of AcademicCourse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AcademicCourseCopyWith<_AcademicCourse> get copyWith => __$AcademicCourseCopyWithImpl<_AcademicCourse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AcademicCourseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AcademicCourse&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.stage, stage) || other.stage == stage)&&(identical(other.creditHours, creditHours) || other.creditHours == creditHours)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,name,stage,creditHours,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'AcademicCourse(code: $code, name: $name, stage: $stage, creditHours: $creditHours, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$AcademicCourseCopyWith<$Res> implements $AcademicCourseCopyWith<$Res> {
  factory _$AcademicCourseCopyWith(_AcademicCourse value, $Res Function(_AcademicCourse) _then) = __$AcademicCourseCopyWithImpl;
@override @useResult
$Res call({
 String code, String name, String stage, int creditHours, bool isActive, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$AcademicCourseCopyWithImpl<$Res>
    implements _$AcademicCourseCopyWith<$Res> {
  __$AcademicCourseCopyWithImpl(this._self, this._then);

  final _AcademicCourse _self;
  final $Res Function(_AcademicCourse) _then;

/// Create a copy of AcademicCourse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? name = null,Object? stage = null,Object? creditHours = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_AcademicCourse(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as String,creditHours: null == creditHours ? _self.creditHours : creditHours // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
