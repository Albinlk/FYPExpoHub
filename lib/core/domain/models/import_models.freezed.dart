// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'import_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ImportRecord {

 String get id; String? get eventId; String get sourceFilePath; String get sourceFileName; String get sourceFileHash; String get uploadedBy; DateTime get uploadedAt; String get parserVersion; String get status; Map<String, int> get summary; Map<String, int> get warningCounts; String? get errorSummary; DateTime? get completedAt; DateTime? get publishedAt;
/// Create a copy of ImportRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImportRecordCopyWith<ImportRecord> get copyWith => _$ImportRecordCopyWithImpl<ImportRecord>(this as ImportRecord, _$identity);

  /// Serializes this ImportRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImportRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.sourceFilePath, sourceFilePath) || other.sourceFilePath == sourceFilePath)&&(identical(other.sourceFileName, sourceFileName) || other.sourceFileName == sourceFileName)&&(identical(other.sourceFileHash, sourceFileHash) || other.sourceFileHash == sourceFileHash)&&(identical(other.uploadedBy, uploadedBy) || other.uploadedBy == uploadedBy)&&(identical(other.uploadedAt, uploadedAt) || other.uploadedAt == uploadedAt)&&(identical(other.parserVersion, parserVersion) || other.parserVersion == parserVersion)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.summary, summary)&&const DeepCollectionEquality().equals(other.warningCounts, warningCounts)&&(identical(other.errorSummary, errorSummary) || other.errorSummary == errorSummary)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,eventId,sourceFilePath,sourceFileName,sourceFileHash,uploadedBy,uploadedAt,parserVersion,status,const DeepCollectionEquality().hash(summary),const DeepCollectionEquality().hash(warningCounts),errorSummary,completedAt,publishedAt);

@override
String toString() {
  return 'ImportRecord(id: $id, eventId: $eventId, sourceFilePath: $sourceFilePath, sourceFileName: $sourceFileName, sourceFileHash: $sourceFileHash, uploadedBy: $uploadedBy, uploadedAt: $uploadedAt, parserVersion: $parserVersion, status: $status, summary: $summary, warningCounts: $warningCounts, errorSummary: $errorSummary, completedAt: $completedAt, publishedAt: $publishedAt)';
}


}

