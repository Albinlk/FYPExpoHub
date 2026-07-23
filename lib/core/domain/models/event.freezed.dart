// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FaqItem {

 String get question; String get answer;
/// Create a copy of FaqItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FaqItemCopyWith<FaqItem> get copyWith => _$FaqItemCopyWithImpl<FaqItem>(this as FaqItem, _$identity);

  /// Serializes this FaqItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FaqItem&&(identical(other.question, question) || other.question == question)&&(identical(other.answer, answer) || other.answer == answer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,question,answer);

@override
String toString() {
  return 'FaqItem(question: $question, answer: $answer)';
}


}

/// @nodoc
abstract mixin class $FaqItemCopyWith<$Res>  {
  factory $FaqItemCopyWith(FaqItem value, $Res Function(FaqItem) _then) = _$FaqItemCopyWithImpl;
@useResult
$Res call({
 String question, String answer
});




}
/// @nodoc
class _$FaqItemCopyWithImpl<$Res>
    implements $FaqItemCopyWith<$Res> {
  _$FaqItemCopyWithImpl(this._self, this._then);

  final FaqItem _self;
  final $Res Function(FaqItem) _then;

/// Create a copy of FaqItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? question = null,Object? answer = null,}) {
  return _then(_self.copyWith(
question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,answer: null == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [FaqItem].
extension FaqItemPatterns on FaqItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FaqItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FaqItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FaqItem value)  $default,){
final _that = this;
switch (_that) {
case _FaqItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FaqItem value)?  $default,){
final _that = this;
switch (_that) {
case _FaqItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String question,  String answer)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FaqItem() when $default != null:
return $default(_that.question,_that.answer);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String question,  String answer)  $default,) {final _that = this;
switch (_that) {
case _FaqItem():
return $default(_that.question,_that.answer);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String question,  String answer)?  $default,) {final _that = this;
switch (_that) {
case _FaqItem() when $default != null:
return $default(_that.question,_that.answer);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FaqItem implements FaqItem {
  const _FaqItem({required this.question, required this.answer});
  factory _FaqItem.fromJson(Map<String, dynamic> json) => _$FaqItemFromJson(json);

@override final  String question;
@override final  String answer;

/// Create a copy of FaqItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FaqItemCopyWith<_FaqItem> get copyWith => __$FaqItemCopyWithImpl<_FaqItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FaqItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FaqItem&&(identical(other.question, question) || other.question == question)&&(identical(other.answer, answer) || other.answer == answer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,question,answer);

@override
String toString() {
  return 'FaqItem(question: $question, answer: $answer)';
}


}

/// @nodoc
abstract mixin class _$FaqItemCopyWith<$Res> implements $FaqItemCopyWith<$Res> {
  factory _$FaqItemCopyWith(_FaqItem value, $Res Function(_FaqItem) _then) = __$FaqItemCopyWithImpl;
@override @useResult
$Res call({
 String question, String answer
});




}
/// @nodoc
class __$FaqItemCopyWithImpl<$Res>
    implements _$FaqItemCopyWith<$Res> {
  __$FaqItemCopyWithImpl(this._self, this._then);

  final _FaqItem _self;
  final $Res Function(_FaqItem) _then;

/// Create a copy of FaqItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? question = null,Object? answer = null,}) {
  return _then(_FaqItem(
question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,answer: null == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Event {

 String get id; String get title; String get sessionLabel; DateTime get startAt; DateTime get endAt; String get dailyHours; String get venue; String get locationDetails; String? get mapUrl; String get description; List<String> get objectives; String get status; String get heroImageUrl; String get posterUrl; String get publicContactEmail; List<FaqItem> get faqItems; String get publicationStatus; DateTime get updatedAt; DateTime? get publishedAt;
/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventCopyWith<Event> get copyWith => _$EventCopyWithImpl<Event>(this as Event, _$identity);

  /// Serializes this Event to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Event&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.sessionLabel, sessionLabel) || other.sessionLabel == sessionLabel)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.dailyHours, dailyHours) || other.dailyHours == dailyHours)&&(identical(other.venue, venue) || other.venue == venue)&&(identical(other.locationDetails, locationDetails) || other.locationDetails == locationDetails)&&(identical(other.mapUrl, mapUrl) || other.mapUrl == mapUrl)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.objectives, objectives)&&(identical(other.status, status) || other.status == status)&&(identical(other.heroImageUrl, heroImageUrl) || other.heroImageUrl == heroImageUrl)&&(identical(other.posterUrl, posterUrl) || other.posterUrl == posterUrl)&&(identical(other.publicContactEmail, publicContactEmail) || other.publicContactEmail == publicContactEmail)&&const DeepCollectionEquality().equals(other.faqItems, faqItems)&&(identical(other.publicationStatus, publicationStatus) || other.publicationStatus == publicationStatus)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,sessionLabel,startAt,endAt,dailyHours,venue,locationDetails,mapUrl,description,const DeepCollectionEquality().hash(objectives),status,heroImageUrl,posterUrl,publicContactEmail,const DeepCollectionEquality().hash(faqItems),publicationStatus,updatedAt,publishedAt]);

@override
String toString() {
  return 'Event(id: $id, title: $title, sessionLabel: $sessionLabel, startAt: $startAt, endAt: $endAt, dailyHours: $dailyHours, venue: $venue, locationDetails: $locationDetails, mapUrl: $mapUrl, description: $description, objectives: $objectives, status: $status, heroImageUrl: $heroImageUrl, posterUrl: $posterUrl, publicContactEmail: $publicContactEmail, faqItems: $faqItems, publicationStatus: $publicationStatus, updatedAt: $updatedAt, publishedAt: $publishedAt)';
}


}

/// @nodoc
abstract mixin class $EventCopyWith<$Res>  {
  factory $EventCopyWith(Event value, $Res Function(Event) _then) = _$EventCopyWithImpl;
@useResult
$Res call({
 String id, String title, String sessionLabel, DateTime startAt, DateTime endAt, String dailyHours, String venue, String locationDetails, String? mapUrl, String description, List<String> objectives, String status, String heroImageUrl, String posterUrl, String publicContactEmail, List<FaqItem> faqItems, String publicationStatus, DateTime updatedAt, DateTime? publishedAt
});




}
/// @nodoc
class _$EventCopyWithImpl<$Res>
    implements $EventCopyWith<$Res> {
  _$EventCopyWithImpl(this._self, this._then);

  final Event _self;
  final $Res Function(Event) _then;

/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? sessionLabel = null,Object? startAt = null,Object? endAt = null,Object? dailyHours = null,Object? venue = null,Object? locationDetails = null,Object? mapUrl = freezed,Object? description = null,Object? objectives = null,Object? status = null,Object? heroImageUrl = null,Object? posterUrl = null,Object? publicContactEmail = null,Object? faqItems = null,Object? publicationStatus = null,Object? updatedAt = null,Object? publishedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,sessionLabel: null == sessionLabel ? _self.sessionLabel : sessionLabel // ignore: cast_nullable_to_non_nullable
as String,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime,dailyHours: null == dailyHours ? _self.dailyHours : dailyHours // ignore: cast_nullable_to_non_nullable
as String,venue: null == venue ? _self.venue : venue // ignore: cast_nullable_to_non_nullable
as String,locationDetails: null == locationDetails ? _self.locationDetails : locationDetails // ignore: cast_nullable_to_non_nullable
as String,mapUrl: freezed == mapUrl ? _self.mapUrl : mapUrl // ignore: cast_nullable_to_non_nullable
as String?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,objectives: null == objectives ? _self.objectives : objectives // ignore: cast_nullable_to_non_nullable
as List<String>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,heroImageUrl: null == heroImageUrl ? _self.heroImageUrl : heroImageUrl // ignore: cast_nullable_to_non_nullable
as String,posterUrl: null == posterUrl ? _self.posterUrl : posterUrl // ignore: cast_nullable_to_non_nullable
as String,publicContactEmail: null == publicContactEmail ? _self.publicContactEmail : publicContactEmail // ignore: cast_nullable_to_non_nullable
as String,faqItems: null == faqItems ? _self.faqItems : faqItems // ignore: cast_nullable_to_non_nullable
as List<FaqItem>,publicationStatus: null == publicationStatus ? _self.publicationStatus : publicationStatus // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Event].
extension EventPatterns on Event {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Event value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Event() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Event value)  $default,){
final _that = this;
switch (_that) {
case _Event():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Event value)?  $default,){
final _that = this;
switch (_that) {
case _Event() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String sessionLabel,  DateTime startAt,  DateTime endAt,  String dailyHours,  String venue,  String locationDetails,  String? mapUrl,  String description,  List<String> objectives,  String status,  String heroImageUrl,  String posterUrl,  String publicContactEmail,  List<FaqItem> faqItems,  String publicationStatus,  DateTime updatedAt,  DateTime? publishedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Event() when $default != null:
return $default(_that.id,_that.title,_that.sessionLabel,_that.startAt,_that.endAt,_that.dailyHours,_that.venue,_that.locationDetails,_that.mapUrl,_that.description,_that.objectives,_that.status,_that.heroImageUrl,_that.posterUrl,_that.publicContactEmail,_that.faqItems,_that.publicationStatus,_that.updatedAt,_that.publishedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String sessionLabel,  DateTime startAt,  DateTime endAt,  String dailyHours,  String venue,  String locationDetails,  String? mapUrl,  String description,  List<String> objectives,  String status,  String heroImageUrl,  String posterUrl,  String publicContactEmail,  List<FaqItem> faqItems,  String publicationStatus,  DateTime updatedAt,  DateTime? publishedAt)  $default,) {final _that = this;
switch (_that) {
case _Event():
return $default(_that.id,_that.title,_that.sessionLabel,_that.startAt,_that.endAt,_that.dailyHours,_that.venue,_that.locationDetails,_that.mapUrl,_that.description,_that.objectives,_that.status,_that.heroImageUrl,_that.posterUrl,_that.publicContactEmail,_that.faqItems,_that.publicationStatus,_that.updatedAt,_that.publishedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String sessionLabel,  DateTime startAt,  DateTime endAt,  String dailyHours,  String venue,  String locationDetails,  String? mapUrl,  String description,  List<String> objectives,  String status,  String heroImageUrl,  String posterUrl,  String publicContactEmail,  List<FaqItem> faqItems,  String publicationStatus,  DateTime updatedAt,  DateTime? publishedAt)?  $default,) {final _that = this;
switch (_that) {
case _Event() when $default != null:
return $default(_that.id,_that.title,_that.sessionLabel,_that.startAt,_that.endAt,_that.dailyHours,_that.venue,_that.locationDetails,_that.mapUrl,_that.description,_that.objectives,_that.status,_that.heroImageUrl,_that.posterUrl,_that.publicContactEmail,_that.faqItems,_that.publicationStatus,_that.updatedAt,_that.publishedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Event implements Event {
  const _Event({required this.id, required this.title, required this.sessionLabel, required this.startAt, required this.endAt, required this.dailyHours, required this.venue, required this.locationDetails, this.mapUrl, required this.description, required final  List<String> objectives, required this.status, required this.heroImageUrl, required this.posterUrl, required this.publicContactEmail, required final  List<FaqItem> faqItems, required this.publicationStatus, required this.updatedAt, this.publishedAt}): _objectives = objectives,_faqItems = faqItems;
  factory _Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

@override final  String id;
@override final  String title;
@override final  String sessionLabel;
@override final  DateTime startAt;
@override final  DateTime endAt;
@override final  String dailyHours;
@override final  String venue;
@override final  String locationDetails;
@override final  String? mapUrl;
@override final  String description;
 final  List<String> _objectives;
@override List<String> get objectives {
  if (_objectives is EqualUnmodifiableListView) return _objectives;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_objectives);
}

@override final  String status;
@override final  String heroImageUrl;
@override final  String posterUrl;
@override final  String publicContactEmail;
 final  List<FaqItem> _faqItems;
@override List<FaqItem> get faqItems {
  if (_faqItems is EqualUnmodifiableListView) return _faqItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_faqItems);
}

@override final  String publicationStatus;
@override final  DateTime updatedAt;
@override final  DateTime? publishedAt;

/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventCopyWith<_Event> get copyWith => __$EventCopyWithImpl<_Event>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Event&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.sessionLabel, sessionLabel) || other.sessionLabel == sessionLabel)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.dailyHours, dailyHours) || other.dailyHours == dailyHours)&&(identical(other.venue, venue) || other.venue == venue)&&(identical(other.locationDetails, locationDetails) || other.locationDetails == locationDetails)&&(identical(other.mapUrl, mapUrl) || other.mapUrl == mapUrl)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._objectives, _objectives)&&(identical(other.status, status) || other.status == status)&&(identical(other.heroImageUrl, heroImageUrl) || other.heroImageUrl == heroImageUrl)&&(identical(other.posterUrl, posterUrl) || other.posterUrl == posterUrl)&&(identical(other.publicContactEmail, publicContactEmail) || other.publicContactEmail == publicContactEmail)&&const DeepCollectionEquality().equals(other._faqItems, _faqItems)&&(identical(other.publicationStatus, publicationStatus) || other.publicationStatus == publicationStatus)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,sessionLabel,startAt,endAt,dailyHours,venue,locationDetails,mapUrl,description,const DeepCollectionEquality().hash(_objectives),status,heroImageUrl,posterUrl,publicContactEmail,const DeepCollectionEquality().hash(_faqItems),publicationStatus,updatedAt,publishedAt]);

@override
String toString() {
  return 'Event(id: $id, title: $title, sessionLabel: $sessionLabel, startAt: $startAt, endAt: $endAt, dailyHours: $dailyHours, venue: $venue, locationDetails: $locationDetails, mapUrl: $mapUrl, description: $description, objectives: $objectives, status: $status, heroImageUrl: $heroImageUrl, posterUrl: $posterUrl, publicContactEmail: $publicContactEmail, faqItems: $faqItems, publicationStatus: $publicationStatus, updatedAt: $updatedAt, publishedAt: $publishedAt)';
}


}

/// @nodoc
abstract mixin class _$EventCopyWith<$Res> implements $EventCopyWith<$Res> {
  factory _$EventCopyWith(_Event value, $Res Function(_Event) _then) = __$EventCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String sessionLabel, DateTime startAt, DateTime endAt, String dailyHours, String venue, String locationDetails, String? mapUrl, String description, List<String> objectives, String status, String heroImageUrl, String posterUrl, String publicContactEmail, List<FaqItem> faqItems, String publicationStatus, DateTime updatedAt, DateTime? publishedAt
});




}
/// @nodoc
class __$EventCopyWithImpl<$Res>
    implements _$EventCopyWith<$Res> {
  __$EventCopyWithImpl(this._self, this._then);

  final _Event _self;
  final $Res Function(_Event) _then;

/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? sessionLabel = null,Object? startAt = null,Object? endAt = null,Object? dailyHours = null,Object? venue = null,Object? locationDetails = null,Object? mapUrl = freezed,Object? description = null,Object? objectives = null,Object? status = null,Object? heroImageUrl = null,Object? posterUrl = null,Object? publicContactEmail = null,Object? faqItems = null,Object? publicationStatus = null,Object? updatedAt = null,Object? publishedAt = freezed,}) {
  return _then(_Event(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,sessionLabel: null == sessionLabel ? _self.sessionLabel : sessionLabel // ignore: cast_nullable_to_non_nullable
as String,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime,dailyHours: null == dailyHours ? _self.dailyHours : dailyHours // ignore: cast_nullable_to_non_nullable
as String,venue: null == venue ? _self.venue : venue // ignore: cast_nullable_to_non_nullable
as String,locationDetails: null == locationDetails ? _self.locationDetails : locationDetails // ignore: cast_nullable_to_non_nullable
as String,mapUrl: freezed == mapUrl ? _self.mapUrl : mapUrl // ignore: cast_nullable_to_non_nullable
as String?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,objectives: null == objectives ? _self._objectives : objectives // ignore: cast_nullable_to_non_nullable
as List<String>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,heroImageUrl: null == heroImageUrl ? _self.heroImageUrl : heroImageUrl // ignore: cast_nullable_to_non_nullable
as String,posterUrl: null == posterUrl ? _self.posterUrl : posterUrl // ignore: cast_nullable_to_non_nullable
as String,publicContactEmail: null == publicContactEmail ? _self.publicContactEmail : publicContactEmail // ignore: cast_nullable_to_non_nullable
as String,faqItems: null == faqItems ? _self._faqItems : faqItems // ignore: cast_nullable_to_non_nullable
as List<FaqItem>,publicationStatus: null == publicationStatus ? _self.publicationStatus : publicationStatus // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
