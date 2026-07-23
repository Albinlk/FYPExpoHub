// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'award.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AwardCategory {

 String get id; String get eventId; String get name; String get description; String get publicationStatus; DateTime get createdAt; DateTime get updatedAt; DateTime? get publishedAt;
/// Create a copy of AwardCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AwardCategoryCopyWith<AwardCategory> get copyWith => _$AwardCategoryCopyWithImpl<AwardCategory>(this as AwardCategory, _$identity);

  /// Serializes this AwardCategory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AwardCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.publicationStatus, publicationStatus) || other.publicationStatus == publicationStatus)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,eventId,name,description,publicationStatus,createdAt,updatedAt,publishedAt);

@override
String toString() {
  return 'AwardCategory(id: $id, eventId: $eventId, name: $name, description: $description, publicationStatus: $publicationStatus, createdAt: $createdAt, updatedAt: $updatedAt, publishedAt: $publishedAt)';
}


}

/// @nodoc
abstract mixin class $AwardCategoryCopyWith<$Res>  {
  factory $AwardCategoryCopyWith(AwardCategory value, $Res Function(AwardCategory) _then) = _$AwardCategoryCopyWithImpl;
@useResult
$Res call({
 String id, String eventId, String name, String description, String publicationStatus, DateTime createdAt, DateTime updatedAt, DateTime? publishedAt
});




}
/// @nodoc
class _$AwardCategoryCopyWithImpl<$Res>
    implements $AwardCategoryCopyWith<$Res> {
  _$AwardCategoryCopyWithImpl(this._self, this._then);

  final AwardCategory _self;
  final $Res Function(AwardCategory) _then;

/// Create a copy of AwardCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? eventId = null,Object? name = null,Object? description = null,Object? publicationStatus = null,Object? createdAt = null,Object? updatedAt = null,Object? publishedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,publicationStatus: null == publicationStatus ? _self.publicationStatus : publicationStatus // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [AwardCategory].
extension AwardCategoryPatterns on AwardCategory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AwardCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AwardCategory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AwardCategory value)  $default,){
final _that = this;
switch (_that) {
case _AwardCategory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AwardCategory value)?  $default,){
final _that = this;
switch (_that) {
case _AwardCategory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String eventId,  String name,  String description,  String publicationStatus,  DateTime createdAt,  DateTime updatedAt,  DateTime? publishedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AwardCategory() when $default != null:
return $default(_that.id,_that.eventId,_that.name,_that.description,_that.publicationStatus,_that.createdAt,_that.updatedAt,_that.publishedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String eventId,  String name,  String description,  String publicationStatus,  DateTime createdAt,  DateTime updatedAt,  DateTime? publishedAt)  $default,) {final _that = this;
switch (_that) {
case _AwardCategory():
return $default(_that.id,_that.eventId,_that.name,_that.description,_that.publicationStatus,_that.createdAt,_that.updatedAt,_that.publishedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String eventId,  String name,  String description,  String publicationStatus,  DateTime createdAt,  DateTime updatedAt,  DateTime? publishedAt)?  $default,) {final _that = this;
switch (_that) {
case _AwardCategory() when $default != null:
return $default(_that.id,_that.eventId,_that.name,_that.description,_that.publicationStatus,_that.createdAt,_that.updatedAt,_that.publishedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AwardCategory implements AwardCategory {
  const _AwardCategory({required this.id, required this.eventId, required this.name, required this.description, required this.publicationStatus, required this.createdAt, required this.updatedAt, this.publishedAt});
  factory _AwardCategory.fromJson(Map<String, dynamic> json) => _$AwardCategoryFromJson(json);

@override final  String id;
@override final  String eventId;
@override final  String name;
@override final  String description;
@override final  String publicationStatus;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? publishedAt;

/// Create a copy of AwardCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AwardCategoryCopyWith<_AwardCategory> get copyWith => __$AwardCategoryCopyWithImpl<_AwardCategory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AwardCategoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AwardCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.publicationStatus, publicationStatus) || other.publicationStatus == publicationStatus)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,eventId,name,description,publicationStatus,createdAt,updatedAt,publishedAt);

@override
String toString() {
  return 'AwardCategory(id: $id, eventId: $eventId, name: $name, description: $description, publicationStatus: $publicationStatus, createdAt: $createdAt, updatedAt: $updatedAt, publishedAt: $publishedAt)';
}


}

/// @nodoc
abstract mixin class _$AwardCategoryCopyWith<$Res> implements $AwardCategoryCopyWith<$Res> {
  factory _$AwardCategoryCopyWith(_AwardCategory value, $Res Function(_AwardCategory) _then) = __$AwardCategoryCopyWithImpl;
@override @useResult
$Res call({
 String id, String eventId, String name, String description, String publicationStatus, DateTime createdAt, DateTime updatedAt, DateTime? publishedAt
});




}
/// @nodoc
class __$AwardCategoryCopyWithImpl<$Res>
    implements _$AwardCategoryCopyWith<$Res> {
  __$AwardCategoryCopyWithImpl(this._self, this._then);

  final _AwardCategory _self;
  final $Res Function(_AwardCategory) _then;

/// Create a copy of AwardCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? eventId = null,Object? name = null,Object? description = null,Object? publicationStatus = null,Object? createdAt = null,Object? updatedAt = null,Object? publishedAt = freezed,}) {
  return _then(_AwardCategory(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,publicationStatus: null == publicationStatus ? _self.publicationStatus : publicationStatus // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$PublishedAwardWinner {

 String get id; String get eventId; String get awardCategoryId; String? get projectId; String get projectTitle; String? get programmeCode; String? get teamDisplayName; String? get supervisorDisplayName; String get publicationStatus; String? get sourceImportId; DateTime get createdAt; DateTime get updatedAt; DateTime? get publishedAt;
/// Create a copy of PublishedAwardWinner
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PublishedAwardWinnerCopyWith<PublishedAwardWinner> get copyWith => _$PublishedAwardWinnerCopyWithImpl<PublishedAwardWinner>(this as PublishedAwardWinner, _$identity);

  /// Serializes this PublishedAwardWinner to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PublishedAwardWinner&&(identical(other.id, id) || other.id == id)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.awardCategoryId, awardCategoryId) || other.awardCategoryId == awardCategoryId)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.projectTitle, projectTitle) || other.projectTitle == projectTitle)&&(identical(other.programmeCode, programmeCode) || other.programmeCode == programmeCode)&&(identical(other.teamDisplayName, teamDisplayName) || other.teamDisplayName == teamDisplayName)&&(identical(other.supervisorDisplayName, supervisorDisplayName) || other.supervisorDisplayName == supervisorDisplayName)&&(identical(other.publicationStatus, publicationStatus) || other.publicationStatus == publicationStatus)&&(identical(other.sourceImportId, sourceImportId) || other.sourceImportId == sourceImportId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,eventId,awardCategoryId,projectId,projectTitle,programmeCode,teamDisplayName,supervisorDisplayName,publicationStatus,sourceImportId,createdAt,updatedAt,publishedAt);

@override
String toString() {
  return 'PublishedAwardWinner(id: $id, eventId: $eventId, awardCategoryId: $awardCategoryId, projectId: $projectId, projectTitle: $projectTitle, programmeCode: $programmeCode, teamDisplayName: $teamDisplayName, supervisorDisplayName: $supervisorDisplayName, publicationStatus: $publicationStatus, sourceImportId: $sourceImportId, createdAt: $createdAt, updatedAt: $updatedAt, publishedAt: $publishedAt)';
}


}

/// @nodoc
abstract mixin class $PublishedAwardWinnerCopyWith<$Res>  {
  factory $PublishedAwardWinnerCopyWith(PublishedAwardWinner value, $Res Function(PublishedAwardWinner) _then) = _$PublishedAwardWinnerCopyWithImpl;
@useResult
$Res call({
 String id, String eventId, String awardCategoryId, String? projectId, String projectTitle, String? programmeCode, String? teamDisplayName, String? supervisorDisplayName, String publicationStatus, String? sourceImportId, DateTime createdAt, DateTime updatedAt, DateTime? publishedAt
});




}
/// @nodoc
class _$PublishedAwardWinnerCopyWithImpl<$Res>
    implements $PublishedAwardWinnerCopyWith<$Res> {
  _$PublishedAwardWinnerCopyWithImpl(this._self, this._then);

  final PublishedAwardWinner _self;
  final $Res Function(PublishedAwardWinner) _then;

/// Create a copy of PublishedAwardWinner
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? eventId = null,Object? awardCategoryId = null,Object? projectId = freezed,Object? projectTitle = null,Object? programmeCode = freezed,Object? teamDisplayName = freezed,Object? supervisorDisplayName = freezed,Object? publicationStatus = null,Object? sourceImportId = freezed,Object? createdAt = null,Object? updatedAt = null,Object? publishedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,awardCategoryId: null == awardCategoryId ? _self.awardCategoryId : awardCategoryId // ignore: cast_nullable_to_non_nullable
as String,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,projectTitle: null == projectTitle ? _self.projectTitle : projectTitle // ignore: cast_nullable_to_non_nullable
as String,programmeCode: freezed == programmeCode ? _self.programmeCode : programmeCode // ignore: cast_nullable_to_non_nullable
as String?,teamDisplayName: freezed == teamDisplayName ? _self.teamDisplayName : teamDisplayName // ignore: cast_nullable_to_non_nullable
as String?,supervisorDisplayName: freezed == supervisorDisplayName ? _self.supervisorDisplayName : supervisorDisplayName // ignore: cast_nullable_to_non_nullable
as String?,publicationStatus: null == publicationStatus ? _self.publicationStatus : publicationStatus // ignore: cast_nullable_to_non_nullable
as String,sourceImportId: freezed == sourceImportId ? _self.sourceImportId : sourceImportId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [PublishedAwardWinner].
extension PublishedAwardWinnerPatterns on PublishedAwardWinner {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PublishedAwardWinner value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PublishedAwardWinner() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PublishedAwardWinner value)  $default,){
final _that = this;
switch (_that) {
case _PublishedAwardWinner():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PublishedAwardWinner value)?  $default,){
final _that = this;
switch (_that) {
case _PublishedAwardWinner() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String eventId,  String awardCategoryId,  String? projectId,  String projectTitle,  String? programmeCode,  String? teamDisplayName,  String? supervisorDisplayName,  String publicationStatus,  String? sourceImportId,  DateTime createdAt,  DateTime updatedAt,  DateTime? publishedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PublishedAwardWinner() when $default != null:
return $default(_that.id,_that.eventId,_that.awardCategoryId,_that.projectId,_that.projectTitle,_that.programmeCode,_that.teamDisplayName,_that.supervisorDisplayName,_that.publicationStatus,_that.sourceImportId,_that.createdAt,_that.updatedAt,_that.publishedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String eventId,  String awardCategoryId,  String? projectId,  String projectTitle,  String? programmeCode,  String? teamDisplayName,  String? supervisorDisplayName,  String publicationStatus,  String? sourceImportId,  DateTime createdAt,  DateTime updatedAt,  DateTime? publishedAt)  $default,) {final _that = this;
switch (_that) {
case _PublishedAwardWinner():
return $default(_that.id,_that.eventId,_that.awardCategoryId,_that.projectId,_that.projectTitle,_that.programmeCode,_that.teamDisplayName,_that.supervisorDisplayName,_that.publicationStatus,_that.sourceImportId,_that.createdAt,_that.updatedAt,_that.publishedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String eventId,  String awardCategoryId,  String? projectId,  String projectTitle,  String? programmeCode,  String? teamDisplayName,  String? supervisorDisplayName,  String publicationStatus,  String? sourceImportId,  DateTime createdAt,  DateTime updatedAt,  DateTime? publishedAt)?  $default,) {final _that = this;
switch (_that) {
case _PublishedAwardWinner() when $default != null:
return $default(_that.id,_that.eventId,_that.awardCategoryId,_that.projectId,_that.projectTitle,_that.programmeCode,_that.teamDisplayName,_that.supervisorDisplayName,_that.publicationStatus,_that.sourceImportId,_that.createdAt,_that.updatedAt,_that.publishedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PublishedAwardWinner implements PublishedAwardWinner {
  const _PublishedAwardWinner({required this.id, required this.eventId, required this.awardCategoryId, this.projectId, required this.projectTitle, this.programmeCode, this.teamDisplayName, this.supervisorDisplayName, required this.publicationStatus, this.sourceImportId, required this.createdAt, required this.updatedAt, this.publishedAt});
  factory _PublishedAwardWinner.fromJson(Map<String, dynamic> json) => _$PublishedAwardWinnerFromJson(json);

@override final  String id;
@override final  String eventId;
@override final  String awardCategoryId;
@override final  String? projectId;
@override final  String projectTitle;
@override final  String? programmeCode;
@override final  String? teamDisplayName;
@override final  String? supervisorDisplayName;
@override final  String publicationStatus;
@override final  String? sourceImportId;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? publishedAt;

/// Create a copy of PublishedAwardWinner
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PublishedAwardWinnerCopyWith<_PublishedAwardWinner> get copyWith => __$PublishedAwardWinnerCopyWithImpl<_PublishedAwardWinner>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PublishedAwardWinnerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PublishedAwardWinner&&(identical(other.id, id) || other.id == id)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.awardCategoryId, awardCategoryId) || other.awardCategoryId == awardCategoryId)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.projectTitle, projectTitle) || other.projectTitle == projectTitle)&&(identical(other.programmeCode, programmeCode) || other.programmeCode == programmeCode)&&(identical(other.teamDisplayName, teamDisplayName) || other.teamDisplayName == teamDisplayName)&&(identical(other.supervisorDisplayName, supervisorDisplayName) || other.supervisorDisplayName == supervisorDisplayName)&&(identical(other.publicationStatus, publicationStatus) || other.publicationStatus == publicationStatus)&&(identical(other.sourceImportId, sourceImportId) || other.sourceImportId == sourceImportId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,eventId,awardCategoryId,projectId,projectTitle,programmeCode,teamDisplayName,supervisorDisplayName,publicationStatus,sourceImportId,createdAt,updatedAt,publishedAt);

@override
String toString() {
  return 'PublishedAwardWinner(id: $id, eventId: $eventId, awardCategoryId: $awardCategoryId, projectId: $projectId, projectTitle: $projectTitle, programmeCode: $programmeCode, teamDisplayName: $teamDisplayName, supervisorDisplayName: $supervisorDisplayName, publicationStatus: $publicationStatus, sourceImportId: $sourceImportId, createdAt: $createdAt, updatedAt: $updatedAt, publishedAt: $publishedAt)';
}


}

/// @nodoc
abstract mixin class _$PublishedAwardWinnerCopyWith<$Res> implements $PublishedAwardWinnerCopyWith<$Res> {
  factory _$PublishedAwardWinnerCopyWith(_PublishedAwardWinner value, $Res Function(_PublishedAwardWinner) _then) = __$PublishedAwardWinnerCopyWithImpl;
@override @useResult
$Res call({
 String id, String eventId, String awardCategoryId, String? projectId, String projectTitle, String? programmeCode, String? teamDisplayName, String? supervisorDisplayName, String publicationStatus, String? sourceImportId, DateTime createdAt, DateTime updatedAt, DateTime? publishedAt
});




}
/// @nodoc
class __$PublishedAwardWinnerCopyWithImpl<$Res>
    implements _$PublishedAwardWinnerCopyWith<$Res> {
  __$PublishedAwardWinnerCopyWithImpl(this._self, this._then);

  final _PublishedAwardWinner _self;
  final $Res Function(_PublishedAwardWinner) _then;

/// Create a copy of PublishedAwardWinner
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? eventId = null,Object? awardCategoryId = null,Object? projectId = freezed,Object? projectTitle = null,Object? programmeCode = freezed,Object? teamDisplayName = freezed,Object? supervisorDisplayName = freezed,Object? publicationStatus = null,Object? sourceImportId = freezed,Object? createdAt = null,Object? updatedAt = null,Object? publishedAt = freezed,}) {
  return _then(_PublishedAwardWinner(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,awardCategoryId: null == awardCategoryId ? _self.awardCategoryId : awardCategoryId // ignore: cast_nullable_to_non_nullable
as String,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,projectTitle: null == projectTitle ? _self.projectTitle : projectTitle // ignore: cast_nullable_to_non_nullable
as String,programmeCode: freezed == programmeCode ? _self.programmeCode : programmeCode // ignore: cast_nullable_to_non_nullable
as String?,teamDisplayName: freezed == teamDisplayName ? _self.teamDisplayName : teamDisplayName // ignore: cast_nullable_to_non_nullable
as String?,supervisorDisplayName: freezed == supervisorDisplayName ? _self.supervisorDisplayName : supervisorDisplayName // ignore: cast_nullable_to_non_nullable
as String?,publicationStatus: null == publicationStatus ? _self.publicationStatus : publicationStatus // ignore: cast_nullable_to_non_nullable
as String,sourceImportId: freezed == sourceImportId ? _self.sourceImportId : sourceImportId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
