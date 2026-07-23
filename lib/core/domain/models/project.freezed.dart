// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'project.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Project {

 String get id; String get eventId; String get slug; String get title; String? get matricId; String get programmeCode; String get programmeName; String get shortDescription; String get category; List<String> get technologyTags; String? get boothId; String? get boothNumber; String? get boothZone; String get coverImageUrl; String? get posterUrl; List<String> get teamDisplayNames; String get supervisorDisplayName; String? get examinerDisplayName; String? get demoUrl; String? get videoUrl; String? get repositoryUrl; bool get featured; String get publicationStatus; DateTime get createdAt; DateTime get updatedAt; DateTime? get publishedAt;
/// Create a copy of Project
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectCopyWith<Project> get copyWith => _$ProjectCopyWithImpl<Project>(this as Project, _$identity);

  /// Serializes this Project to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Project&&(identical(other.id, id) || other.id == id)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.title, title) || other.title == title)&&(identical(other.matricId, matricId) || other.matricId == matricId)&&(identical(other.programmeCode, programmeCode) || other.programmeCode == programmeCode)&&(identical(other.programmeName, programmeName) || other.programmeName == programmeName)&&(identical(other.shortDescription, shortDescription) || other.shortDescription == shortDescription)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other.technologyTags, technologyTags)&&(identical(other.boothId, boothId) || other.boothId == boothId)&&(identical(other.boothNumber, boothNumber) || other.boothNumber == boothNumber)&&(identical(other.boothZone, boothZone) || other.boothZone == boothZone)&&(identical(other.coverImageUrl, coverImageUrl) || other.coverImageUrl == coverImageUrl)&&(identical(other.posterUrl, posterUrl) || other.posterUrl == posterUrl)&&const DeepCollectionEquality().equals(other.teamDisplayNames, teamDisplayNames)&&(identical(other.supervisorDisplayName, supervisorDisplayName) || other.supervisorDisplayName == supervisorDisplayName)&&(identical(other.examinerDisplayName, examinerDisplayName) || other.examinerDisplayName == examinerDisplayName)&&(identical(other.demoUrl, demoUrl) || other.demoUrl == demoUrl)&&(identical(other.videoUrl, videoUrl) || other.videoUrl == videoUrl)&&(identical(other.repositoryUrl, repositoryUrl) || other.repositoryUrl == repositoryUrl)&&(identical(other.featured, featured) || other.featured == featured)&&(identical(other.publicationStatus, publicationStatus) || other.publicationStatus == publicationStatus)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,eventId,slug,title,matricId,programmeCode,programmeName,shortDescription,category,const DeepCollectionEquality().hash(technologyTags),boothId,boothNumber,boothZone,coverImageUrl,posterUrl,const DeepCollectionEquality().hash(teamDisplayNames),supervisorDisplayName,examinerDisplayName,demoUrl,videoUrl,repositoryUrl,featured,publicationStatus,createdAt,updatedAt,publishedAt]);

@override
String toString() {
  return 'Project(id: $id, eventId: $eventId, slug: $slug, title: $title, matricId: $matricId, programmeCode: $programmeCode, programmeName: $programmeName, shortDescription: $shortDescription, category: $category, technologyTags: $technologyTags, boothId: $boothId, boothNumber: $boothNumber, boothZone: $boothZone, coverImageUrl: $coverImageUrl, posterUrl: $posterUrl, teamDisplayNames: $teamDisplayNames, supervisorDisplayName: $supervisorDisplayName, examinerDisplayName: $examinerDisplayName, demoUrl: $demoUrl, videoUrl: $videoUrl, repositoryUrl: $repositoryUrl, featured: $featured, publicationStatus: $publicationStatus, createdAt: $createdAt, updatedAt: $updatedAt, publishedAt: $publishedAt)';
}


}

