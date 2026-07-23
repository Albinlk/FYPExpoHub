// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booth.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Booth {

 String get id; String get eventId; String get boothNumber; String get zone; String get locationNote; String? get staticFloorPlanUrl; String? get projectId; String get publicationStatus; DateTime get createdAt; DateTime get updatedAt; DateTime? get publishedAt;
/// Create a copy of Booth
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BoothCopyWith<Booth> get copyWith => _$BoothCopyWithImpl<Booth>(this as Booth, _$identity);

  /// Serializes this Booth to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Booth&&(identical(other.id, id) || other.id == id)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.boothNumber, boothNumber) || other.boothNumber == boothNumber)&&(identical(other.zone, zone) || other.zone == zone)&&(identical(other.locationNote, locationNote) || other.locationNote == locationNote)&&(identical(other.staticFloorPlanUrl, staticFloorPlanUrl) || other.staticFloorPlanUrl == staticFloorPlanUrl)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.publicationStatus, publicationStatus) || other.publicationStatus == publicationStatus)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,eventId,boothNumber,zone,locationNote,staticFloorPlanUrl,projectId,publicationStatus,createdAt,updatedAt,publishedAt);

@override
String toString() {
  return 'Booth(id: $id, eventId: $eventId, boothNumber: $boothNumber, zone: $zone, locationNote: $locationNote, staticFloorPlanUrl: $staticFloorPlanUrl, projectId: $projectId, publicationStatus: $publicationStatus, createdAt: $createdAt, updatedAt: $updatedAt, publishedAt: $publishedAt)';
}


}

/// @nodoc
abstract mixin class $BoothCopyWith<$Res>  {
  factory $BoothCopyWith(Booth value, $Res Function(Booth) _then) = _$BoothCopyWithImpl;
@useResult
$Res call({
 String id, String eventId, String boothNumber, String zone, String locationNote, String? staticFloorPlanUrl, String? projectId, String publicationStatus, DateTime createdAt, DateTime updatedAt, DateTime? publishedAt
});




}
/// @nodoc
class _$BoothCopyWithImpl<$Res>
    implements $BoothCopyWith<$Res> {
  _$BoothCopyWithImpl(this._self, this._then);

  final Booth _self;
  final $Res Function(Booth) _then;

/// Create a copy of Booth
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? eventId = null,Object? boothNumber = null,Object? zone = null,Object? locationNote = null,Object? staticFloorPlanUrl = freezed,Object? projectId = freezed,Object? publicationStatus = null,Object? createdAt = null,Object? updatedAt = null,Object? publishedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,boothNumber: null == boothNumber ? _self.boothNumber : boothNumber // ignore: cast_nullable_to_non_nullable
as String,zone: null == zone ? _self.zone : zone // ignore: cast_nullable_to_non_nullable
as String,locationNote: null == locationNote ? _self.locationNote : locationNote // ignore: cast_nullable_to_non_nullable
as String,staticFloorPlanUrl: freezed == staticFloorPlanUrl ? _self.staticFloorPlanUrl : staticFloorPlanUrl // ignore: cast_nullable_to_non_nullable
as String?,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,publicationStatus: null == publicationStatus ? _self.publicationStatus : publicationStatus // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Booth].
extension BoothPatterns on Booth {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Booth value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Booth() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Booth value)  $default,){
final _that = this;
switch (_that) {
case _Booth():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Booth value)?  $default,){
final _that = this;
switch (_that) {
case _Booth() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String eventId,  String boothNumber,  String zone,  String locationNote,  String? staticFloorPlanUrl,  String? projectId,  String publicationStatus,  DateTime createdAt,  DateTime updatedAt,  DateTime? publishedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Booth() when $default != null:
return $default(_that.id,_that.eventId,_that.boothNumber,_that.zone,_that.locationNote,_that.staticFloorPlanUrl,_that.projectId,_that.publicationStatus,_that.createdAt,_that.updatedAt,_that.publishedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String eventId,  String boothNumber,  String zone,  String locationNote,  String? staticFloorPlanUrl,  String? projectId,  String publicationStatus,  DateTime createdAt,  DateTime updatedAt,  DateTime? publishedAt)  $default,) {final _that = this;
switch (_that) {
case _Booth():
return $default(_that.id,_that.eventId,_that.boothNumber,_that.zone,_that.locationNote,_that.staticFloorPlanUrl,_that.projectId,_that.publicationStatus,_that.createdAt,_that.updatedAt,_that.publishedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String eventId,  String boothNumber,  String zone,  String locationNote,  String? staticFloorPlanUrl,  String? projectId,  String publicationStatus,  DateTime createdAt,  DateTime updatedAt,  DateTime? publishedAt)?  $default,) {final _that = this;
switch (_that) {
case _Booth() when $default != null:
return $default(_that.id,_that.eventId,_that.boothNumber,_that.zone,_that.locationNote,_that.staticFloorPlanUrl,_that.projectId,_that.publicationStatus,_that.createdAt,_that.updatedAt,_that.publishedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Booth implements Booth {
  const _Booth({required this.id, required this.eventId, required this.boothNumber, required this.zone, required this.locationNote, this.staticFloorPlanUrl, this.projectId, required this.publicationStatus, required this.createdAt, required this.updatedAt, this.publishedAt});
  factory _Booth.fromJson(Map<String, dynamic> json) => _$BoothFromJson(json);

@override final  String id;
@override final  String eventId;
@override final  String boothNumber;
@override final  String zone;
@override final  String locationNote;
@override final  String? staticFloorPlanUrl;
@override final  String? projectId;
@override final  String publicationStatus;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? publishedAt;

/// Create a copy of Booth
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BoothCopyWith<_Booth> get copyWith => __$BoothCopyWithImpl<_Booth>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BoothToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Booth&&(identical(other.id, id) || other.id == id)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.boothNumber, boothNumber) || other.boothNumber == boothNumber)&&(identical(other.zone, zone) || other.zone == zone)&&(identical(other.locationNote, locationNote) || other.locationNote == locationNote)&&(identical(other.staticFloorPlanUrl, staticFloorPlanUrl) || other.staticFloorPlanUrl == staticFloorPlanUrl)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.publicationStatus, publicationStatus) || other.publicationStatus == publicationStatus)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,eventId,boothNumber,zone,locationNote,staticFloorPlanUrl,projectId,publicationStatus,createdAt,updatedAt,publishedAt);

@override
String toString() {
  return 'Booth(id: $id, eventId: $eventId, boothNumber: $boothNumber, zone: $zone, locationNote: $locationNote, staticFloorPlanUrl: $staticFloorPlanUrl, projectId: $projectId, publicationStatus: $publicationStatus, createdAt: $createdAt, updatedAt: $updatedAt, publishedAt: $publishedAt)';
}


}

