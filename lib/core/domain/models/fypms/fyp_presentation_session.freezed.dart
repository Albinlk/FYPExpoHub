// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fyp_presentation_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FypPresentationSession {

 String get id; String? get offeringId; String get sessionCode; String get sessionTitle; DateTime get eventDate; DateTime get startAt; DateTime get endAt; String? get venue; String get sessionType;// 'defence', 'expo'
 DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of FypPresentationSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FypPresentationSessionCopyWith<FypPresentationSession> get copyWith => _$FypPresentationSessionCopyWithImpl<FypPresentationSession>(this as FypPresentationSession, _$identity);

  /// Serializes this FypPresentationSession to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FypPresentationSession&&(identical(other.id, id) || other.id == id)&&(identical(other.offeringId, offeringId) || other.offeringId == offeringId)&&(identical(other.sessionCode, sessionCode) || other.sessionCode == sessionCode)&&(identical(other.sessionTitle, sessionTitle) || other.sessionTitle == sessionTitle)&&(identical(other.eventDate, eventDate) || other.eventDate == eventDate)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.venue, venue) || other.venue == venue)&&(identical(other.sessionType, sessionType) || other.sessionType == sessionType)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,offeringId,sessionCode,sessionTitle,eventDate,startAt,endAt,venue,sessionType,createdAt,updatedAt);