/// @nodoc
abstract mixin class $ProjectCopyWith<$Res>  {
  factory $ProjectCopyWith(Project value, $Res Function(Project) _then) = _$ProjectCopyWithImpl;
@useResult
$Res call({
 String id, String eventId, String slug, String title, String? matricId, String programmeCode, String programmeName, String shortDescription, String category, List<String> technologyTags, String? boothId, String? boothNumber, String? boothZone, String coverImageUrl, String? posterUrl, List<String> teamDisplayNames, String supervisorDisplayName, String? examinerDisplayName, String? demoUrl, String? videoUrl, String? repositoryUrl, bool featured, String publicationStatus, DateTime createdAt, DateTime updatedAt, DateTime? publishedAt
});




}
/// @nodoc
class _$ProjectCopyWithImpl<$Res>
    implements $ProjectCopyWith<$Res> {
  _$ProjectCopyWithImpl(this._self, this._then);

  final Project _self;
  final $Res Function(Project) _then;

/// Create a copy of Project
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? eventId = null,Object? slug = null,Object? title = null,Object? matricId = freezed,Object? programmeCode = null,Object? programmeName = null,Object? shortDescription = null,Object? category = null,Object? technologyTags = null,Object? boothId = freezed,Object? boothNumber = freezed,Object? boothZone = freezed,Object? coverImageUrl = null,Object? posterUrl = freezed,Object? teamDisplayNames = null,Object? supervisorDisplayName = null,Object? examinerDisplayName = freezed,Object? demoUrl = freezed,Object? videoUrl = freezed,Object? repositoryUrl = freezed,Object? featured = null,Object? publicationStatus = null,Object? createdAt = null,Object? updatedAt = null,Object? publishedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,matricId: freezed == matricId ? _self.matricId : matricId // ignore: cast_nullable_to_non_nullable
as String?,programmeCode: null == programmeCode ? _self.programmeCode : programmeCode // ignore: cast_nullable_to_non_nullable
as String,programmeName: null == programmeName ? _self.programmeName : programmeName // ignore: cast_nullable_to_non_nullable
as String,shortDescription: null == shortDescription ? _self.shortDescription : shortDescription // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,technologyTags: null == technologyTags ? _self.technologyTags : technologyTags // ignore: cast_nullable_to_non_nullable
as List<String>,boothId: freezed == boothId ? _self.boothId : boothId // ignore: cast_nullable_to_non_nullable
as String?,boothNumber: freezed == boothNumber ? _self.boothNumber : boothNumber // ignore: cast_nullable_to_non_nullable
as String?,boothZone: freezed == boothZone ? _self.boothZone : boothZone // ignore: cast_nullable_to_non_nullable
as String?,coverImageUrl: null == coverImageUrl ? _self.coverImageUrl : coverImageUrl // ignore: cast_nullable_to_non_nullable
as String,posterUrl: freezed == posterUrl ? _self.posterUrl : posterUrl // ignore: cast_nullable_to_non_nullable
as String?,teamDisplayNames: null == teamDisplayNames ? _self.teamDisplayNames : teamDisplayNames // ignore: cast_nullable_to_non_nullable
as List<String>,supervisorDisplayName: null == supervisorDisplayName ? _self.supervisorDisplayName : supervisorDisplayName // ignore: cast_nullable_to_non_nullable
as String,examinerDisplayName: freezed == examinerDisplayName ? _self.examinerDisplayName : examinerDisplayName // ignore: cast_nullable_to_non_nullable
as String?,demoUrl: freezed == demoUrl ? _self.demoUrl : demoUrl // ignore: cast_nullable_to_non_nullable
as String?,videoUrl: freezed == videoUrl ? _self.videoUrl : videoUrl // ignore: cast_nullable_to_non_nullable
as String?,repositoryUrl: freezed == repositoryUrl ? _self.repositoryUrl : repositoryUrl // ignore: cast_nullable_to_non_nullable
as String?,featured: null == featured ? _self.featured : featured // ignore: cast_nullable_to_non_nullable
as bool,publicationStatus: null == publicationStatus ? _self.publicationStatus : publicationStatus // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Project].
extension ProjectPatterns on Project {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Project value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Project() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Project value)  $default,){
final _that = this;
switch (_that) {
case _Project():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Project value)?  $default,){
final _that = this;
switch (_that) {
case _Project() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String eventId,  String slug,  String title,  String? matricId,  String programmeCode,  String programmeName,  String shortDescription,  String category,  List<String> technologyTags,  String? boothId,  String? boothNumber,  String? boothZone,  String coverImageUrl,  String? posterUrl,  List<String> teamDisplayNames,  String supervisorDisplayName,  String? examinerDisplayName,  String? demoUrl,  String? videoUrl,  String? repositoryUrl,  bool featured,  String publicationStatus,  DateTime createdAt,  DateTime updatedAt,  DateTime? publishedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Project() when $default != null:
return $default(_that.id,_that.eventId,_that.slug,_that.title,_that.matricId,_that.programmeCode,_that.programmeName,_that.shortDescription,_that.category,_that.technologyTags,_that.boothId,_that.boothNumber,_that.boothZone,_that.coverImageUrl,_that.posterUrl,_that.teamDisplayNames,_that.supervisorDisplayName,_that.examinerDisplayName,_that.demoUrl,_that.videoUrl,_that.repositoryUrl,_that.featured,_that.publicationStatus,_that.createdAt,_that.updatedAt,_that.publishedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String eventId,  String slug,  String title,  String? matricId,  String programmeCode,  String programmeName,  String shortDescription,  String category,  List<String> technologyTags,  String? boothId,  String? boothNumber,  String? boothZone,  String coverImageUrl,  String? posterUrl,  List<String> teamDisplayNames,  String supervisorDisplayName,  String? examinerDisplayName,  String? demoUrl,  String? videoUrl,  String? repositoryUrl,  bool featured,  String publicationStatus,  DateTime createdAt,  DateTime updatedAt,  DateTime? publishedAt)  $default,) {final _that = this;
switch (_that) {
case _Project():
return $default(_that.id,_that.eventId,_that.slug,_that.title,_that.matricId,_that.programmeCode,_that.programmeName,_that.shortDescription,_that.category,_that.technologyTags,_that.boothId,_that.boothNumber,_that.boothZone,_that.coverImageUrl,_that.posterUrl,_that.teamDisplayNames,_that.supervisorDisplayName,_that.examinerDisplayName,_that.demoUrl,_that.videoUrl,_that.repositoryUrl,_that.featured,_that.publicationStatus,_that.createdAt,_that.updatedAt,_that.publishedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String eventId,  String slug,  String title,  String? matricId,  String programmeCode,  String programmeName,  String shortDescription,  String category,  List<String> technologyTags,  String? boothId,  String? boothNumber,  String? boothZone,  String coverImageUrl,  String? posterUrl,  List<String> teamDisplayNames,  String supervisorDisplayName,  String? examinerDisplayName,  String? demoUrl,  String? videoUrl,  String? repositoryUrl,  bool featured,  String publicationStatus,  DateTime createdAt,  DateTime updatedAt,  DateTime? publishedAt)?  $default,) {final _that = this;
switch (_that) {
case _Project() when $default != null:
return $default(_that.id,_that.eventId,_that.slug,_that.title,_that.matricId,_that.programmeCode,_that.programmeName,_that.shortDescription,_that.category,_that.technologyTags,_that.boothId,_that.boothNumber,_that.boothZone,_that.coverImageUrl,_that.posterUrl,_that.teamDisplayNames,_that.supervisorDisplayName,_that.examinerDisplayName,_that.demoUrl,_that.videoUrl,_that.repositoryUrl,_that.featured,_that.publicationStatus,_that.createdAt,_that.updatedAt,_that.publishedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Project implements Project {
  const _Project({required this.id, required this.eventId, required this.slug, required this.title, this.matricId, required this.programmeCode, required this.programmeName, required this.shortDescription, required this.category, required final  List<String> technologyTags, this.boothId, this.boothNumber, this.boothZone, required this.coverImageUrl, this.posterUrl, required final  List<String> teamDisplayNames, required this.supervisorDisplayName, this.examinerDisplayName, this.demoUrl, this.videoUrl, this.repositoryUrl, required this.featured, required this.publicationStatus, required this.createdAt, required this.updatedAt, this.publishedAt}): _technologyTags = technologyTags,_teamDisplayNames = teamDisplayNames;
  factory _Project.fromJson(Map<String, dynamic> json) => _$ProjectFromJson(json);

@override final  String id;
@override final  String eventId;
@override final  String slug;
@override final  String title;
@override final  String? matricId;
@override final  String programmeCode;
@override final  String programmeName;
@override final  String shortDescription;
@override final  String category;
 final  List<String> _technologyTags;
@override List<String> get technologyTags {
  if (_technologyTags is EqualUnmodifiableListView) return _technologyTags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_technologyTags);
}

@override final  String? boothId;
@override final  String? boothNumber;
@override final  String? boothZone;
@override final  String coverImageUrl;
@override final  String? posterUrl;
 final  List<String> _teamDisplayNames;
@override List<String> get teamDisplayNames {
  if (_teamDisplayNames is EqualUnmodifiableListView) return _teamDisplayNames;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_teamDisplayNames);
}

@override final  String supervisorDisplayName;
@override final  String? examinerDisplayName;
@override final  String? demoUrl;
@override final  String? videoUrl;
@override final  String? repositoryUrl;
@override final  bool featured;
@override final  String publicationStatus;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? publishedAt;

/// Create a copy of Project
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProjectCopyWith<_Project> get copyWith => __$ProjectCopyWithImpl<_Project>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProjectToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Project&&(identical(other.id, id) || other.id == id)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.title, title) || other.title == title)&&(identical(other.matricId, matricId) || other.matricId == matricId)&&(identical(other.programmeCode, programmeCode) || other.programmeCode == programmeCode)&&(identical(other.programmeName, programmeName) || other.programmeName == programmeName)&&(identical(other.shortDescription, shortDescription) || other.shortDescription == shortDescription)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other._technologyTags, _technologyTags)&&(identical(other.boothId, boothId) || other.boothId == boothId)&&(identical(other.boothNumber, boothNumber) || other.boothNumber == boothNumber)&&(identical(other.boothZone, boothZone) || other.boothZone == boothZone)&&(identical(other.coverImageUrl, coverImageUrl) || other.coverImageUrl == coverImageUrl)&&(identical(other.posterUrl, posterUrl) || other.posterUrl == posterUrl)&&const DeepCollectionEquality().equals(other._teamDisplayNames, _teamDisplayNames)&&(identical(other.supervisorDisplayName, supervisorDisplayName) || other.supervisorDisplayName == supervisorDisplayName)&&(identical(other.examinerDisplayName, examinerDisplayName) || other.examinerDisplayName == examinerDisplayName)&&(identical(other.demoUrl, demoUrl) || other.demoUrl == demoUrl)&&(identical(other.videoUrl, videoUrl) || other.videoUrl == videoUrl)&&(identical(other.repositoryUrl, repositoryUrl) || other.repositoryUrl == repositoryUrl)&&(identical(other.featured, featured) || other.featured == featured)&&(identical(other.publicationStatus, publicationStatus) || other.publicationStatus == publicationStatus)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,eventId,slug,title,matricId,programmeCode,programmeName,shortDescription,category,const DeepCollectionEquality().hash(_technologyTags),boothId,boothNumber,boothZone,coverImageUrl,posterUrl,const DeepCollectionEquality().hash(_teamDisplayNames),supervisorDisplayName,examinerDisplayName,demoUrl,videoUrl,repositoryUrl,featured,publicationStatus,createdAt,updatedAt,publishedAt]);

