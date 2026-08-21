// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fyp_deliverable.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FypDeliverable {

 String get id; String get fypRecordId; String? get deliverableType; String get title; String? get description; String? get fileUrl; int get version; bool get isRequired; String? get submittedBy; DateTime? get submittedAt; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of FypDeliverable
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FypDeliverableCopyWith<FypDeliverable> get copyWith => _$FypDeliverableCopyWithImpl<FypDeliverable>(this as FypDeliverable, _$identity);

  /// Serializes this FypDeliverable to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FypDeliverable&&(identical(other.id, id) || other.id == id)&&(identical(other.fypRecordId, fypRecordId) || other.fypRecordId == fypRecordId)&&(identical(other.deliverableType, deliverableType) || other.deliverableType == deliverableType)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl)&&(identical(other.version, version) || other.version == version)&&(identical(other.isRequired, isRequired) || other.isRequired == isRequired)&&(identical(other.submittedBy, submittedBy) || other.submittedBy == submittedBy)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fypRecordId,deliverableType,title,description,fileUrl,version,isRequired,submittedBy,submittedAt,createdAt,updatedAt);

@override
String toString() {
  return 'FypDeliverable(id: $id, fypRecordId: $fypRecordId, deliverableType: $deliverableType, title: $title, description: $description, fileUrl: $fileUrl, version: $version, isRequired: $isRequired, submittedBy: $submittedBy, submittedAt: $submittedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $FypDeliverableCopyWith<$Res>  {
  factory $FypDeliverableCopyWith(FypDeliverable value, $Res Function(FypDeliverable) _then) = _$FypDeliverableCopyWithImpl;
@useResult
$Res call({
 String id, String fypRecordId, String? deliverableType, String title, String? description, String? fileUrl, int version, bool isRequired, String? submittedBy, DateTime? submittedAt, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$FypDeliverableCopyWithImpl<$Res>
    implements $FypDeliverableCopyWith<$Res> {
  _$FypDeliverableCopyWithImpl(this._self, this._then);

  final FypDeliverable _self;
  final $Res Function(FypDeliverable) _then;

/// Create a copy of FypDeliverable
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fypRecordId = null,Object? deliverableType = freezed,Object? title = null,Object? description = freezed,Object? fileUrl = freezed,Object? version = null,Object? isRequired = null,Object? submittedBy = freezed,Object? submittedAt = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fypRecordId: null == fypRecordId ? _self.fypRecordId : fypRecordId // ignore: cast_nullable_to_non_nullable
as String,deliverableType: freezed == deliverableType ? _self.deliverableType : deliverableType // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,fileUrl: freezed == fileUrl ? _self.fileUrl : fileUrl // ignore: cast_nullable_to_non_nullable
as String?,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,isRequired: null == isRequired ? _self.isRequired : isRequired // ignore: cast_nullable_to_non_nullable
as bool,submittedBy: freezed == submittedBy ? _self.submittedBy : submittedBy // ignore: cast_nullable_to_non_nullable
as String?,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [FypDeliverable].
extension FypDeliverablePatterns on FypDeliverable {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FypDeliverable value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FypDeliverable() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FypDeliverable value)  $default,){
final _that = this;
switch (_that) {
case _FypDeliverable():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FypDeliverable value)?  $default,){
final _that = this;
switch (_that) {
case _FypDeliverable() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fypRecordId,  String? deliverableType,  String title,  String? description,  String? fileUrl,  int version,  bool isRequired,  String? submittedBy,  DateTime? submittedAt,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FypDeliverable() when $default != null:
return $default(_that.id,_that.fypRecordId,_that.deliverableType,_that.title,_that.description,_that.fileUrl,_that.version,_that.isRequired,_that.submittedBy,_that.submittedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fypRecordId,  String? deliverableType,  String title,  String? description,  String? fileUrl,  int version,  bool isRequired,  String? submittedBy,  DateTime? submittedAt,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _FypDeliverable():
return $default(_that.id,_that.fypRecordId,_that.deliverableType,_that.title,_that.description,_that.fileUrl,_that.version,_that.isRequired,_that.submittedBy,_that.submittedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fypRecordId,  String? deliverableType,  String title,  String? description,  String? fileUrl,  int version,  bool isRequired,  String? submittedBy,  DateTime? submittedAt,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _FypDeliverable() when $default != null:
return $default(_that.id,_that.fypRecordId,_that.deliverableType,_that.title,_that.description,_that.fileUrl,_that.version,_that.isRequired,_that.submittedBy,_that.submittedAt,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FypDeliverable implements FypDeliverable {
  const _FypDeliverable({required this.id, required this.fypRecordId, this.deliverableType, required this.title, this.description, this.fileUrl, required this.version, required this.isRequired, this.submittedBy, this.submittedAt, required this.createdAt, required this.updatedAt});
  factory _FypDeliverable.fromJson(Map<String, dynamic> json) => _$FypDeliverableFromJson(json);

@override final  String id;
@override final  String fypRecordId;
@override final  String? deliverableType;
@override final  String title;
@override final  String? description;
@override final  String? fileUrl;
@override final  int version;
@override final  bool isRequired;
@override final  String? submittedBy;
@override final  DateTime? submittedAt;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of FypDeliverable
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FypDeliverableCopyWith<_FypDeliverable> get copyWith => __$FypDeliverableCopyWithImpl<_FypDeliverable>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FypDeliverableToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FypDeliverable&&(identical(other.id, id) || other.id == id)&&(identical(other.fypRecordId, fypRecordId) || other.fypRecordId == fypRecordId)&&(identical(other.deliverableType, deliverableType) || other.deliverableType == deliverableType)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl)&&(identical(other.version, version) || other.version == version)&&(identical(other.isRequired, isRequired) || other.isRequired == isRequired)&&(identical(other.submittedBy, submittedBy) || other.submittedBy == submittedBy)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fypRecordId,deliverableType,title,description,fileUrl,version,isRequired,submittedBy,submittedAt,createdAt,updatedAt);

@override
String toString() {
  return 'FypDeliverable(id: $id, fypRecordId: $fypRecordId, deliverableType: $deliverableType, title: $title, description: $description, fileUrl: $fileUrl, version: $version, isRequired: $isRequired, submittedBy: $submittedBy, submittedAt: $submittedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$FypDeliverableCopyWith<$Res> implements $FypDeliverableCopyWith<$Res> {
  factory _$FypDeliverableCopyWith(_FypDeliverable value, $Res Function(_FypDeliverable) _then) = __$FypDeliverableCopyWithImpl;
@override @useResult
$Res call({
 String id, String fypRecordId, String? deliverableType, String title, String? description, String? fileUrl, int version, bool isRequired, String? submittedBy, DateTime? submittedAt, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$FypDeliverableCopyWithImpl<$Res>
    implements _$FypDeliverableCopyWith<$Res> {
  __$FypDeliverableCopyWithImpl(this._self, this._then);

  final _FypDeliverable _self;
  final $Res Function(_FypDeliverable) _then;

/// Create a copy of FypDeliverable
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fypRecordId = null,Object? deliverableType = freezed,Object? title = null,Object? description = freezed,Object? fileUrl = freezed,Object? version = null,Object? isRequired = null,Object? submittedBy = freezed,Object? submittedAt = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_FypDeliverable(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fypRecordId: null == fypRecordId ? _self.fypRecordId : fypRecordId // ignore: cast_nullable_to_non_nullable
as String,deliverableType: freezed == deliverableType ? _self.deliverableType : deliverableType // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,fileUrl: freezed == fileUrl ? _self.fileUrl : fileUrl // ignore: cast_nullable_to_non_nullable
as String?,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,isRequired: null == isRequired ? _self.isRequired : isRequired // ignore: cast_nullable_to_non_nullable
as bool,submittedBy: freezed == submittedBy ? _self.submittedBy : submittedBy // ignore: cast_nullable_to_non_nullable
as String?,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
