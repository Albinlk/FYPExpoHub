// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feedback_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FeedbackEntry {

 String get id; String? get userId; String get eventId; String get subject; String get message; int? get rating; String? get userAgent; String get status; String? get adminNote; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of FeedbackEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeedbackEntryCopyWith<FeedbackEntry> get copyWith => _$FeedbackEntryCopyWithImpl<FeedbackEntry>(this as FeedbackEntry, _$identity);

  /// Serializes this FeedbackEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedbackEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.message, message) || other.message == message)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.userAgent, userAgent) || other.userAgent == userAgent)&&(identical(other.status, status) || other.status == status)&&(identical(other.adminNote, adminNote) || other.adminNote == adminNote)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,eventId,subject,message,rating,userAgent,status,adminNote,createdAt,updatedAt);

@override
String toString() {
  return 'FeedbackEntry(id: $id, userId: $userId, eventId: $eventId, subject: $subject, message: $message, rating: $rating, userAgent: $userAgent, status: $status, adminNote: $adminNote, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $FeedbackEntryCopyWith<$Res>  {
  factory $FeedbackEntryCopyWith(FeedbackEntry value, $Res Function(FeedbackEntry) _then) = _$FeedbackEntryCopyWithImpl;
@useResult
$Res call({
 String id, String? userId, String eventId, String subject, String message, int? rating, String? userAgent, String status, String? adminNote, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$FeedbackEntryCopyWithImpl<$Res>
    implements $FeedbackEntryCopyWith<$Res> {
  _$FeedbackEntryCopyWithImpl(this._self, this._then);

  final FeedbackEntry _self;
  final $Res Function(FeedbackEntry) _then;

/// Create a copy of FeedbackEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = freezed,Object? eventId = null,Object? subject = null,Object? message = null,Object? rating = freezed,Object? userAgent = freezed,Object? status = null,Object? adminNote = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int?,userAgent: freezed == userAgent ? _self.userAgent : userAgent // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,adminNote: freezed == adminNote ? _self.adminNote : adminNote // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [FeedbackEntry].
extension FeedbackEntryPatterns on FeedbackEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FeedbackEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FeedbackEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FeedbackEntry value)  $default,){
final _that = this;
switch (_that) {
case _FeedbackEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FeedbackEntry value)?  $default,){
final _that = this;
switch (_that) {
case _FeedbackEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? userId,  String eventId,  String subject,  String message,  int? rating,  String? userAgent,  String status,  String? adminNote,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FeedbackEntry() when $default != null:
return $default(_that.id,_that.userId,_that.eventId,_that.subject,_that.message,_that.rating,_that.userAgent,_that.status,_that.adminNote,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? userId,  String eventId,  String subject,  String message,  int? rating,  String? userAgent,  String status,  String? adminNote,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _FeedbackEntry():
return $default(_that.id,_that.userId,_that.eventId,_that.subject,_that.message,_that.rating,_that.userAgent,_that.status,_that.adminNote,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? userId,  String eventId,  String subject,  String message,  int? rating,  String? userAgent,  String status,  String? adminNote,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _FeedbackEntry() when $default != null:
return $default(_that.id,_that.userId,_that.eventId,_that.subject,_that.message,_that.rating,_that.userAgent,_that.status,_that.adminNote,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FeedbackEntry implements FeedbackEntry {
  const _FeedbackEntry({required this.id, this.userId, required this.eventId, required this.subject, required this.message, this.rating, this.userAgent, this.status = 'new', this.adminNote, required this.createdAt, required this.updatedAt});
  factory _FeedbackEntry.fromJson(Map<String, dynamic> json) => _$FeedbackEntryFromJson(json);

@override final  String id;
@override final  String? userId;
@override final  String eventId;
@override final  String subject;
@override final  String message;
@override final  int? rating;
@override final  String? userAgent;
@override@JsonKey() final  String status;
@override final  String? adminNote;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of FeedbackEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeedbackEntryCopyWith<_FeedbackEntry> get copyWith => __$FeedbackEntryCopyWithImpl<_FeedbackEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FeedbackEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeedbackEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.message, message) || other.message == message)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.userAgent, userAgent) || other.userAgent == userAgent)&&(identical(other.status, status) || other.status == status)&&(identical(other.adminNote, adminNote) || other.adminNote == adminNote)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,eventId,subject,message,rating,userAgent,status,adminNote,createdAt,updatedAt);

@override
String toString() {
  return 'FeedbackEntry(id: $id, userId: $userId, eventId: $eventId, subject: $subject, message: $message, rating: $rating, userAgent: $userAgent, status: $status, adminNote: $adminNote, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$FeedbackEntryCopyWith<$Res> implements $FeedbackEntryCopyWith<$Res> {
  factory _$FeedbackEntryCopyWith(_FeedbackEntry value, $Res Function(_FeedbackEntry) _then) = __$FeedbackEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, String? userId, String eventId, String subject, String message, int? rating, String? userAgent, String status, String? adminNote, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$FeedbackEntryCopyWithImpl<$Res>
    implements _$FeedbackEntryCopyWith<$Res> {
  __$FeedbackEntryCopyWithImpl(this._self, this._then);

  final _FeedbackEntry _self;
  final $Res Function(_FeedbackEntry) _then;

/// Create a copy of FeedbackEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = freezed,Object? eventId = null,Object? subject = null,Object? message = null,Object? rating = freezed,Object? userAgent = freezed,Object? status = null,Object? adminNote = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_FeedbackEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int?,userAgent: freezed == userAgent ? _self.userAgent : userAgent // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,adminNote: freezed == adminNote ? _self.adminNote : adminNote // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