@override
String toString() {
  return 'FypPresentationSession(id: $id, offeringId: $offeringId, sessionCode: $sessionCode, sessionTitle: $sessionTitle, eventDate: $eventDate, startAt: $startAt, endAt: $endAt, venue: $venue, sessionType: $sessionType, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $FypPresentationSessionCopyWith<$Res>  {
  factory $FypPresentationSessionCopyWith(FypPresentationSession value, $Res Function(FypPresentationSession) _then) = _$FypPresentationSessionCopyWithImpl;
@useResult
$Res call({
 String id, String? offeringId, String sessionCode, String sessionTitle, DateTime eventDate, DateTime startAt, DateTime endAt, String? venue, String sessionType, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$FypPresentationSessionCopyWithImpl<$Res>
    implements $FypPresentationSessionCopyWith<$Res> {
  _$FypPresentationSessionCopyWithImpl(this._self, this._then);

  final FypPresentationSession _self;
  final $Res Function(FypPresentationSession) _then;

/// Create a copy of FypPresentationSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? offeringId = freezed,Object? sessionCode = null,Object? sessionTitle = null,Object? eventDate = null,Object? startAt = null,Object? endAt = null,Object? venue = freezed,Object? sessionType = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,offeringId: freezed == offeringId ? _self.offeringId : offeringId // ignore: cast_nullable_to_non_nullable
as String?,sessionCode: null == sessionCode ? _self.sessionCode : sessionCode // ignore: cast_nullable_to_non_nullable
as String,sessionTitle: null == sessionTitle ? _self.sessionTitle : sessionTitle // ignore: cast_nullable_to_non_nullable
as String,eventDate: null == eventDate ? _self.eventDate : eventDate // ignore: cast_nullable_to_non_nullable
as DateTime,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime,venue: freezed == venue ? _self.venue : venue // ignore: cast_nullable_to_non_nullable
as String?,sessionType: null == sessionType ? _self.sessionType : sessionType // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [FypPresentationSession].
extension FypPresentationSessionPatterns on FypPresentationSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FypPresentationSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FypPresentationSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FypPresentationSession value)  $default,){
final _that = this;
switch (_that) {
case _FypPresentationSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FypPresentationSession value)?  $default,){
final _that = this;
switch (_that) {
case _FypPresentationSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? offeringId,  String sessionCode,  String sessionTitle,  DateTime eventDate,  DateTime startAt,  DateTime endAt,  String? venue,  String sessionType,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FypPresentationSession() when $default != null:
return $default(_that.id,_that.offeringId,_that.sessionCode,_that.sessionTitle,_that.eventDate,_that.startAt,_that.endAt,_that.venue,_that.sessionType,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? offeringId,  String sessionCode,  String sessionTitle,  DateTime eventDate,  DateTime startAt,  DateTime endAt,  String? venue,  String sessionType,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _FypPresentationSession():
return $default(_that.id,_that.offeringId,_that.sessionCode,_that.sessionTitle,_that.eventDate,_that.startAt,_that.endAt,_that.venue,_that.sessionType,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? offeringId,  String sessionCode,  String sessionTitle,  DateTime eventDate,  DateTime startAt,  DateTime endAt,  String? venue,  String sessionType,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _FypPresentationSession() when $default != null:
return $default(_that.id,_that.offeringId,_that.sessionCode,_that.sessionTitle,_that.eventDate,_that.startAt,_that.endAt,_that.venue,_that.sessionType,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FypPresentationSession implements FypPresentationSession {
  const _FypPresentationSession({required this.id, this.offeringId, required this.sessionCode, required this.sessionTitle, required this.eventDate, required this.startAt, required this.endAt, this.venue, required this.sessionType, required this.createdAt, required this.updatedAt});
  factory _FypPresentationSession.fromJson(Map<String, dynamic> json) => _$FypPresentationSessionFromJson(json);

@override final  String id;
@override final  String? offeringId;
@override final  String sessionCode;
@override final  String sessionTitle;
@override final  DateTime eventDate;
@override final  DateTime startAt;
@override final  DateTime endAt;
@override final  String? venue;
@override final  String sessionType;
// 'defence', 'expo'
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of FypPresentationSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FypPresentationSessionCopyWith<_FypPresentationSession> get copyWith => __$FypPresentationSessionCopyWithImpl<_FypPresentationSession>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FypPresentationSessionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FypPresentationSession&&(identical(other.id, id) || other.id == id)&&(identical(other.offeringId, offeringId) || other.offeringId == offeringId)&&(identical(other.sessionCode, sessionCode) || other.sessionCode == sessionCode)&&(identical(other.sessionTitle, sessionTitle) || other.sessionTitle == sessionTitle)&&(identical(other.eventDate, eventDate) || other.eventDate == eventDate)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.venue, venue) || other.venue == venue)&&(identical(other.sessionType, sessionType) || other.sessionType == sessionType)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,offeringId,sessionCode,sessionTitle,eventDate,startAt,endAt,venue,sessionType,createdAt,updatedAt);

@override
String toString() {
  return 'FypPresentationSession(id: $id, offeringId: $offeringId, sessionCode: $sessionCode, sessionTitle: $sessionTitle, eventDate: $eventDate, startAt: $startAt, endAt: $endAt, venue: $venue, sessionType: $sessionType, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$FypPresentationSessionCopyWith<$Res> implements $FypPresentationSessionCopyWith<$Res> {
  factory _$FypPresentationSessionCopyWith(_FypPresentationSession value, $Res Function(_FypPresentationSession) _then) = __$FypPresentationSessionCopyWithImpl;
@override @useResult
$Res call({
 String id, String? offeringId, String sessionCode, String sessionTitle, DateTime eventDate, DateTime startAt, DateTime endAt, String? venue, String sessionType, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$FypPresentationSessionCopyWithImpl<$Res>
    implements _$FypPresentationSessionCopyWith<$Res> {
  __$FypPresentationSessionCopyWithImpl(this._self, this._then);

  final _FypPresentationSession _self;
  final $Res Function(_FypPresentationSession) _then;

/// Create a copy of FypPresentationSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? offeringId = freezed,Object? sessionCode = null,Object? sessionTitle = null,Object? eventDate = null,Object? startAt = null,Object? endAt = null,Object? venue = freezed,Object? sessionType = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_FypPresentationSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,offeringId: freezed == offeringId ? _self.offeringId : offeringId // ignore: cast_nullable_to_non_nullable
as String?,sessionCode: null == sessionCode ? _self.sessionCode : sessionCode // ignore: cast_nullable_to_non_nullable
as String,sessionTitle: null == sessionTitle ? _self.sessionTitle : sessionTitle // ignore: cast_nullable_to_non_nullable
as String,eventDate: null == eventDate ? _self.eventDate : eventDate // ignore: cast_nullable_to_non_nullable
as DateTime,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime,venue: freezed == venue ? _self.venue : venue // ignore: cast_nullable_to_non_nullable
as String?,sessionType: null == sessionType ? _self.sessionType : sessionType // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
