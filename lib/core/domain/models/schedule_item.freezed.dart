// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedule_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ScheduleItem {

 String get id; String get eventId; DateTime get date; String get startAt; String get endAt; String get title; String get venue; String get audience; String? get description; String get visibility; String get publicationStatus; String? get sourceImportId; String? get sourceStagingId; DateTime get createdAt; DateTime get updatedAt; DateTime? get publishedAt;
/// Create a copy of ScheduleItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScheduleItemCopyWith<ScheduleItem> get copyWith => _$ScheduleItemCopyWithImpl<ScheduleItem>(this as ScheduleItem, _$identity);

  /// Serializes this ScheduleItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScheduleItem&&(identical(other.id, id) || other.id == id)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.date, date) || other.date == date)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.title, title) || other.title == title)&&(identical(other.venue, venue) || other.venue == venue)&&(identical(other.audience, audience) || other.audience == audience)&&(identical(other.description, description) || other.description == description)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.publicationStatus, publicationStatus) || other.publicationStatus == publicationStatus)&&(identical(other.sourceImportId, sourceImportId) || other.sourceImportId == sourceImportId)&&(identical(other.sourceStagingId, sourceStagingId) || other.sourceStagingId == sourceStagingId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,eventId,date,startAt,endAt,title,venue,audience,description,visibility,publicationStatus,sourceImportId,sourceStagingId,createdAt,updatedAt,publishedAt);

@override
String toString() {
  return 'ScheduleItem(id: $id, eventId: $eventId, date: $date, startAt: $startAt, endAt: $endAt, title: $title, venue: $venue, audience: $audience, description: $description, visibility: $visibility, publicationStatus: $publicationStatus, sourceImportId: $sourceImportId, sourceStagingId: $sourceStagingId, createdAt: $createdAt, updatedAt: $updatedAt, publishedAt: $publishedAt)';
}


}

