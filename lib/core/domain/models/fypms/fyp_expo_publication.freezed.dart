// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fyp_expo_publication.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FypExpoPublication {

 String get id; String get fypRecordId; String get eventId; String get status;// 'draft', 'ready', 'published', 'failed'
 Map<String, dynamic> get payload; String? get publishedProjectId; String? get preparedBy; DateTime? get preparedAt; String? get publishedBy; DateTime? get publishedAt; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of FypExpoPublication
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FypExpoPublicationCopyWith<FypExpoPublication> get copyWith => _$FypExpoPublicationCopyWithImpl<FypExpoPublication>(this as FypExpoPublication, _$identity);

  /// Serializes this FypExpoPublication to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FypExpoPublication&&(identical(other.id, id) || other.id == id)&&(identical(other.fypRecordId, fypRecordId) || other.fypRecordId == fypRecordId)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.payload, payload)&&(identical(other.publishedProjectId, publishedProjectId) || other.publishedProjectId == publishedProjectId)&&(identical(other.preparedBy, preparedBy) || other.preparedBy == preparedBy)&&(identical(other.preparedAt, preparedAt) || other.preparedAt == preparedAt)&&(identical(other.publishedBy, publishedBy) || other.publishedBy == publishedBy)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fypRecordId,eventId,status,const DeepCollectionEquality().hash(payload),publishedProjectId,preparedBy,preparedAt,publishedBy,publishedAt,createdAt,updatedAt);

