// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fyp_course_offering.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FypCourseOffering {

 String get id; String get academicSemesterId; String get courseCode; String? get lecturerId; bool get isActive; int? get maxStudents; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of FypCourseOffering
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FypCourseOfferingCopyWith<FypCourseOffering> get copyWith => _$FypCourseOfferingCopyWithImpl<FypCourseOffering>(this as FypCourseOffering, _$identity);

  /// Serializes this FypCourseOffering to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FypCourseOffering&&(identical(other.id, id) || other.id == id)&&(identical(other.academicSemesterId, academicSemesterId) || other.academicSemesterId == academicSemesterId)&&(identical(other.courseCode, courseCode) || other.courseCode == courseCode)&&(identical(other.lecturerId, lecturerId) || other.lecturerId == lecturerId)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.maxStudents, maxStudents) || other.maxStudents == maxStudents)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,academicSemesterId,courseCode,lecturerId,isActive,maxStudents,createdAt,updatedAt);

@override
String toString() {
  return 'FypCourseOffering(id: $id, academicSemesterId: $academicSemesterId, courseCode: $courseCode, lecturerId: $lecturerId, isActive: $isActive, maxStudents: $maxStudents, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $FypCourseOfferingCopyWith<$Res>  {
  factory $FypCourseOfferingCopyWith(FypCourseOffering value, $Res Function(FypCourseOffering) _then) = _$FypCourseOfferingCopyWithImpl;
@useResult
$Res call({
 String id, String academicSemesterId, String courseCode, String? lecturerId, bool isActive, int? maxStudents, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$FypCourseOfferingCopyWithImpl<$Res>
    implements $FypCourseOfferingCopyWith<$Res> {
  _$FypCourseOfferingCopyWithImpl(this._self, this._then);

  final FypCourseOffering _self;
  final $Res Function(FypCourseOffering) _then;

/// Create a copy of FypCourseOffering
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? academicSemesterId = null,Object? courseCode = null,Object? lecturerId = freezed,Object? isActive = null,Object? maxStudents = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,academicSemesterId: null == academicSemesterId ? _self.academicSemesterId : academicSemesterId // ignore: cast_nullable_to_non_nullable
as String,courseCode: null == courseCode ? _self.courseCode : courseCode // ignore: cast_nullable_to_non_nullable
as String,lecturerId: freezed == lecturerId ? _self.lecturerId : lecturerId // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,maxStudents: freezed == maxStudents ? _self.maxStudents : maxStudents // ignore: cast_nullable_to_non_nullable
as int?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [FypCourseOffering].
extension FypCourseOfferingPatterns on FypCourseOffering {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FypCourseOffering value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FypCourseOffering() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FypCourseOffering value)  $default,){
final _that = this;
switch (_that) {
case _FypCourseOffering():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FypCourseOffering value)?  $default,){
final _that = this;
switch (_that) {
case _FypCourseOffering() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String academicSemesterId,  String courseCode,  String? lecturerId,  bool isActive,  int? maxStudents,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FypCourseOffering() when $default != null:
return $default(_that.id,_that.academicSemesterId,_that.courseCode,_that.lecturerId,_that.isActive,_that.maxStudents,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String academicSemesterId,  String courseCode,  String? lecturerId,  bool isActive,  int? maxStudents,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _FypCourseOffering():
return $default(_that.id,_that.academicSemesterId,_that.courseCode,_that.lecturerId,_that.isActive,_that.maxStudents,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String academicSemesterId,  String courseCode,  String? lecturerId,  bool isActive,  int? maxStudents,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _FypCourseOffering() when $default != null:
return $default(_that.id,_that.academicSemesterId,_that.courseCode,_that.lecturerId,_that.isActive,_that.maxStudents,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FypCourseOffering implements FypCourseOffering {
  const _FypCourseOffering({required this.id, required this.academicSemesterId, required this.courseCode, this.lecturerId, required this.isActive, this.maxStudents, required this.createdAt, required this.updatedAt});
  factory _FypCourseOffering.fromJson(Map<String, dynamic> json) => _$FypCourseOfferingFromJson(json);

@override final  String id;
@override final  String academicSemesterId;
@override final  String courseCode;
@override final  String? lecturerId;
@override final  bool isActive;
@override final  int? maxStudents;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of FypCourseOffering
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FypCourseOfferingCopyWith<_FypCourseOffering> get copyWith => __$FypCourseOfferingCopyWithImpl<_FypCourseOffering>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FypCourseOfferingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FypCourseOffering&&(identical(other.id, id) || other.id == id)&&(identical(other.academicSemesterId, academicSemesterId) || other.academicSemesterId == academicSemesterId)&&(identical(other.courseCode, courseCode) || other.courseCode == courseCode)&&(identical(other.lecturerId, lecturerId) || other.lecturerId == lecturerId)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.maxStudents, maxStudents) || other.maxStudents == maxStudents)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,academicSemesterId,courseCode,lecturerId,isActive,maxStudents,createdAt,updatedAt);

@override
String toString() {
  return 'FypCourseOffering(id: $id, academicSemesterId: $academicSemesterId, courseCode: $courseCode, lecturerId: $lecturerId, isActive: $isActive, maxStudents: $maxStudents, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$FypCourseOfferingCopyWith<$Res> implements $FypCourseOfferingCopyWith<$Res> {
  factory _$FypCourseOfferingCopyWith(_FypCourseOffering value, $Res Function(_FypCourseOffering) _then) = __$FypCourseOfferingCopyWithImpl;
@override @useResult
$Res call({
 String id, String academicSemesterId, String courseCode, String? lecturerId, bool isActive, int? maxStudents, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$FypCourseOfferingCopyWithImpl<$Res>
    implements _$FypCourseOfferingCopyWith<$Res> {
  __$FypCourseOfferingCopyWithImpl(this._self, this._then);

  final _FypCourseOffering _self;
  final $Res Function(_FypCourseOffering) _then;

/// Create a copy of FypCourseOffering
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? academicSemesterId = null,Object? courseCode = null,Object? lecturerId = freezed,Object? isActive = null,Object? maxStudents = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_FypCourseOffering(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,academicSemesterId: null == academicSemesterId ? _self.academicSemesterId : academicSemesterId // ignore: cast_nullable_to_non_nullable
as String,courseCode: null == courseCode ? _self.courseCode : courseCode // ignore: cast_nullable_to_non_nullable
as String,lecturerId: freezed == lecturerId ? _self.lecturerId : lecturerId // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,maxStudents: freezed == maxStudents ? _self.maxStudents : maxStudents // ignore: cast_nullable_to_non_nullable
as int?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