/// @nodoc
abstract mixin class _$BoothCopyWith<$Res> implements $BoothCopyWith<$Res> {
  factory _$BoothCopyWith(_Booth value, $Res Function(_Booth) _then) = __$BoothCopyWithImpl;
@override @useResult
$Res call({
 String id, String eventId, String boothNumber, String zone, String locationNote, String? staticFloorPlanUrl, String? projectId, String publicationStatus, DateTime createdAt, DateTime updatedAt, DateTime? publishedAt
});




}
/// @nodoc
class __$BoothCopyWithImpl<$Res>
    implements _$BoothCopyWith<$Res> {
  __$BoothCopyWithImpl(this._self, this._then);

  final _Booth _self;
  final $Res Function(_Booth) _then;

/// Create a copy of Booth
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? eventId = null,Object? boothNumber = null,Object? zone = null,Object? locationNote = null,Object? staticFloorPlanUrl = freezed,Object? projectId = freezed,Object? publicationStatus = null,Object? createdAt = null,Object? updatedAt = null,Object? publishedAt = freezed,}) {
  return _then(_Booth(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,boothNumber: null == boothNumber ? _self.boothNumber : boothNumber // ignore: cast_nullable_to_non_nullable
as String,zone: null == zone ? _self.zone : zone // ignore: cast_nullable_to_non_nullable
as String,locationNote: null == locationNote ? _self.locationNote : locationNote // ignore: cast_nullable_to_non_nullable
as String,staticFloorPlanUrl: freezed == staticFloorPlanUrl ? _self.staticFloorPlanUrl : staticFloorPlanUrl // ignore: cast_nullable_to_non_nullable
as String?,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,publicationStatus: null == publicationStatus ? _self.publicationStatus : publicationStatus // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