/// @nodoc
abstract mixin class $ScheduleItemCopyWith<$Res>  {
  factory $ScheduleItemCopyWith(ScheduleItem value, $Res Function(ScheduleItem) _then) = _$ScheduleItemCopyWithImpl;
@useResult
$Res call({
 String id, String eventId, DateTime date, String startAt, String endAt, String title, String venue, String audience, String? description, String visibility, String publicationStatus, String? sourceImportId, String? sourceStagingId, DateTime createdAt, DateTime updatedAt, DateTime? publishedAt
});




}
/// @nodoc
class _$ScheduleItemCopyWithImpl<$Res>
    implements $ScheduleItemCopyWith<$Res> {
  _$ScheduleItemCopyWithImpl(this._self, this._then);

  final ScheduleItem _self;
  final $Res Function(ScheduleItem) _then;

/// Create a copy of ScheduleItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? eventId = null,Object? date = null,Object? startAt = null,Object? endAt = null,Object? title = null,Object? venue = null,Object? audience = null,Object? description = freezed,Object? visibility = null,Object? publicationStatus = null,Object? sourceImportId = freezed,Object? sourceStagingId = freezed,Object? createdAt = null,Object? updatedAt = null,Object? publishedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as String,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,venue: null == venue ? _self.venue : venue // ignore: cast_nullable_to_non_nullable
as String,audience: null == audience ? _self.audience : audience // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as String,publicationStatus: null == publicationStatus ? _self.publicationStatus : publicationStatus // ignore: cast_nullable_to_non_nullable
as String,sourceImportId: freezed == sourceImportId ? _self.sourceImportId : sourceImportId // ignore: cast_nullable_to_non_nullable
as String?,sourceStagingId: freezed == sourceStagingId ? _self.sourceStagingId : sourceStagingId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ScheduleItem].
extension ScheduleItemPatterns on ScheduleItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScheduleItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScheduleItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScheduleItem value)  $default,){
final _that = this;
switch (_that) {
case _ScheduleItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScheduleItem value)?  $default,){
final _that = this;
switch (_that) {
case _ScheduleItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String eventId,  DateTime date,  String startAt,  String endAt,  String title,  String venue,  String audience,  String? description,  String visibility,  String publicationStatus,  String? sourceImportId,  String? sourceStagingId,  DateTime createdAt,  DateTime updatedAt,  DateTime? publishedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScheduleItem() when $default != null:
return $default(_that.id,_that.eventId,_that.date,_that.startAt,_that.endAt,_that.title,_that.venue,_that.audience,_that.description,_that.visibility,_that.publicationStatus,_that.sourceImportId,_that.sourceStagingId,_that.createdAt,_that.updatedAt,_that.publishedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String eventId,  DateTime date,  String startAt,  String endAt,  String title,  String venue,  String audience,  String? description,  String visibility,  String publicationStatus,  String? sourceImportId,  String? sourceStagingId,  DateTime createdAt,  DateTime updatedAt,  DateTime? publishedAt)  $default,) {final _that = this;
switch (_that) {
case _ScheduleItem():
return $default(_that.id,_that.eventId,_that.date,_that.startAt,_that.endAt,_that.title,_that.venue,_that.audience,_that.description,_that.visibility,_that.publicationStatus,_that.sourceImportId,_that.sourceStagingId,_that.createdAt,_that.updatedAt,_that.publishedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String eventId,  DateTime date,  String startAt,  String endAt,  String title,  String venue,  String audience,  String? description,  String visibility,  String publicationStatus,  String? sourceImportId,  String? sourceStagingId,  DateTime createdAt,  DateTime updatedAt,  DateTime? publishedAt)?  $default,) {final _that = this;
switch (_that) {
case _ScheduleItem() when $default != null:
return $default(_that.id,_that.eventId,_that.date,_that.startAt,_that.endAt,_that.title,_that.venue,_that.audience,_that.description,_that.visibility,_that.publicationStatus,_that.sourceImportId,_that.sourceStagingId,_that.createdAt,_that.updatedAt,_that.publishedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ScheduleItem implements ScheduleItem {
  const _ScheduleItem({required this.id, required this.eventId, required this.date, required this.startAt, required this.endAt, required this.title, required this.venue, required this.audience, this.description, required this.visibility, required this.publicationStatus, this.sourceImportId, this.sourceStagingId, required this.createdAt, required this.updatedAt, this.publishedAt});
  factory _ScheduleItem.fromJson(Map<String, dynamic> json) => _$ScheduleItemFromJson(json);

@override final  String id;
@override final  String eventId;
@override final  DateTime date;
@override final  String startAt;
@override final  String endAt;
@override final  String title;
@override final  String venue;
@override final  String audience;
@override final  String? description;
@override final  String visibility;
@override final  String publicationStatus;
@override final  String? sourceImportId;
@override final  String? sourceStagingId;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? publishedAt;

/// Create a copy of ScheduleItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScheduleItemCopyWith<_ScheduleItem> get copyWith => __$ScheduleItemCopyWithImpl<_ScheduleItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScheduleItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScheduleItem&&(identical(other.id, id) || other.id == id)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.date, date) || other.date == date)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.title, title) || other.title == title)&&(identical(other.venue, venue) || other.venue == venue)&&(identical(other.audience, audience) || other.audience == audience)&&(identical(other.description, description) || other.description == description)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.publicationStatus, publicationStatus) || other.publicationStatus == publicationStatus)&&(identical(other.sourceImportId, sourceImportId) || other.sourceImportId == sourceImportId)&&(identical(other.sourceStagingId, sourceStagingId) || other.sourceStagingId == sourceStagingId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,eventId,date,startAt,endAt,title,venue,audience,description,visibility,publicationStatus,sourceImportId,sourceStagingId,createdAt,updatedAt,publishedAt);

@override
String toString() {
  return 'ScheduleItem(id: $id, eventId: $eventId, date: $date, startAt: $startAt, endAt: $endAt, title: $title, venue: $venue, audience: $audience, description: $description, visibility: $visibility, publicationStatus: $publicationStatus, sourceImportId: $sourceImportId, sourceStagingId: $sourceStagingId, createdAt: $createdAt, updatedAt: $updatedAt, publishedAt: $publishedAt)';
}


}

/// @nodoc
abstract mixin class _$ScheduleItemCopyWith<$Res> implements $ScheduleItemCopyWith<$Res> {
  factory _$ScheduleItemCopyWith(_ScheduleItem value, $Res Function(_ScheduleItem) _then) = __$ScheduleItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String eventId, DateTime date, String startAt, String endAt, String title, String venue, String audience, String? description, String visibility, String publicationStatus, String? sourceImportId, String? sourceStagingId, DateTime createdAt, DateTime updatedAt, DateTime? publishedAt
});




}
/// @nodoc
class __$ScheduleItemCopyWithImpl<$Res>
    implements _$ScheduleItemCopyWith<$Res> {
  __$ScheduleItemCopyWithImpl(this._self, this._then);

  final _ScheduleItem _self;
  final $Res Function(_ScheduleItem) _then;

/// Create a copy of ScheduleItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? eventId = null,Object? date = null,Object? startAt = null,Object? endAt = null,Object? title = null,Object? venue = null,Object? audience = null,Object? description = freezed,Object? visibility = null,Object? publicationStatus = null,Object? sourceImportId = freezed,Object? sourceStagingId = freezed,Object? createdAt = null,Object? updatedAt = null,Object? publishedAt = freezed,}) {
  return _then(_ScheduleItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as String,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,venue: null == venue ? _self.venue : venue // ignore: cast_nullable_to_non_nullable
as String,audience: null == audience ? _self.audience : audience // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as String,publicationStatus: null == publicationStatus ? _self.publicationStatus : publicationStatus // ignore: cast_nullable_to_non_nullable
as String,sourceImportId: freezed == sourceImportId ? _self.sourceImportId : sourceImportId // ignore: cast_nullable_to_non_nullable
as String?,sourceStagingId: freezed == sourceStagingId ? _self.sourceStagingId : sourceStagingId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