@override
String toString() {
  return 'Project(id: $id, eventId: $eventId, slug: $slug, title: $title, matricId: $matricId, programmeCode: $programmeCode, programmeName: $programmeName, shortDescription: $shortDescription, category: $category, technologyTags: $technologyTags, boothId: $boothId, boothNumber: $boothNumber, boothZone: $boothZone, coverImageUrl: $coverImageUrl, posterUrl: $posterUrl, teamDisplayNames: $teamDisplayNames, supervisorDisplayName: $supervisorDisplayName, examinerDisplayName: $examinerDisplayName, demoUrl: $demoUrl, videoUrl: $videoUrl, repositoryUrl: $repositoryUrl, featured: $featured, publicationStatus: $publicationStatus, createdAt: $createdAt, updatedAt: $updatedAt, publishedAt: $publishedAt)';
}


}

/// @nodoc
abstract mixin class _$ProjectCopyWith<$Res> implements $ProjectCopyWith<$Res> {
  factory _$ProjectCopyWith(_Project value, $Res Function(_Project) _then) = __$ProjectCopyWithImpl;
@override @useResult
$Res call({
 String id, String eventId, String slug, String title, String? matricId, String programmeCode, String programmeName, String shortDescription, String category, List<String> technologyTags, String? boothId, String? boothNumber, String? boothZone, String coverImageUrl, String? posterUrl, List<String> teamDisplayNames, String supervisorDisplayName, String? examinerDisplayName, String? demoUrl, String? videoUrl, String? repositoryUrl, bool featured, String publicationStatus, DateTime createdAt, DateTime updatedAt, DateTime? publishedAt
});




}
/// @nodoc
class __$ProjectCopyWithImpl<$Res>
    implements _$ProjectCopyWith<$Res> {
  __$ProjectCopyWithImpl(this._self, this._then);

  final _Project _self;
  final $Res Function(_Project) _then;

/// Create a copy of Project
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? eventId = null,Object? slug = null,Object? title = null,Object? matricId = freezed,Object? programmeCode = null,Object? programmeName = null,Object? shortDescription = null,Object? category = null,Object? technologyTags = null,Object? boothId = freezed,Object? boothNumber = freezed,Object? boothZone = freezed,Object? coverImageUrl = null,Object? posterUrl = freezed,Object? teamDisplayNames = null,Object? supervisorDisplayName = null,Object? examinerDisplayName = freezed,Object? demoUrl = freezed,Object? videoUrl = freezed,Object? repositoryUrl = freezed,Object? featured = null,Object? publicationStatus = null,Object? createdAt = null,Object? updatedAt = null,Object? publishedAt = freezed,}) {
  return _then(_Project(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,matricId: freezed == matricId ? _self.matricId : matricId // ignore: cast_nullable_to_non_nullable
as String?,programmeCode: null == programmeCode ? _self.programmeCode : programmeCode // ignore: cast_nullable_to_non_nullable
as String,programmeName: null == programmeName ? _self.programmeName : programmeName // ignore: cast_nullable_to_non_nullable
as String,shortDescription: null == shortDescription ? _self.shortDescription : shortDescription // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,technologyTags: null == technologyTags ? _self._technologyTags : technologyTags // ignore: cast_nullable_to_non_nullable
as List<String>,boothId: freezed == boothId ? _self.boothId : boothId // ignore: cast_nullable_to_non_nullable
as String?,boothNumber: freezed == boothNumber ? _self.boothNumber : boothNumber // ignore: cast_nullable_to_non_nullable
as String?,boothZone: freezed == boothZone ? _self.boothZone : boothZone // ignore: cast_nullable_to_non_nullable
as String?,coverImageUrl: null == coverImageUrl ? _self.coverImageUrl : coverImageUrl // ignore: cast_nullable_to_non_nullable
as String,posterUrl: freezed == posterUrl ? _self.posterUrl : posterUrl // ignore: cast_nullable_to_non_nullable
as String?,teamDisplayNames: null == teamDisplayNames ? _self._teamDisplayNames : teamDisplayNames // ignore: cast_nullable_to_non_nullable
as List<String>,supervisorDisplayName: null == supervisorDisplayName ? _self.supervisorDisplayName : supervisorDisplayName // ignore: cast_nullable_to_non_nullable
as String,examinerDisplayName: freezed == examinerDisplayName ? _self.examinerDisplayName : examinerDisplayName // ignore: cast_nullable_to_non_nullable
as String?,demoUrl: freezed == demoUrl ? _self.demoUrl : demoUrl // ignore: cast_nullable_to_non_nullable
as String?,videoUrl: freezed == videoUrl ? _self.videoUrl : videoUrl // ignore: cast_nullable_to_non_nullable
as String?,repositoryUrl: freezed == repositoryUrl ? _self.repositoryUrl : repositoryUrl // ignore: cast_nullable_to_non_nullable
as String?,featured: null == featured ? _self.featured : featured // ignore: cast_nullable_to_non_nullable
as bool,publicationStatus: null == publicationStatus ? _self.publicationStatus : publicationStatus // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