@override
String toString() {
  return 'FypExpoPublication(id: $id, fypRecordId: $fypRecordId, eventId: $eventId, status: $status, payload: $payload, publishedProjectId: $publishedProjectId, preparedBy: $preparedBy, preparedAt: $preparedAt, publishedBy: $publishedBy, publishedAt: $publishedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $FypExpoPublicationCopyWith<$Res>  {
  factory $FypExpoPublicationCopyWith(FypExpoPublication value, $Res Function(FypExpoPublication) _then) = _$FypExpoPublicationCopyWithImpl;
@useResult
$Res call({
 String id, String fypRecordId, String eventId, String status, Map<String, dynamic> payload, String? publishedProjectId, String? preparedBy, DateTime? preparedAt, String? publishedBy, DateTime? publishedAt, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$FypExpoPublicationCopyWithImpl<$Res>
    implements $FypExpoPublicationCopyWith<$Res> {
  _$FypExpoPublicationCopyWithImpl(this._self, this._then);

  final FypExpoPublication _self;
  final $Res Function(FypExpoPublication) _then;

/// Create a copy of FypExpoPublication
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fypRecordId = null,Object? eventId = null,Object? status = null,Object? payload = null,Object? publishedProjectId = freezed,Object? preparedBy = freezed,Object? preparedAt = freezed,Object? publishedBy = freezed,Object? publishedAt = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fypRecordId: null == fypRecordId ? _self.fypRecordId : fypRecordId // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,payload: null == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,publishedProjectId: freezed == publishedProjectId ? _self.publishedProjectId : publishedProjectId // ignore: cast_nullable_to_non_nullable
as String?,preparedBy: freezed == preparedBy ? _self.preparedBy : preparedBy // ignore: cast_nullable_to_non_nullable
as String?,preparedAt: freezed == preparedAt ? _self.preparedAt : preparedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,publishedBy: freezed == publishedBy ? _self.publishedBy : publishedBy // ignore: cast_nullable_to_non_nullable
as String?,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [FypExpoPublication].
extension FypExpoPublicationPatterns on FypExpoPublication {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FypExpoPublication value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FypExpoPublication() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FypExpoPublication value)  $default,){
final _that = this;
switch (_that) {
case _FypExpoPublication():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FypExpoPublication value)?  $default,){
final _that = this;
switch (_that) {
case _FypExpoPublication() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fypRecordId,  String eventId,  String status,  Map<String, dynamic> payload,  String? publishedProjectId,  String? preparedBy,  DateTime? preparedAt,  String? publishedBy,  DateTime? publishedAt,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FypExpoPublication() when $default != null:
return $default(_that.id,_that.fypRecordId,_that.eventId,_that.status,_that.payload,_that.publishedProjectId,_that.preparedBy,_that.preparedAt,_that.publishedBy,_that.publishedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fypRecordId,  String eventId,  String status,  Map<String, dynamic> payload,  String? publishedProjectId,  String? preparedBy,  DateTime? preparedAt,  String? publishedBy,  DateTime? publishedAt,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _FypExpoPublication():
return $default(_that.id,_that.fypRecordId,_that.eventId,_that.status,_that.payload,_that.publishedProjectId,_that.preparedBy,_that.preparedAt,_that.publishedBy,_that.publishedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fypRecordId,  String eventId,  String status,  Map<String, dynamic> payload,  String? publishedProjectId,  String? preparedBy,  DateTime? preparedAt,  String? publishedBy,  DateTime? publishedAt,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _FypExpoPublication() when $default != null:
return $default(_that.id,_that.fypRecordId,_that.eventId,_that.status,_that.payload,_that.publishedProjectId,_that.preparedBy,_that.preparedAt,_that.publishedBy,_that.publishedAt,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FypExpoPublication implements FypExpoPublication {
  const _FypExpoPublication({required this.id, required this.fypRecordId, required this.eventId, required this.status, required final  Map<String, dynamic> payload, this.publishedProjectId, this.preparedBy, this.preparedAt, this.publishedBy, this.publishedAt, required this.createdAt, required this.updatedAt}): _payload = payload;
  factory _FypExpoPublication.fromJson(Map<String, dynamic> json) => _$FypExpoPublicationFromJson(json);

@override final  String id;
@override final  String fypRecordId;
@override final  String eventId;
@override final  String status;
// 'draft', 'ready', 'published', 'failed'
 final  Map<String, dynamic> _payload;
// 'draft', 'ready', 'published', 'failed'
@override Map<String, dynamic> get payload {
  if (_payload is EqualUnmodifiableMapView) return _payload;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_payload);
}

@override final  String? publishedProjectId;
@override final  String? preparedBy;
@override final  DateTime? preparedAt;
@override final  String? publishedBy;
@override final  DateTime? publishedAt;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of FypExpoPublication
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FypExpoPublicationCopyWith<_FypExpoPublication> get copyWith => __$FypExpoPublicationCopyWithImpl<_FypExpoPublication>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FypExpoPublicationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FypExpoPublication&&(identical(other.id, id) || other.id == id)&&(identical(other.fypRecordId, fypRecordId) || other.fypRecordId == fypRecordId)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._payload, _payload)&&(identical(other.publishedProjectId, publishedProjectId) || other.publishedProjectId == publishedProjectId)&&(identical(other.preparedBy, preparedBy) || other.preparedBy == preparedBy)&&(identical(other.preparedAt, preparedAt) || other.preparedAt == preparedAt)&&(identical(other.publishedBy, publishedBy) || other.publishedBy == publishedBy)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fypRecordId,eventId,status,const DeepCollectionEquality().hash(_payload),publishedProjectId,preparedBy,preparedAt,publishedBy,publishedAt,createdAt,updatedAt);

@override
String toString() {
  return 'FypExpoPublication(id: $id, fypRecordId: $fypRecordId, eventId: $eventId, status: $status, payload: $payload, publishedProjectId: $publishedProjectId, preparedBy: $preparedBy, preparedAt: $preparedAt, publishedBy: $publishedBy, publishedAt: $publishedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$FypExpoPublicationCopyWith<$Res> implements $FypExpoPublicationCopyWith<$Res> {
  factory _$FypExpoPublicationCopyWith(_FypExpoPublication value, $Res Function(_FypExpoPublication) _then) = __$FypExpoPublicationCopyWithImpl;
@override @useResult
$Res call({
 String id, String fypRecordId, String eventId, String status, Map<String, dynamic> payload, String? publishedProjectId, String? preparedBy, DateTime? preparedAt, String? publishedBy, DateTime? publishedAt, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$FypExpoPublicationCopyWithImpl<$Res>
    implements _$FypExpoPublicationCopyWith<$Res> {
  __$FypExpoPublicationCopyWithImpl(this._self, this._then);

  final _FypExpoPublication _self;
  final $Res Function(_FypExpoPublication) _then;

/// Create a copy of FypExpoPublication
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fypRecordId = null,Object? eventId = null,Object? status = null,Object? payload = null,Object? publishedProjectId = freezed,Object? preparedBy = freezed,Object? preparedAt = freezed,Object? publishedBy = freezed,Object? publishedAt = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_FypExpoPublication(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fypRecordId: null == fypRecordId ? _self.fypRecordId : fypRecordId // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,payload: null == payload ? _self._payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,publishedProjectId: freezed == publishedProjectId ? _self.publishedProjectId : publishedProjectId // ignore: cast_nullable_to_non_nullable
as String?,preparedBy: freezed == preparedBy ? _self.preparedBy : preparedBy // ignore: cast_nullable_to_non_nullable
as String?,preparedAt: freezed == preparedAt ? _self.preparedAt : preparedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,publishedBy: freezed == publishedBy ? _self.publishedBy : publishedBy // ignore: cast_nullable_to_non_nullable
as String?,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