/// @nodoc
abstract mixin class $ImportRecordCopyWith<$Res>  {
  factory $ImportRecordCopyWith(ImportRecord value, $Res Function(ImportRecord) _then) = _$ImportRecordCopyWithImpl;
@useResult
$Res call({
 String id, String? eventId, String sourceFilePath, String sourceFileName, String sourceFileHash, String uploadedBy, DateTime uploadedAt, String parserVersion, String status, Map<String, int> summary, Map<String, int> warningCounts, String? errorSummary, DateTime? completedAt, DateTime? publishedAt
});




}
/// @nodoc
class _$ImportRecordCopyWithImpl<$Res>
    implements $ImportRecordCopyWith<$Res> {
  _$ImportRecordCopyWithImpl(this._self, this._then);

  final ImportRecord _self;
  final $Res Function(ImportRecord) _then;

/// Create a copy of ImportRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? eventId = freezed,Object? sourceFilePath = null,Object? sourceFileName = null,Object? sourceFileHash = null,Object? uploadedBy = null,Object? uploadedAt = null,Object? parserVersion = null,Object? status = null,Object? summary = null,Object? warningCounts = null,Object? errorSummary = freezed,Object? completedAt = freezed,Object? publishedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,eventId: freezed == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String?,sourceFilePath: null == sourceFilePath ? _self.sourceFilePath : sourceFilePath // ignore: cast_nullable_to_non_nullable
as String,sourceFileName: null == sourceFileName ? _self.sourceFileName : sourceFileName // ignore: cast_nullable_to_non_nullable
as String,sourceFileHash: null == sourceFileHash ? _self.sourceFileHash : sourceFileHash // ignore: cast_nullable_to_non_nullable
as String,uploadedBy: null == uploadedBy ? _self.uploadedBy : uploadedBy // ignore: cast_nullable_to_non_nullable
as String,uploadedAt: null == uploadedAt ? _self.uploadedAt : uploadedAt // ignore: cast_nullable_to_non_nullable
as DateTime,parserVersion: null == parserVersion ? _self.parserVersion : parserVersion // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as Map<String, int>,warningCounts: null == warningCounts ? _self.warningCounts : warningCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,errorSummary: freezed == errorSummary ? _self.errorSummary : errorSummary // ignore: cast_nullable_to_non_nullable
as String?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ImportRecord].
extension ImportRecordPatterns on ImportRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImportRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImportRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImportRecord value)  $default,){
final _that = this;
switch (_that) {
case _ImportRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImportRecord value)?  $default,){
final _that = this;
switch (_that) {
case _ImportRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? eventId,  String sourceFilePath,  String sourceFileName,  String sourceFileHash,  String uploadedBy,  DateTime uploadedAt,  String parserVersion,  String status,  Map<String, int> summary,  Map<String, int> warningCounts,  String? errorSummary,  DateTime? completedAt,  DateTime? publishedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImportRecord() when $default != null:
return $default(_that.id,_that.eventId,_that.sourceFilePath,_that.sourceFileName,_that.sourceFileHash,_that.uploadedBy,_that.uploadedAt,_that.parserVersion,_that.status,_that.summary,_that.warningCounts,_that.errorSummary,_that.completedAt,_that.publishedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? eventId,  String sourceFilePath,  String sourceFileName,  String sourceFileHash,  String uploadedBy,  DateTime uploadedAt,  String parserVersion,  String status,  Map<String, int> summary,  Map<String, int> warningCounts,  String? errorSummary,  DateTime? completedAt,  DateTime? publishedAt)  $default,) {final _that = this;
switch (_that) {
case _ImportRecord():
return $default(_that.id,_that.eventId,_that.sourceFilePath,_that.sourceFileName,_that.sourceFileHash,_that.uploadedBy,_that.uploadedAt,_that.parserVersion,_that.status,_that.summary,_that.warningCounts,_that.errorSummary,_that.completedAt,_that.publishedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? eventId,  String sourceFilePath,  String sourceFileName,  String sourceFileHash,  String uploadedBy,  DateTime uploadedAt,  String parserVersion,  String status,  Map<String, int> summary,  Map<String, int> warningCounts,  String? errorSummary,  DateTime? completedAt,  DateTime? publishedAt)?  $default,) {final _that = this;
switch (_that) {
case _ImportRecord() when $default != null:
return $default(_that.id,_that.eventId,_that.sourceFilePath,_that.sourceFileName,_that.sourceFileHash,_that.uploadedBy,_that.uploadedAt,_that.parserVersion,_that.status,_that.summary,_that.warningCounts,_that.errorSummary,_that.completedAt,_that.publishedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ImportRecord implements ImportRecord {
  const _ImportRecord({required this.id, this.eventId, required this.sourceFilePath, required this.sourceFileName, required this.sourceFileHash, required this.uploadedBy, required this.uploadedAt, required this.parserVersion, required this.status, required final  Map<String, int> summary, required final  Map<String, int> warningCounts, this.errorSummary, this.completedAt, this.publishedAt}): _summary = summary,_warningCounts = warningCounts;
  factory _ImportRecord.fromJson(Map<String, dynamic> json) => _$ImportRecordFromJson(json);

@override final  String id;
@override final  String? eventId;
@override final  String sourceFilePath;
@override final  String sourceFileName;
@override final  String sourceFileHash;
@override final  String uploadedBy;
@override final  DateTime uploadedAt;
@override final  String parserVersion;
@override final  String status;
 final  Map<String, int> _summary;
@override Map<String, int> get summary {
  if (_summary is EqualUnmodifiableMapView) return _summary;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_summary);
}

 final  Map<String, int> _warningCounts;
@override Map<String, int> get warningCounts {
  if (_warningCounts is EqualUnmodifiableMapView) return _warningCounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_warningCounts);
}

@override final  String? errorSummary;
@override final  DateTime? completedAt;
@override final  DateTime? publishedAt;

/// Create a copy of ImportRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImportRecordCopyWith<_ImportRecord> get copyWith => __$ImportRecordCopyWithImpl<_ImportRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ImportRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImportRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.sourceFilePath, sourceFilePath) || other.sourceFilePath == sourceFilePath)&&(identical(other.sourceFileName, sourceFileName) || other.sourceFileName == sourceFileName)&&(identical(other.sourceFileHash, sourceFileHash) || other.sourceFileHash == sourceFileHash)&&(identical(other.uploadedBy, uploadedBy) || other.uploadedBy == uploadedBy)&&(identical(other.uploadedAt, uploadedAt) || other.uploadedAt == uploadedAt)&&(identical(other.parserVersion, parserVersion) || other.parserVersion == parserVersion)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._summary, _summary)&&const DeepCollectionEquality().equals(other._warningCounts, _warningCounts)&&(identical(other.errorSummary, errorSummary) || other.errorSummary == errorSummary)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,eventId,sourceFilePath,sourceFileName,sourceFileHash,uploadedBy,uploadedAt,parserVersion,status,const DeepCollectionEquality().hash(_summary),const DeepCollectionEquality().hash(_warningCounts),errorSummary,completedAt,publishedAt);

@override
String toString() {
  return 'ImportRecord(id: $id, eventId: $eventId, sourceFilePath: $sourceFilePath, sourceFileName: $sourceFileName, sourceFileHash: $sourceFileHash, uploadedBy: $uploadedBy, uploadedAt: $uploadedAt, parserVersion: $parserVersion, status: $status, summary: $summary, warningCounts: $warningCounts, errorSummary: $errorSummary, completedAt: $completedAt, publishedAt: $publishedAt)';
}


}

/// @nodoc
abstract mixin class _$ImportRecordCopyWith<$Res> implements $ImportRecordCopyWith<$Res> {
  factory _$ImportRecordCopyWith(_ImportRecord value, $Res Function(_ImportRecord) _then) = __$ImportRecordCopyWithImpl;
@override @useResult
$Res call({
 String id, String? eventId, String sourceFilePath, String sourceFileName, String sourceFileHash, String uploadedBy, DateTime uploadedAt, String parserVersion, String status, Map<String, int> summary, Map<String, int> warningCounts, String? errorSummary, DateTime? completedAt, DateTime? publishedAt
});




}
/// @nodoc
class __$ImportRecordCopyWithImpl<$Res>
    implements _$ImportRecordCopyWith<$Res> {
  __$ImportRecordCopyWithImpl(this._self, this._then);

  final _ImportRecord _self;
  final $Res Function(_ImportRecord) _then;

/// Create a copy of ImportRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? eventId = freezed,Object? sourceFilePath = null,Object? sourceFileName = null,Object? sourceFileHash = null,Object? uploadedBy = null,Object? uploadedAt = null,Object? parserVersion = null,Object? status = null,Object? summary = null,Object? warningCounts = null,Object? errorSummary = freezed,Object? completedAt = freezed,Object? publishedAt = freezed,}) {
  return _then(_ImportRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,eventId: freezed == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String?,sourceFilePath: null == sourceFilePath ? _self.sourceFilePath : sourceFilePath // ignore: cast_nullable_to_non_nullable
as String,sourceFileName: null == sourceFileName ? _self.sourceFileName : sourceFileName // ignore: cast_nullable_to_non_nullable
as String,sourceFileHash: null == sourceFileHash ? _self.sourceFileHash : sourceFileHash // ignore: cast_nullable_to_non_nullable
as String,uploadedBy: null == uploadedBy ? _self.uploadedBy : uploadedBy // ignore: cast_nullable_to_non_nullable
as String,uploadedAt: null == uploadedAt ? _self.uploadedAt : uploadedAt // ignore: cast_nullable_to_non_nullable
as DateTime,parserVersion: null == parserVersion ? _self.parserVersion : parserVersion // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self._summary : summary // ignore: cast_nullable_to_non_nullable
as Map<String, int>,warningCounts: null == warningCounts ? _self._warningCounts : warningCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,errorSummary: freezed == errorSummary ? _self.errorSummary : errorSummary // ignore: cast_nullable_to_non_nullable
as String?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$EventMetadataCandidate {

 String get id; String get title; String get sessionLabel; String get tentativeDateRange;
/// Create a copy of EventMetadataCandidate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventMetadataCandidateCopyWith<EventMetadataCandidate> get copyWith => _$EventMetadataCandidateCopyWithImpl<EventMetadataCandidate>(this as EventMetadataCandidate, _$identity);

  /// Serializes this EventMetadataCandidate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventMetadataCandidate&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.sessionLabel, sessionLabel) || other.sessionLabel == sessionLabel)&&(identical(other.tentativeDateRange, tentativeDateRange) || other.tentativeDateRange == tentativeDateRange));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,sessionLabel,tentativeDateRange);

@override
String toString() {
  return 'EventMetadataCandidate(id: $id, title: $title, sessionLabel: $sessionLabel, tentativeDateRange: $tentativeDateRange)';
}


}

/// @nodoc
abstract mixin class $EventMetadataCandidateCopyWith<$Res>  {
  factory $EventMetadataCandidateCopyWith(EventMetadataCandidate value, $Res Function(EventMetadataCandidate) _then) = _$EventMetadataCandidateCopyWithImpl;
@useResult
$Res call({
 String id, String title, String sessionLabel, String tentativeDateRange
});




}
/// @nodoc
class _$EventMetadataCandidateCopyWithImpl<$Res>
    implements $EventMetadataCandidateCopyWith<$Res> {
  _$EventMetadataCandidateCopyWithImpl(this._self, this._then);

  final EventMetadataCandidate _self;
  final $Res Function(EventMetadataCandidate) _then;

/// Create a copy of EventMetadataCandidate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? sessionLabel = null,Object? tentativeDateRange = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,sessionLabel: null == sessionLabel ? _self.sessionLabel : sessionLabel // ignore: cast_nullable_to_non_nullable
as String,tentativeDateRange: null == tentativeDateRange ? _self.tentativeDateRange : tentativeDateRange // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [EventMetadataCandidate].
extension EventMetadataCandidatePatterns on EventMetadataCandidate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventMetadataCandidate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventMetadataCandidate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventMetadataCandidate value)  $default,){
final _that = this;
switch (_that) {
case _EventMetadataCandidate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventMetadataCandidate value)?  $default,){
final _that = this;
switch (_that) {
case _EventMetadataCandidate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String sessionLabel,  String tentativeDateRange)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventMetadataCandidate() when $default != null:
return $default(_that.id,_that.title,_that.sessionLabel,_that.tentativeDateRange);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String sessionLabel,  String tentativeDateRange)  $default,) {final _that = this;
switch (_that) {
case _EventMetadataCandidate():
return $default(_that.id,_that.title,_that.sessionLabel,_that.tentativeDateRange);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String sessionLabel,  String tentativeDateRange)?  $default,) {final _that = this;
switch (_that) {
case _EventMetadataCandidate() when $default != null:
return $default(_that.id,_that.title,_that.sessionLabel,_that.tentativeDateRange);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EventMetadataCandidate implements EventMetadataCandidate {
  const _EventMetadataCandidate({required this.id, required this.title, required this.sessionLabel, required this.tentativeDateRange});
  factory _EventMetadataCandidate.fromJson(Map<String, dynamic> json) => _$EventMetadataCandidateFromJson(json);

@override final  String id;
@override final  String title;
@override final  String sessionLabel;
@override final  String tentativeDateRange;

/// Create a copy of EventMetadataCandidate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventMetadataCandidateCopyWith<_EventMetadataCandidate> get copyWith => __$EventMetadataCandidateCopyWithImpl<_EventMetadataCandidate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventMetadataCandidateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventMetadataCandidate&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.sessionLabel, sessionLabel) || other.sessionLabel == sessionLabel)&&(identical(other.tentativeDateRange, tentativeDateRange) || other.tentativeDateRange == tentativeDateRange));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,sessionLabel,tentativeDateRange);

@override
String toString() {
  return 'EventMetadataCandidate(id: $id, title: $title, sessionLabel: $sessionLabel, tentativeDateRange: $tentativeDateRange)';
}


}

/// @nodoc
abstract mixin class _$EventMetadataCandidateCopyWith<$Res> implements $EventMetadataCandidateCopyWith<$Res> {
  factory _$EventMetadataCandidateCopyWith(_EventMetadataCandidate value, $Res Function(_EventMetadataCandidate) _then) = __$EventMetadataCandidateCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String sessionLabel, String tentativeDateRange
});




}
/// @nodoc
class __$EventMetadataCandidateCopyWithImpl<$Res>
    implements _$EventMetadataCandidateCopyWith<$Res> {
  __$EventMetadataCandidateCopyWithImpl(this._self, this._then);

  final _EventMetadataCandidate _self;
  final $Res Function(_EventMetadataCandidate) _then;

/// Create a copy of EventMetadataCandidate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? sessionLabel = null,Object? tentativeDateRange = null,}) {
  return _then(_EventMetadataCandidate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,sessionLabel: null == sessionLabel ? _self.sessionLabel : sessionLabel // ignore: cast_nullable_to_non_nullable
as String,tentativeDateRange: null == tentativeDateRange ? _self.tentativeDateRange : tentativeDateRange // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ScheduleCandidate {

 String get id; DateTime get date; String get startAt; String get endAt; String get title; String get venue; String get audience; String get classification; String get comparisonStatus; bool get isDuplicate; bool get isOverlapping;
/// Create a copy of ScheduleCandidate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScheduleCandidateCopyWith<ScheduleCandidate> get copyWith => _$ScheduleCandidateCopyWithImpl<ScheduleCandidate>(this as ScheduleCandidate, _$identity);

  /// Serializes this ScheduleCandidate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScheduleCandidate&&(identical(other.id, id) || other.id == id)&&(identical(other.date, date) || other.date == date)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.title, title) || other.title == title)&&(identical(other.venue, venue) || other.venue == venue)&&(identical(other.audience, audience) || other.audience == audience)&&(identical(other.classification, classification) || other.classification == classification)&&(identical(other.comparisonStatus, comparisonStatus) || other.comparisonStatus == comparisonStatus)&&(identical(other.isDuplicate, isDuplicate) || other.isDuplicate == isDuplicate)&&(identical(other.isOverlapping, isOverlapping) || other.isOverlapping == isOverlapping));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,date,startAt,endAt,title,venue,audience,classification,comparisonStatus,isDuplicate,isOverlapping);

@override
String toString() {
  return 'ScheduleCandidate(id: $id, date: $date, startAt: $startAt, endAt: $endAt, title: $title, venue: $venue, audience: $audience, classification: $classification, comparisonStatus: $comparisonStatus, isDuplicate: $isDuplicate, isOverlapping: $isOverlapping)';
}


}

/// @nodoc
abstract mixin class $ScheduleCandidateCopyWith<$Res>  {
  factory $ScheduleCandidateCopyWith(ScheduleCandidate value, $Res Function(ScheduleCandidate) _then) = _$ScheduleCandidateCopyWithImpl;
@useResult
$Res call({
 String id, DateTime date, String startAt, String endAt, String title, String venue, String audience, String classification, String comparisonStatus, bool isDuplicate, bool isOverlapping
});




}
/// @nodoc
class _$ScheduleCandidateCopyWithImpl<$Res>
    implements $ScheduleCandidateCopyWith<$Res> {
  _$ScheduleCandidateCopyWithImpl(this._self, this._then);

  final ScheduleCandidate _self;
  final $Res Function(ScheduleCandidate) _then;

/// Create a copy of ScheduleCandidate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? date = null,Object? startAt = null,Object? endAt = null,Object? title = null,Object? venue = null,Object? audience = null,Object? classification = null,Object? comparisonStatus = null,Object? isDuplicate = null,Object? isOverlapping = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as String,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,venue: null == venue ? _self.venue : venue // ignore: cast_nullable_to_non_nullable
as String,audience: null == audience ? _self.audience : audience // ignore: cast_nullable_to_non_nullable
as String,classification: null == classification ? _self.classification : classification // ignore: cast_nullable_to_non_nullable
as String,comparisonStatus: null == comparisonStatus ? _self.comparisonStatus : comparisonStatus // ignore: cast_nullable_to_non_nullable
as String,isDuplicate: null == isDuplicate ? _self.isDuplicate : isDuplicate // ignore: cast_nullable_to_non_nullable
as bool,isOverlapping: null == isOverlapping ? _self.isOverlapping : isOverlapping // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ScheduleCandidate].
extension ScheduleCandidatePatterns on ScheduleCandidate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScheduleCandidate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScheduleCandidate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScheduleCandidate value)  $default,){
final _that = this;
switch (_that) {
case _ScheduleCandidate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScheduleCandidate value)?  $default,){
final _that = this;
switch (_that) {
case _ScheduleCandidate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime date,  String startAt,  String endAt,  String title,  String venue,  String audience,  String classification,  String comparisonStatus,  bool isDuplicate,  bool isOverlapping)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScheduleCandidate() when $default != null:
return $default(_that.id,_that.date,_that.startAt,_that.endAt,_that.title,_that.venue,_that.audience,_that.classification,_that.comparisonStatus,_that.isDuplicate,_that.isOverlapping);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime date,  String startAt,  String endAt,  String title,  String venue,  String audience,  String classification,  String comparisonStatus,  bool isDuplicate,  bool isOverlapping)  $default,) {final _that = this;
switch (_that) {
case _ScheduleCandidate():
return $default(_that.id,_that.date,_that.startAt,_that.endAt,_that.title,_that.venue,_that.audience,_that.classification,_that.comparisonStatus,_that.isDuplicate,_that.isOverlapping);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime date,  String startAt,  String endAt,  String title,  String venue,  String audience,  String classification,  String comparisonStatus,  bool isDuplicate,  bool isOverlapping)?  $default,) {final _that = this;
switch (_that) {
case _ScheduleCandidate() when $default != null:
return $default(_that.id,_that.date,_that.startAt,_that.endAt,_that.title,_that.venue,_that.audience,_that.classification,_that.comparisonStatus,_that.isDuplicate,_that.isOverlapping);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ScheduleCandidate implements ScheduleCandidate {
  const _ScheduleCandidate({required this.id, required this.date, required this.startAt, required this.endAt, required this.title, required this.venue, required this.audience, required this.classification, required this.comparisonStatus, required this.isDuplicate, required this.isOverlapping});
  factory _ScheduleCandidate.fromJson(Map<String, dynamic> json) => _$ScheduleCandidateFromJson(json);

@override final  String id;
@override final  DateTime date;
@override final  String startAt;
@override final  String endAt;
@override final  String title;
@override final  String venue;
@override final  String audience;
@override final  String classification;
@override final  String comparisonStatus;
@override final  bool isDuplicate;
@override final  bool isOverlapping;

/// Create a copy of ScheduleCandidate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScheduleCandidateCopyWith<_ScheduleCandidate> get copyWith => __$ScheduleCandidateCopyWithImpl<_ScheduleCandidate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScheduleCandidateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScheduleCandidate&&(identical(other.id, id) || other.id == id)&&(identical(other.date, date) || other.date == date)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.title, title) || other.title == title)&&(identical(other.venue, venue) || other.venue == venue)&&(identical(other.audience, audience) || other.audience == audience)&&(identical(other.classification, classification) || other.classification == classification)&&(identical(other.comparisonStatus, comparisonStatus) || other.comparisonStatus == comparisonStatus)&&(identical(other.isDuplicate, isDuplicate) || other.isDuplicate == isDuplicate)&&(identical(other.isOverlapping, isOverlapping) || other.isOverlapping == isOverlapping));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,date,startAt,endAt,title,venue,audience,classification,comparisonStatus,isDuplicate,isOverlapping);

@override
String toString() {
  return 'ScheduleCandidate(id: $id, date: $date, startAt: $startAt, endAt: $endAt, title: $title, venue: $venue, audience: $audience, classification: $classification, comparisonStatus: $comparisonStatus, isDuplicate: $isDuplicate, isOverlapping: $isOverlapping)';
}


}

/// @nodoc
abstract mixin class _$ScheduleCandidateCopyWith<$Res> implements $ScheduleCandidateCopyWith<$Res> {
  factory _$ScheduleCandidateCopyWith(_ScheduleCandidate value, $Res Function(_ScheduleCandidate) _then) = __$ScheduleCandidateCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime date, String startAt, String endAt, String title, String venue, String audience, String classification, String comparisonStatus, bool isDuplicate, bool isOverlapping
});




}
/// @nodoc
class __$ScheduleCandidateCopyWithImpl<$Res>
    implements _$ScheduleCandidateCopyWith<$Res> {
  __$ScheduleCandidateCopyWithImpl(this._self, this._then);

  final _ScheduleCandidate _self;
  final $Res Function(_ScheduleCandidate) _then;

/// Create a copy of ScheduleCandidate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? date = null,Object? startAt = null,Object? endAt = null,Object? title = null,Object? venue = null,Object? audience = null,Object? classification = null,Object? comparisonStatus = null,Object? isDuplicate = null,Object? isOverlapping = null,}) {
  return _then(_ScheduleCandidate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as String,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,venue: null == venue ? _self.venue : venue // ignore: cast_nullable_to_non_nullable
as String,audience: null == audience ? _self.audience : audience // ignore: cast_nullable_to_non_nullable
as String,classification: null == classification ? _self.classification : classification // ignore: cast_nullable_to_non_nullable
as String,comparisonStatus: null == comparisonStatus ? _self.comparisonStatus : comparisonStatus // ignore: cast_nullable_to_non_nullable
as String,isDuplicate: null == isDuplicate ? _self.isDuplicate : isDuplicate // ignore: cast_nullable_to_non_nullable
as bool,isOverlapping: null == isOverlapping ? _self.isOverlapping : isOverlapping // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$AwardCandidate {

 String get id; String get awardCategory; String get projectTitle; String? get teamDisplayName; String? get supervisorDisplayName; String? get programmeCode; bool get isSkip;
/// Create a copy of AwardCandidate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AwardCandidateCopyWith<AwardCandidate> get copyWith => _$AwardCandidateCopyWithImpl<AwardCandidate>(this as AwardCandidate, _$identity);

  /// Serializes this AwardCandidate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AwardCandidate&&(identical(other.id, id) || other.id == id)&&(identical(other.awardCategory, awardCategory) || other.awardCategory == awardCategory)&&(identical(other.projectTitle, projectTitle) || other.projectTitle == projectTitle)&&(identical(other.teamDisplayName, teamDisplayName) || other.teamDisplayName == teamDisplayName)&&(identical(other.supervisorDisplayName, supervisorDisplayName) || other.supervisorDisplayName == supervisorDisplayName)&&(identical(other.programmeCode, programmeCode) || other.programmeCode == programmeCode)&&(identical(other.isSkip, isSkip) || other.isSkip == isSkip));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,awardCategory,projectTitle,teamDisplayName,supervisorDisplayName,programmeCode,isSkip);

@override
String toString() {
  return 'AwardCandidate(id: $id, awardCategory: $awardCategory, projectTitle: $projectTitle, teamDisplayName: $teamDisplayName, supervisorDisplayName: $supervisorDisplayName, programmeCode: $programmeCode, isSkip: $isSkip)';
}


}

/// @nodoc
abstract mixin class $AwardCandidateCopyWith<$Res>  {
  factory $AwardCandidateCopyWith(AwardCandidate value, $Res Function(AwardCandidate) _then) = _$AwardCandidateCopyWithImpl;
@useResult
$Res call({
 String id, String awardCategory, String projectTitle, String? teamDisplayName, String? supervisorDisplayName, String? programmeCode, bool isSkip
});




}
/// @nodoc
class _$AwardCandidateCopyWithImpl<$Res>
    implements $AwardCandidateCopyWith<$Res> {
  _$AwardCandidateCopyWithImpl(this._self, this._then);

  final AwardCandidate _self;
  final $Res Function(AwardCandidate) _then;

/// Create a copy of AwardCandidate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? awardCategory = null,Object? projectTitle = null,Object? teamDisplayName = freezed,Object? supervisorDisplayName = freezed,Object? programmeCode = freezed,Object? isSkip = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,awardCategory: null == awardCategory ? _self.awardCategory : awardCategory // ignore: cast_nullable_to_non_nullable
as String,projectTitle: null == projectTitle ? _self.projectTitle : projectTitle // ignore: cast_nullable_to_non_nullable
as String,teamDisplayName: freezed == teamDisplayName ? _self.teamDisplayName : teamDisplayName // ignore: cast_nullable_to_non_nullable
as String?,supervisorDisplayName: freezed == supervisorDisplayName ? _self.supervisorDisplayName : supervisorDisplayName // ignore: cast_nullable_to_non_nullable
as String?,programmeCode: freezed == programmeCode ? _self.programmeCode : programmeCode // ignore: cast_nullable_to_non_nullable
as String?,isSkip: null == isSkip ? _self.isSkip : isSkip // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AwardCandidate].
extension AwardCandidatePatterns on AwardCandidate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AwardCandidate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AwardCandidate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AwardCandidate value)  $default,){
final _that = this;
switch (_that) {
case _AwardCandidate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AwardCandidate value)?  $default,){
final _that = this;
switch (_that) {
case _AwardCandidate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String awardCategory,  String projectTitle,  String? teamDisplayName,  String? supervisorDisplayName,  String? programmeCode,  bool isSkip)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AwardCandidate() when $default != null:
return $default(_that.id,_that.awardCategory,_that.projectTitle,_that.teamDisplayName,_that.supervisorDisplayName,_that.programmeCode,_that.isSkip);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String awardCategory,  String projectTitle,  String? teamDisplayName,  String? supervisorDisplayName,  String? programmeCode,  bool isSkip)  $default,) {final _that = this;
switch (_that) {
case _AwardCandidate():
return $default(_that.id,_that.awardCategory,_that.projectTitle,_that.teamDisplayName,_that.supervisorDisplayName,_that.programmeCode,_that.isSkip);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String awardCategory,  String projectTitle,  String? teamDisplayName,  String? supervisorDisplayName,  String? programmeCode,  bool isSkip)?  $default,) {final _that = this;
switch (_that) {
case _AwardCandidate() when $default != null:
return $default(_that.id,_that.awardCategory,_that.projectTitle,_that.teamDisplayName,_that.supervisorDisplayName,_that.programmeCode,_that.isSkip);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AwardCandidate implements AwardCandidate {
  const _AwardCandidate({required this.id, required this.awardCategory, required this.projectTitle, this.teamDisplayName, this.supervisorDisplayName, this.programmeCode, required this.isSkip});
  factory _AwardCandidate.fromJson(Map<String, dynamic> json) => _$AwardCandidateFromJson(json);

@override final  String id;
@override final  String awardCategory;
@override final  String projectTitle;
@override final  String? teamDisplayName;
@override final  String? supervisorDisplayName;
@override final  String? programmeCode;
@override final  bool isSkip;

/// Create a copy of AwardCandidate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AwardCandidateCopyWith<_AwardCandidate> get copyWith => __$AwardCandidateCopyWithImpl<_AwardCandidate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AwardCandidateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AwardCandidate&&(identical(other.id, id) || other.id == id)&&(identical(other.awardCategory, awardCategory) || other.awardCategory == awardCategory)&&(identical(other.projectTitle, projectTitle) || other.projectTitle == projectTitle)&&(identical(other.teamDisplayName, teamDisplayName) || other.teamDisplayName == teamDisplayName)&&(identical(other.supervisorDisplayName, supervisorDisplayName) || other.supervisorDisplayName == supervisorDisplayName)&&(identical(other.programmeCode, programmeCode) || other.programmeCode == programmeCode)&&(identical(other.isSkip, isSkip) || other.isSkip == isSkip));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,awardCategory,projectTitle,teamDisplayName,supervisorDisplayName,programmeCode,isSkip);

@override
String toString() {
  return 'AwardCandidate(id: $id, awardCategory: $awardCategory, projectTitle: $projectTitle, teamDisplayName: $teamDisplayName, supervisorDisplayName: $supervisorDisplayName, programmeCode: $programmeCode, isSkip: $isSkip)';
}


}

/// @nodoc
abstract mixin class _$AwardCandidateCopyWith<$Res> implements $AwardCandidateCopyWith<$Res> {
  factory _$AwardCandidateCopyWith(_AwardCandidate value, $Res Function(_AwardCandidate) _then) = __$AwardCandidateCopyWithImpl;
@override @useResult
$Res call({
 String id, String awardCategory, String projectTitle, String? teamDisplayName, String? supervisorDisplayName, String? programmeCode, bool isSkip
});




}
/// @nodoc
class __$AwardCandidateCopyWithImpl<$Res>
    implements _$AwardCandidateCopyWith<$Res> {
  __$AwardCandidateCopyWithImpl(this._self, this._then);

  final _AwardCandidate _self;
  final $Res Function(_AwardCandidate) _then;

/// Create a copy of AwardCandidate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? awardCategory = null,Object? projectTitle = null,Object? teamDisplayName = freezed,Object? supervisorDisplayName = freezed,Object? programmeCode = freezed,Object? isSkip = null,}) {
  return _then(_AwardCandidate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,awardCategory: null == awardCategory ? _self.awardCategory : awardCategory // ignore: cast_nullable_to_non_nullable
as String,projectTitle: null == projectTitle ? _self.projectTitle : projectTitle // ignore: cast_nullable_to_non_nullable
as String,teamDisplayName: freezed == teamDisplayName ? _self.teamDisplayName : teamDisplayName // ignore: cast_nullable_to_non_nullable
as String?,supervisorDisplayName: freezed == supervisorDisplayName ? _self.supervisorDisplayName : supervisorDisplayName // ignore: cast_nullable_to_non_nullable
as String?,programmeCode: freezed == programmeCode ? _self.programmeCode : programmeCode // ignore: cast_nullable_to_non_nullable
as String?,isSkip: null == isSkip ? _self.isSkip : isSkip // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$PrivacySkip {

 String get id; String get skipType; int get count; String get reason; String get worksheetName; DateTime get timestamp;
/// Create a copy of PrivacySkip
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrivacySkipCopyWith<PrivacySkip> get copyWith => _$PrivacySkipCopyWithImpl<PrivacySkip>(this as PrivacySkip, _$identity);

  /// Serializes this PrivacySkip to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrivacySkip&&(identical(other.id, id) || other.id == id)&&(identical(other.skipType, skipType) || other.skipType == skipType)&&(identical(other.count, count) || other.count == count)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.worksheetName, worksheetName) || other.worksheetName == worksheetName)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,skipType,count,reason,worksheetName,timestamp);

@override
String toString() {
  return 'PrivacySkip(id: $id, skipType: $skipType, count: $count, reason: $reason, worksheetName: $worksheetName, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class $PrivacySkipCopyWith<$Res>  {
  factory $PrivacySkipCopyWith(PrivacySkip value, $Res Function(PrivacySkip) _then) = _$PrivacySkipCopyWithImpl;
@useResult
$Res call({
 String id, String skipType, int count, String reason, String worksheetName, DateTime timestamp
});




}
/// @nodoc
class _$PrivacySkipCopyWithImpl<$Res>
    implements $PrivacySkipCopyWith<$Res> {
  _$PrivacySkipCopyWithImpl(this._self, this._then);

  final PrivacySkip _self;
  final $Res Function(PrivacySkip) _then;

/// Create a copy of PrivacySkip
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? skipType = null,Object? count = null,Object? reason = null,Object? worksheetName = null,Object? timestamp = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,skipType: null == skipType ? _self.skipType : skipType // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,worksheetName: null == worksheetName ? _self.worksheetName : worksheetName // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PrivacySkip].
extension PrivacySkipPatterns on PrivacySkip {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PrivacySkip value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PrivacySkip() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PrivacySkip value)  $default,){
final _that = this;
switch (_that) {
case _PrivacySkip():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PrivacySkip value)?  $default,){
final _that = this;
switch (_that) {
case _PrivacySkip() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String skipType,  int count,  String reason,  String worksheetName,  DateTime timestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PrivacySkip() when $default != null:
return $default(_that.id,_that.skipType,_that.count,_that.reason,_that.worksheetName,_that.timestamp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String skipType,  int count,  String reason,  String worksheetName,  DateTime timestamp)  $default,) {final _that = this;
switch (_that) {
case _PrivacySkip():
return $default(_that.id,_that.skipType,_that.count,_that.reason,_that.worksheetName,_that.timestamp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String skipType,  int count,  String reason,  String worksheetName,  DateTime timestamp)?  $default,) {final _that = this;
switch (_that) {
case _PrivacySkip() when $default != null:
return $default(_that.id,_that.skipType,_that.count,_that.reason,_that.worksheetName,_that.timestamp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PrivacySkip implements PrivacySkip {
  const _PrivacySkip({required this.id, required this.skipType, required this.count, required this.reason, required this.worksheetName, required this.timestamp});
  factory _PrivacySkip.fromJson(Map<String, dynamic> json) => _$PrivacySkipFromJson(json);

@override final  String id;
@override final  String skipType;
@override final  int count;
@override final  String reason;
@override final  String worksheetName;
@override final  DateTime timestamp;

/// Create a copy of PrivacySkip
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PrivacySkipCopyWith<_PrivacySkip> get copyWith => __$PrivacySkipCopyWithImpl<_PrivacySkip>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PrivacySkipToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PrivacySkip&&(identical(other.id, id) || other.id == id)&&(identical(other.skipType, skipType) || other.skipType == skipType)&&(identical(other.count, count) || other.count == count)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.worksheetName, worksheetName) || other.worksheetName == worksheetName)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,skipType,count,reason,worksheetName,timestamp);

@override
String toString() {
  return 'PrivacySkip(id: $id, skipType: $skipType, count: $count, reason: $reason, worksheetName: $worksheetName, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class _$PrivacySkipCopyWith<$Res> implements $PrivacySkipCopyWith<$Res> {
  factory _$PrivacySkipCopyWith(_PrivacySkip value, $Res Function(_PrivacySkip) _then) = __$PrivacySkipCopyWithImpl;
@override @useResult
$Res call({
 String id, String skipType, int count, String reason, String worksheetName, DateTime timestamp
});




}
/// @nodoc
class __$PrivacySkipCopyWithImpl<$Res>
    implements _$PrivacySkipCopyWith<$Res> {
  __$PrivacySkipCopyWithImpl(this._self, this._then);

  final _PrivacySkip _self;
  final $Res Function(_PrivacySkip) _then;

/// Create a copy of PrivacySkip
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? skipType = null,Object? count = null,Object? reason = null,Object? worksheetName = null,Object? timestamp = null,}) {
  return _then(_PrivacySkip(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,skipType: null == skipType ? _self.skipType : skipType // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,worksheetName: null == worksheetName ? _self.worksheetName : worksheetName // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$ValidationIssue {

 String get id; String get issueType; String get severity; String get message; String get worksheetName; int? get rowNumber;
/// Create a copy of ValidationIssue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ValidationIssueCopyWith<ValidationIssue> get copyWith => _$ValidationIssueCopyWithImpl<ValidationIssue>(this as ValidationIssue, _$identity);

  /// Serializes this ValidationIssue to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ValidationIssue&&(identical(other.id, id) || other.id == id)&&(identical(other.issueType, issueType) || other.issueType == issueType)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.message, message) || other.message == message)&&(identical(other.worksheetName, worksheetName) || other.worksheetName == worksheetName)&&(identical(other.rowNumber, rowNumber) || other.rowNumber == rowNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,issueType,severity,message,worksheetName,rowNumber);

@override
String toString() {
  return 'ValidationIssue(id: $id, issueType: $issueType, severity: $severity, message: $message, worksheetName: $worksheetName, rowNumber: $rowNumber)';
}


}

/// @nodoc
abstract mixin class $ValidationIssueCopyWith<$Res>  {
  factory $ValidationIssueCopyWith(ValidationIssue value, $Res Function(ValidationIssue) _then) = _$ValidationIssueCopyWithImpl;
@useResult
$Res call({
 String id, String issueType, String severity, String message, String worksheetName, int? rowNumber
});




}
/// @nodoc
class _$ValidationIssueCopyWithImpl<$Res>
    implements $ValidationIssueCopyWith<$Res> {
  _$ValidationIssueCopyWithImpl(this._self, this._then);

  final ValidationIssue _self;
  final $Res Function(ValidationIssue) _then;

/// Create a copy of ValidationIssue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? issueType = null,Object? severity = null,Object? message = null,Object? worksheetName = null,Object? rowNumber = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,issueType: null == issueType ? _self.issueType : issueType // ignore: cast_nullable_to_non_nullable
as String,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,worksheetName: null == worksheetName ? _self.worksheetName : worksheetName // ignore: cast_nullable_to_non_nullable
as String,rowNumber: freezed == rowNumber ? _self.rowNumber : rowNumber // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ValidationIssue].
extension ValidationIssuePatterns on ValidationIssue {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ValidationIssue value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ValidationIssue() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ValidationIssue value)  $default,){
final _that = this;
switch (_that) {
case _ValidationIssue():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ValidationIssue value)?  $default,){
final _that = this;
switch (_that) {
case _ValidationIssue() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String issueType,  String severity,  String message,  String worksheetName,  int? rowNumber)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ValidationIssue() when $default != null:
return $default(_that.id,_that.issueType,_that.severity,_that.message,_that.worksheetName,_that.rowNumber);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String issueType,  String severity,  String message,  String worksheetName,  int? rowNumber)  $default,) {final _that = this;
switch (_that) {
case _ValidationIssue():
return $default(_that.id,_that.issueType,_that.severity,_that.message,_that.worksheetName,_that.rowNumber);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String issueType,  String severity,  String message,  String worksheetName,  int? rowNumber)?  $default,) {final _that = this;
switch (_that) {
case _ValidationIssue() when $default != null:
return $default(_that.id,_that.issueType,_that.severity,_that.message,_that.worksheetName,_that.rowNumber);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ValidationIssue implements ValidationIssue {
  const _ValidationIssue({required this.id, required this.issueType, required this.severity, required this.message, required this.worksheetName, this.rowNumber});
  factory _ValidationIssue.fromJson(Map<String, dynamic> json) => _$ValidationIssueFromJson(json);

@override final  String id;
@override final  String issueType;
@override final  String severity;
@override final  String message;
@override final  String worksheetName;
@override final  int? rowNumber;

/// Create a copy of ValidationIssue
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ValidationIssueCopyWith<_ValidationIssue> get copyWith => __$ValidationIssueCopyWithImpl<_ValidationIssue>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ValidationIssueToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ValidationIssue&&(identical(other.id, id) || other.id == id)&&(identical(other.issueType, issueType) || other.issueType == issueType)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.message, message) || other.message == message)&&(identical(other.worksheetName, worksheetName) || other.worksheetName == worksheetName)&&(identical(other.rowNumber, rowNumber) || other.rowNumber == rowNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,issueType,severity,message,worksheetName,rowNumber);

@override
String toString() {
  return 'ValidationIssue(id: $id, issueType: $issueType, severity: $severity, message: $message, worksheetName: $worksheetName, rowNumber: $rowNumber)';
}


}

/// @nodoc
abstract mixin class _$ValidationIssueCopyWith<$Res> implements $ValidationIssueCopyWith<$Res> {
  factory _$ValidationIssueCopyWith(_ValidationIssue value, $Res Function(_ValidationIssue) _then) = __$ValidationIssueCopyWithImpl;
@override @useResult
$Res call({
 String id, String issueType, String severity, String message, String worksheetName, int? rowNumber
});




}
/// @nodoc
class __$ValidationIssueCopyWithImpl<$Res>
    implements _$ValidationIssueCopyWith<$Res> {
  __$ValidationIssueCopyWithImpl(this._self, this._then);

  final _ValidationIssue _self;
  final $Res Function(_ValidationIssue) _then;

/// Create a copy of ValidationIssue
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? issueType = null,Object? severity = null,Object? message = null,Object? worksheetName = null,Object? rowNumber = freezed,}) {
  return _then(_ValidationIssue(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,issueType: null == issueType ? _self.issueType : issueType // ignore: cast_nullable_to_non_nullable
as String,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,worksheetName: null == worksheetName ? _self.worksheetName : worksheetName // ignore: cast_nullable_to_non_nullable
as String,rowNumber: freezed == rowNumber ? _self.rowNumber : rowNumber // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$ReviewDecision {

 String get id; String get candidateType; String get decision; DateTime get updatedAt; String get updatedBy; Map<String, dynamic>? get editedData;
/// Create a copy of ReviewDecision
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReviewDecisionCopyWith<ReviewDecision> get copyWith => _$ReviewDecisionCopyWithImpl<ReviewDecision>(this as ReviewDecision, _$identity);

  /// Serializes this ReviewDecision to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReviewDecision&&(identical(other.id, id) || other.id == id)&&(identical(other.candidateType, candidateType) || other.candidateType == candidateType)&&(identical(other.decision, decision) || other.decision == decision)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.updatedBy, updatedBy) || other.updatedBy == updatedBy)&&const DeepCollectionEquality().equals(other.editedData, editedData));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,candidateType,decision,updatedAt,updatedBy,const DeepCollectionEquality().hash(editedData));

@override
String toString() {
  return 'ReviewDecision(id: $id, candidateType: $candidateType, decision: $decision, updatedAt: $updatedAt, updatedBy: $updatedBy, editedData: $editedData)';
}


}

/// @nodoc
abstract mixin class $ReviewDecisionCopyWith<$Res>  {
  factory $ReviewDecisionCopyWith(ReviewDecision value, $Res Function(ReviewDecision) _then) = _$ReviewDecisionCopyWithImpl;
@useResult
$Res call({
 String id, String candidateType, String decision, DateTime updatedAt, String updatedBy, Map<String, dynamic>? editedData
});




}
/// @nodoc
class _$ReviewDecisionCopyWithImpl<$Res>
    implements $ReviewDecisionCopyWith<$Res> {
  _$ReviewDecisionCopyWithImpl(this._self, this._then);

  final ReviewDecision _self;
  final $Res Function(ReviewDecision) _then;

/// Create a copy of ReviewDecision
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? candidateType = null,Object? decision = null,Object? updatedAt = null,Object? updatedBy = null,Object? editedData = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,candidateType: null == candidateType ? _self.candidateType : candidateType // ignore: cast_nullable_to_non_nullable
as String,decision: null == decision ? _self.decision : decision // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedBy: null == updatedBy ? _self.updatedBy : updatedBy // ignore: cast_nullable_to_non_nullable
as String,editedData: freezed == editedData ? _self.editedData : editedData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ReviewDecision].
extension ReviewDecisionPatterns on ReviewDecision {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReviewDecision value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReviewDecision() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReviewDecision value)  $default,){
final _that = this;
switch (_that) {
case _ReviewDecision():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReviewDecision value)?  $default,){
final _that = this;
switch (_that) {
case _ReviewDecision() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String candidateType,  String decision,  DateTime updatedAt,  String updatedBy,  Map<String, dynamic>? editedData)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReviewDecision() when $default != null:
return $default(_that.id,_that.candidateType,_that.decision,_that.updatedAt,_that.updatedBy,_that.editedData);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String candidateType,  String decision,  DateTime updatedAt,  String updatedBy,  Map<String, dynamic>? editedData)  $default,) {final _that = this;
switch (_that) {
case _ReviewDecision():
return $default(_that.id,_that.candidateType,_that.decision,_that.updatedAt,_that.updatedBy,_that.editedData);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String candidateType,  String decision,  DateTime updatedAt,  String updatedBy,  Map<String, dynamic>? editedData)?  $default,) {final _that = this;
switch (_that) {
case _ReviewDecision() when $default != null:
return $default(_that.id,_that.candidateType,_that.decision,_that.updatedAt,_that.updatedBy,_that.editedData);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReviewDecision implements ReviewDecision {
  const _ReviewDecision({required this.id, required this.candidateType, required this.decision, required this.updatedAt, required this.updatedBy, final  Map<String, dynamic>? editedData}): _editedData = editedData;
  factory _ReviewDecision.fromJson(Map<String, dynamic> json) => _$ReviewDecisionFromJson(json);

@override final  String id;
@override final  String candidateType;
@override final  String decision;
@override final  DateTime updatedAt;
@override final  String updatedBy;
 final  Map<String, dynamic>? _editedData;
@override Map<String, dynamic>? get editedData {
  final value = _editedData;
  if (value == null) return null;
  if (_editedData is EqualUnmodifiableMapView) return _editedData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of ReviewDecision
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReviewDecisionCopyWith<_ReviewDecision> get copyWith => __$ReviewDecisionCopyWithImpl<_ReviewDecision>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReviewDecisionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReviewDecision&&(identical(other.id, id) || other.id == id)&&(identical(other.candidateType, candidateType) || other.candidateType == candidateType)&&(identical(other.decision, decision) || other.decision == decision)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.updatedBy, updatedBy) || other.updatedBy == updatedBy)&&const DeepCollectionEquality().equals(other._editedData, _editedData));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,candidateType,decision,updatedAt,updatedBy,const DeepCollectionEquality().hash(_editedData));

@override
String toString() {
  return 'ReviewDecision(id: $id, candidateType: $candidateType, decision: $decision, updatedAt: $updatedAt, updatedBy: $updatedBy, editedData: $editedData)';
}


}

/// @nodoc
abstract mixin class _$ReviewDecisionCopyWith<$Res> implements $ReviewDecisionCopyWith<$Res> {
  factory _$ReviewDecisionCopyWith(_ReviewDecision value, $Res Function(_ReviewDecision) _then) = __$ReviewDecisionCopyWithImpl;
@override @useResult
$Res call({
 String id, String candidateType, String decision, DateTime updatedAt, String updatedBy, Map<String, dynamic>? editedData
});




}
/// @nodoc
class __$ReviewDecisionCopyWithImpl<$Res>
    implements _$ReviewDecisionCopyWith<$Res> {
  __$ReviewDecisionCopyWithImpl(this._self, this._then);

  final _ReviewDecision _self;
  final $Res Function(_ReviewDecision) _then;

/// Create a copy of ReviewDecision
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? candidateType = null,Object? decision = null,Object? updatedAt = null,Object? updatedBy = null,Object? editedData = freezed,}) {
  return _then(_ReviewDecision(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,candidateType: null == candidateType ? _self.candidateType : candidateType // ignore: cast_nullable_to_non_nullable
as String,decision: null == decision ? _self.decision : decision // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedBy: null == updatedBy ? _self.updatedBy : updatedBy // ignore: cast_nullable_to_non_nullable
as String,editedData: freezed == editedData ? _self._editedData : editedData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
