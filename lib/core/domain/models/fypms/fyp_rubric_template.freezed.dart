// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fyp_rubric_template.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FypRubricTemplate {

 String get id; String get rubricCode; String get rubricName; String get formCode; List<Map<String, dynamic>> get criteria; int get version; bool get isActive; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of FypRubricTemplate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FypRubricTemplateCopyWith<FypRubricTemplate> get copyWith => _$FypRubricTemplateCopyWithImpl<FypRubricTemplate>(this as FypRubricTemplate, _$identity);

  /// Serializes this FypRubricTemplate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FypRubricTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.rubricCode, rubricCode) || other.rubricCode == rubricCode)&&(identical(other.rubricName, rubricName) || other.rubricName == rubricName)&&(identical(other.formCode, formCode) || other.formCode == formCode)&&const DeepCollectionEquality().equals(other.criteria, criteria)&&(identical(other.version, version) || other.version == version)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,rubricCode,rubricName,formCode,const DeepCollectionEquality().hash(criteria),version,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'FypRubricTemplate(id: $id, rubricCode: $rubricCode, rubricName: $rubricName, formCode: $formCode, criteria: $criteria, version: $version, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $FypRubricTemplateCopyWith<$Res>  {
  factory $FypRubricTemplateCopyWith(FypRubricTemplate value, $Res Function(FypRubricTemplate) _then) = _$FypRubricTemplateCopyWithImpl;
@useResult
$Res call({
 String id, String rubricCode, String rubricName, String formCode, List<Map<String, dynamic>> criteria, int version, bool isActive, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$FypRubricTemplateCopyWithImpl<$Res>
    implements $FypRubricTemplateCopyWith<$Res> {
  _$FypRubricTemplateCopyWithImpl(this._self, this._then);

  final FypRubricTemplate _self;
  final $Res Function(FypRubricTemplate) _then;

/// Create a copy of FypRubricTemplate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? rubricCode = null,Object? rubricName = null,Object? formCode = null,Object? criteria = null,Object? version = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rubricCode: null == rubricCode ? _self.rubricCode : rubricCode // ignore: cast_nullable_to_non_nullable
as String,rubricName: null == rubricName ? _self.rubricName : rubricName // ignore: cast_nullable_to_non_nullable
as String,formCode: null == formCode ? _self.formCode : formCode // ignore: cast_nullable_to_non_nullable
as String,criteria: null == criteria ? _self.criteria : criteria // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [FypRubricTemplate].
extension FypRubricTemplatePatterns on FypRubricTemplate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FypRubricTemplate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FypRubricTemplate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FypRubricTemplate value)  $default,){
final _that = this;
switch (_that) {
case _FypRubricTemplate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FypRubricTemplate value)?  $default,){
final _that = this;
switch (_that) {
case _FypRubricTemplate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String rubricCode,  String rubricName,  String formCode,  List<Map<String, dynamic>> criteria,  int version,  bool isActive,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FypRubricTemplate() when $default != null:
return $default(_that.id,_that.rubricCode,_that.rubricName,_that.formCode,_that.criteria,_that.version,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String rubricCode,  String rubricName,  String formCode,  List<Map<String, dynamic>> criteria,  int version,  bool isActive,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _FypRubricTemplate():
return $default(_that.id,_that.rubricCode,_that.rubricName,_that.formCode,_that.criteria,_that.version,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String rubricCode,  String rubricName,  String formCode,  List<Map<String, dynamic>> criteria,  int version,  bool isActive,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _FypRubricTemplate() when $default != null:
return $default(_that.id,_that.rubricCode,_that.rubricName,_that.formCode,_that.criteria,_that.version,_that.isActive,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FypRubricTemplate implements FypRubricTemplate {
  const _FypRubricTemplate({required this.id, required this.rubricCode, required this.rubricName, required this.formCode, required final  List<Map<String, dynamic>> criteria, required this.version, required this.isActive, required this.createdAt, required this.updatedAt}): _criteria = criteria;
  factory _FypRubricTemplate.fromJson(Map<String, dynamic> json) => _$FypRubricTemplateFromJson(json);

@override final  String id;
@override final  String rubricCode;
@override final  String rubricName;
@override final  String formCode;
 final  List<Map<String, dynamic>> _criteria;
@override List<Map<String, dynamic>> get criteria {
  if (_criteria is EqualUnmodifiableListView) return _criteria;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_criteria);
}

@override final  int version;
@override final  bool isActive;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of FypRubricTemplate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FypRubricTemplateCopyWith<_FypRubricTemplate> get copyWith => __$FypRubricTemplateCopyWithImpl<_FypRubricTemplate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FypRubricTemplateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FypRubricTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.rubricCode, rubricCode) || other.rubricCode == rubricCode)&&(identical(other.rubricName, rubricName) || other.rubricName == rubricName)&&(identical(other.formCode, formCode) || other.formCode == formCode)&&const DeepCollectionEquality().equals(other._criteria, _criteria)&&(identical(other.version, version) || other.version == version)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,rubricCode,rubricName,formCode,const DeepCollectionEquality().hash(_criteria),version,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'FypRubricTemplate(id: $id, rubricCode: $rubricCode, rubricName: $rubricName, formCode: $formCode, criteria: $criteria, version: $version, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$FypRubricTemplateCopyWith<$Res> implements $FypRubricTemplateCopyWith<$Res> {
  factory _$FypRubricTemplateCopyWith(_FypRubricTemplate value, $Res Function(_FypRubricTemplate) _then) = __$FypRubricTemplateCopyWithImpl;
@override @useResult
$Res call({
 String id, String rubricCode, String rubricName, String formCode, List<Map<String, dynamic>> criteria, int version, bool isActive, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$FypRubricTemplateCopyWithImpl<$Res>
    implements _$FypRubricTemplateCopyWith<$Res> {
  __$FypRubricTemplateCopyWithImpl(this._self, this._then);

  final _FypRubricTemplate _self;
  final $Res Function(_FypRubricTemplate) _then;

/// Create a copy of FypRubricTemplate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? rubricCode = null,Object? rubricName = null,Object? formCode = null,Object? criteria = null,Object? version = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_FypRubricTemplate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rubricCode: null == rubricCode ? _self.rubricCode : rubricCode // ignore: cast_nullable_to_non_nullable
as String,rubricName: null == rubricName ? _self.rubricName : rubricName // ignore: cast_nullable_to_non_nullable
as String,formCode: null == formCode ? _self.formCode : formCode // ignore: cast_nullable_to_non_nullable
as String,criteria: null == criteria ? _self._criteria : criteria // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
