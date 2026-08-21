// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fyp_presentation_slot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FypPresentationSlot {

 String get id; String get sessionId; String get fypRecordId; int get slotNumber; DateTime get startAt; DateTime get endAt; String? get room; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of FypPresentationSlot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FypPresentationSlotCopyWith<FypPresentationSlot> get copyWith => _$FypPresentationSlotCopyWithImpl<FypPresentationSlot>(this as FypPresentationSlot, _$identity);

  /// Serializes this FypPresentationSlot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FypPresentationSlot&&(identical(other.id, id) || other.id == id)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.fypRecordId, fypRecordId) || other.fypRecordId == fypRecordId)&&(identical(other.slotNumber, slotNumber) || other.slotNumber == slotNumber)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.room, room) || other.room == room)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sessionId,fypRecordId,slotNumber,startAt,endAt,room,createdAt,updatedAt);

@override
String toString() {
  return 'FypPresentationSlot(id: $id, sessionId: $sessionId, fypRecordId: $fypRecordId, slotNumber: $slotNumber, startAt: $startAt, endAt: $endAt, room: $room, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $FypPresentationSlotCopyWith<$Res>  {
  factory $FypPresentationSlotCopyWith(FypPresentationSlot value, $Res Function(FypPresentationSlot) _then) = _$FypPresentationSlotCopyWithImpl;
@useResult
$Res call({
 String id, String sessionId, String fypRecordId, int slotNumber, DateTime startAt, DateTime endAt, String? room, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$FypPresentationSlotCopyWithImpl<$Res>
    implements $FypPresentationSlotCopyWith<$Res> {
  _$FypPresentationSlotCopyWithImpl(this._self, this._then);

  final FypPresentationSlot _self;
  final $Res Function(FypPresentationSlot) _then;

/// Create a copy of FypPresentationSlot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sessionId = null,Object? fypRecordId = null,Object? slotNumber = null,Object? startAt = null,Object? endAt = null,Object? room = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,fypRecordId: null == fypRecordId ? _self.fypRecordId : fypRecordId // ignore: cast_nullable_to_non_nullable
as String,slotNumber: null == slotNumber ? _self.slotNumber : slotNumber // ignore: cast_nullable_to_non_nullable
as int,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime,room: freezed == room ? _self.room : room // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [FypPresentationSlot].
extension FypPresentationSlotPatterns on FypPresentationSlot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FypPresentationSlot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FypPresentationSlot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FypPresentationSlot value)  $default,){
final _that = this;
switch (_that) {
case _FypPresentationSlot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FypPresentationSlot value)?  $default,){
final _that = this;
switch (_that) {
case _FypPresentationSlot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String sessionId,  String fypRecordId,  int slotNumber,  DateTime startAt,  DateTime endAt,  String? room,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FypPresentationSlot() when $default != null:
return $default(_that.id,_that.sessionId,_that.fypRecordId,_that.slotNumber,_that.startAt,_that.endAt,_that.room,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String sessionId,  String fypRecordId,  int slotNumber,  DateTime startAt,  DateTime endAt,  String? room,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _FypPresentationSlot():
return $default(_that.id,_that.sessionId,_that.fypRecordId,_that.slotNumber,_that.startAt,_that.endAt,_that.room,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String sessionId,  String fypRecordId,  int slotNumber,  DateTime startAt,  DateTime endAt,  String? room,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _FypPresentationSlot() when $default != null:
return $default(_that.id,_that.sessionId,_that.fypRecordId,_that.slotNumber,_that.startAt,_that.endAt,_that.room,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FypPresentationSlot implements FypPresentationSlot {
  const _FypPresentationSlot({required this.id, required this.sessionId, required this.fypRecordId, required this.slotNumber, required this.startAt, required this.endAt, this.room, required this.createdAt, required this.updatedAt});
  factory _FypPresentationSlot.fromJson(Map<String, dynamic> json) => _$FypPresentationSlotFromJson(json);

@override final  String id;
@override final  String sessionId;
@override final  String fypRecordId;
@override final  int slotNumber;
@override final  DateTime startAt;
@override final  DateTime endAt;
@override final  String? room;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of FypPresentationSlot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FypPresentationSlotCopyWith<_FypPresentationSlot> get copyWith => __$FypPresentationSlotCopyWithImpl<_FypPresentationSlot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FypPresentationSlotToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FypPresentationSlot&&(identical(other.id, id) || other.id == id)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.fypRecordId, fypRecordId) || other.fypRecordId == fypRecordId)&&(identical(other.slotNumber, slotNumber) || other.slotNumber == slotNumber)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.room, room) || other.room == room)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sessionId,fypRecordId,slotNumber,startAt,endAt,room,createdAt,updatedAt);

@override
String toString() {
  return 'FypPresentationSlot(id: $id, sessionId: $sessionId, fypRecordId: $fypRecordId, slotNumber: $slotNumber, startAt: $startAt, endAt: $endAt, room: $room, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$FypPresentationSlotCopyWith<$Res> implements $FypPresentationSlotCopyWith<$Res> {
  factory _$FypPresentationSlotCopyWith(_FypPresentationSlot value, $Res Function(_FypPresentationSlot) _then) = __$FypPresentationSlotCopyWithImpl;
@override @useResult
$Res call({
 String id, String sessionId, String fypRecordId, int slotNumber, DateTime startAt, DateTime endAt, String? room, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$FypPresentationSlotCopyWithImpl<$Res>
    implements _$FypPresentationSlotCopyWith<$Res> {
  __$FypPresentationSlotCopyWithImpl(this._self, this._then);

  final _FypPresentationSlot _self;
  final $Res Function(_FypPresentationSlot) _then;

/// Create a copy of FypPresentationSlot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sessionId = null,Object? fypRecordId = null,Object? slotNumber = null,Object? startAt = null,Object? endAt = null,Object? room = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_FypPresentationSlot(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,fypRecordId: null == fypRecordId ? _self.fypRecordId : fypRecordId // ignore: cast_nullable_to_non_nullable
as String,slotNumber: null == slotNumber ? _self.slotNumber : slotNumber // ignore: cast_nullable_to_non_nullable
as int,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime,room: freezed == room ? _self.room : room // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
