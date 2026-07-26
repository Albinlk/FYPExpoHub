// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'student_visit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StudentVisit {

 String get id; String get eventId; String get projectId; String get assignmentId; String get lecturerId; String get visitRole; String? get boothNumberSnapshot; String? get boothZoneSnapshot; DateTime get visitedAt; String? get visitNote; String get status; DateTime get createdAt; DateTime get updatedAt; DateTime? get voidedAt; String? get voidedBy; String? get voidReason; String get source;
/// Create a copy of StudentVisit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StudentVisitCopyWith<StudentVisit> get copyWith => _$StudentVisitCopyWithImpl<StudentVisit>(this as StudentVisit, _$identity);

  /// Serializes this StudentVisit to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StudentVisit&&(identical(other.id, id) || other.id == id)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.assignmentId, assignmentId) || other.assignmentId == assignmentId)&&(identical(other.lecturerId, lecturerId) || other.lecturerId == lecturerId)&&(identical(other.visitRole, visitRole) || other.visitRole == visitRole)&&(identical(other.boothNumberSnapshot, boothNumberSnapshot) || other.boothNumberSnapshot == boothNumberSnapshot)&&(identical(other.boothZoneSnapshot, boothZoneSnapshot) || other.boothZoneSnapshot == boothZoneSnapshot)&&(identical(other.visitedAt, visitedAt) || other.visitedAt == visitedAt)&&(identical(other.visitNote, visitNote) || other.visitNote == visitNote)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.voidedAt, voidedAt) || other.voidedAt == voidedAt)&&(identical(other.voidedBy, voidedBy) || other.voidedBy == voidedBy)&&(identical(other.voidReason, voidReason) || other.voidReason == voidReason)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,eventId,projectId,assignmentId,lecturerId,visitRole,boothNumberSnapshot,boothZoneSnapshot,visitedAt,visitNote,status,createdAt,updatedAt,voidedAt,voidedBy,voidReason,source);

@override
String toString() {
  return 'StudentVisit(id: $id, eventId: $eventId, projectId: $projectId, assignmentId: $assignmentId, lecturerId: $lecturerId, visitRole: $visitRole, boothNumberSnapshot: $boothNumberSnapshot, boothZoneSnapshot: $boothZoneSnapshot, visitedAt: $visitedAt, visitNote: $visitNote, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, voidedAt: $voidedAt, voidedBy: $voidedBy, voidReason: $voidReason, source: $source)';
}


}

/// @nodoc
abstract mixin class $StudentVisitCopyWith<$Res>  {
  factory $StudentVisitCopyWith(StudentVisit value, $Res Function(StudentVisit) _then) = _$StudentVisitCopyWithImpl;
@useResult
$Res call({
 String id, String eventId, String projectId, String assignmentId, String lecturerId, String visitRole, String? boothNumberSnapshot, String? boothZoneSnapshot, DateTime visitedAt, String? visitNote, String status, DateTime createdAt, DateTime updatedAt, DateTime? voidedAt, String? voidedBy, String? voidReason, String source
});




}
/// @nodoc
class _$StudentVisitCopyWithImpl<$Res>
    implements $StudentVisitCopyWith<$Res> {
  _$StudentVisitCopyWithImpl(this._self, this._then);

  final StudentVisit _self;
  final $Res Function(StudentVisit) _then;

/// Create a copy of StudentVisit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? eventId = null,Object? projectId = null,Object? assignmentId = null,Object? lecturerId = null,Object? visitRole = null,Object? boothNumberSnapshot = freezed,Object? boothZoneSnapshot = freezed,Object? visitedAt = null,Object? visitNote = freezed,Object? status = null,Object? createdAt = null,Object? updatedAt = null,Object? voidedAt = freezed,Object? voidedBy = freezed,Object? voidReason = freezed,Object? source = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,assignmentId: null == assignmentId ? _self.assignmentId : assignmentId // ignore: cast_nullable_to_non_nullable
as String,lecturerId: null == lecturerId ? _self.lecturerId : lecturerId // ignore: cast_nullable_to_non_nullable
as String,visitRole: null == visitRole ? _self.visitRole : visitRole // ignore: cast_nullable_to_non_nullable
as String,boothNumberSnapshot: freezed == boothNumberSnapshot ? _self.boothNumberSnapshot : boothNumberSnapshot // ignore: cast_nullable_to_non_nullable
as String?,boothZoneSnapshot: freezed == boothZoneSnapshot ? _self.boothZoneSnapshot : boothZoneSnapshot // ignore: cast_nullable_to_non_nullable
as String?,visitedAt: null == visitedAt ? _self.visitedAt : visitedAt // ignore: cast_nullable_to_non_nullable
as DateTime,visitNote: freezed == visitNote ? _self.visitNote : visitNote // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,voidedAt: freezed == voidedAt ? _self.voidedAt : voidedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,voidedBy: freezed == voidedBy ? _self.voidedBy : voidedBy // ignore: cast_nullable_to_non_nullable
as String?,voidReason: freezed == voidReason ? _self.voidReason : voidReason // ignore: cast_nullable_to_non_nullable
as String?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [StudentVisit].
extension StudentVisitPatterns on StudentVisit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StudentVisit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StudentVisit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StudentVisit value)  $default,){
final _that = this;
switch (_that) {
case _StudentVisit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StudentVisit value)?  $default,){
final _that = this;
switch (_that) {
case _StudentVisit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String eventId,  String projectId,  String assignmentId,  String lecturerId,  String visitRole,  String? boothNumberSnapshot,  String? boothZoneSnapshot,  DateTime visitedAt,  String? visitNote,  String status,  DateTime createdAt,  DateTime updatedAt,  DateTime? voidedAt,  String? voidedBy,  String? voidReason,  String source)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StudentVisit() when $default != null:
return $default(_that.id,_that.eventId,_that.projectId,_that.assignmentId,_that.lecturerId,_that.visitRole,_that.boothNumberSnapshot,_that.boothZoneSnapshot,_that.visitedAt,_that.visitNote,_that.status,_that.createdAt,_that.updatedAt,_that.voidedAt,_that.voidedBy,_that.voidReason,_that.source);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String eventId,  String projectId,  String assignmentId,  String lecturerId,  String visitRole,  String? boothNumberSnapshot,  String? boothZoneSnapshot,  DateTime visitedAt,  String? visitNote,  String status,  DateTime createdAt,  DateTime updatedAt,  DateTime? voidedAt,  String? voidedBy,  String? voidReason,  String source)  $default,) {final _that = this;
switch (_that) {
case _StudentVisit():
return $default(_that.id,_that.eventId,_that.projectId,_that.assignmentId,_that.lecturerId,_that.visitRole,_that.boothNumberSnapshot,_that.boothZoneSnapshot,_that.visitedAt,_that.visitNote,_that.status,_that.createdAt,_that.updatedAt,_that.voidedAt,_that.voidedBy,_that.voidReason,_that.source);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String eventId,  String projectId,  String assignmentId,  String lecturerId,  String visitRole,  String? boothNumberSnapshot,  String? boothZoneSnapshot,  DateTime visitedAt,  String? visitNote,  String status,  DateTime createdAt,  DateTime updatedAt,  DateTime? voidedAt,  String? voidedBy,  String? voidReason,  String source)?  $default,) {final _that = this;
switch (_that) {
case _StudentVisit() when $default != null:
return $default(_that.id,_that.eventId,_that.projectId,_that.assignmentId,_that.lecturerId,_that.visitRole,_that.boothNumberSnapshot,_that.boothZoneSnapshot,_that.visitedAt,_that.visitNote,_that.status,_that.createdAt,_that.updatedAt,_that.voidedAt,_that.voidedBy,_that.voidReason,_that.source);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StudentVisit implements StudentVisit {
  const _StudentVisit({required this.id, required this.eventId, required this.projectId, required this.assignmentId, required this.lecturerId, required this.visitRole, this.boothNumberSnapshot, this.boothZoneSnapshot, required this.visitedAt, this.visitNote, this.status = 'completed', required this.createdAt, required this.updatedAt, this.voidedAt, this.voidedBy, this.voidReason, this.source = 'lecturer'});
  factory _StudentVisit.fromJson(Map<String, dynamic> json) => _$StudentVisitFromJson(json);

@override final  String id;
@override final  String eventId;
@override final  String projectId;
@override final  String assignmentId;
@override final  String lecturerId;
@override final  String visitRole;
@override final  String? boothNumberSnapshot;
@override final  String? boothZoneSnapshot;
@override final  DateTime visitedAt;
@override final  String? visitNote;
@override@JsonKey() final  String status;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? voidedAt;
@override final  String? voidedBy;
@override final  String? voidReason;
@override@JsonKey() final  String source;

/// Create a copy of StudentVisit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StudentVisitCopyWith<_StudentVisit> get copyWith => __$StudentVisitCopyWithImpl<_StudentVisit>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StudentVisitToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StudentVisit&&(identical(other.id, id) || other.id == id)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.assignmentId, assignmentId) || other.assignmentId == assignmentId)&&(identical(other.lecturerId, lecturerId) || other.lecturerId == lecturerId)&&(identical(other.visitRole, visitRole) || other.visitRole == visitRole)&&(identical(other.boothNumberSnapshot, boothNumberSnapshot) || other.boothNumberSnapshot == boothNumberSnapshot)&&(identical(other.boothZoneSnapshot, boothZoneSnapshot) || other.boothZoneSnapshot == boothZoneSnapshot)&&(identical(other.visitedAt, visitedAt) || other.visitedAt == visitedAt)&&(identical(other.visitNote, visitNote) || other.visitNote == visitNote)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.voidedAt, voidedAt) || other.voidedAt == voidedAt)&&(identical(other.voidedBy, voidedBy) || other.voidedBy == voidedBy)&&(identical(other.voidReason, voidReason) || other.voidReason == voidReason)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,eventId,projectId,assignmentId,lecturerId,visitRole,boothNumberSnapshot,boothZoneSnapshot,visitedAt,visitNote,status,createdAt,updatedAt,voidedAt,voidedBy,voidReason,source);

@override
String toString() {
  return 'StudentVisit(id: $id, eventId: $eventId, projectId: $projectId, assignmentId: $assignmentId, lecturerId: $lecturerId, visitRole: $visitRole, boothNumberSnapshot: $boothNumberSnapshot, boothZoneSnapshot: $boothZoneSnapshot, visitedAt: $visitedAt, visitNote: $visitNote, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, voidedAt: $voidedAt, voidedBy: $voidedBy, voidReason: $voidReason, source: $source)';
}


}

/// @nodoc
abstract mixin class _$StudentVisitCopyWith<$Res> implements $StudentVisitCopyWith<$Res> {
  factory _$StudentVisitCopyWith(_StudentVisit value, $Res Function(_StudentVisit) _then) = __$StudentVisitCopyWithImpl;
@override @useResult
$Res call({
 String id, String eventId, String projectId, String assignmentId, String lecturerId, String visitRole, String? boothNumberSnapshot, String? boothZoneSnapshot, DateTime visitedAt, String? visitNote, String status, DateTime createdAt, DateTime updatedAt, DateTime? voidedAt, String? voidedBy, String? voidReason, String source
});




}
/// @nodoc
class __$StudentVisitCopyWithImpl<$Res>
    implements _$StudentVisitCopyWith<$Res> {
  __$StudentVisitCopyWithImpl(this._self, this._then);

  final _StudentVisit _self;
  final $Res Function(_StudentVisit) _then;

/// Create a copy of StudentVisit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? eventId = null,Object? projectId = null,Object? assignmentId = null,Object? lecturerId = null,Object? visitRole = null,Object? boothNumberSnapshot = freezed,Object? boothZoneSnapshot = freezed,Object? visitedAt = null,Object? visitNote = freezed,Object? status = null,Object? createdAt = null,Object? updatedAt = null,Object? voidedAt = freezed,Object? voidedBy = freezed,Object? voidReason = freezed,Object? source = null,}) {
  return _then(_StudentVisit(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,assignmentId: null == assignmentId ? _self.assignmentId : assignmentId // ignore: cast_nullable_to_non_nullable
as String,lecturerId: null == lecturerId ? _self.lecturerId : lecturerId // ignore: cast_nullable_to_non_nullable
as String,visitRole: null == visitRole ? _self.visitRole : visitRole // ignore: cast_nullable_to_non_nullable
as String,boothNumberSnapshot: freezed == boothNumberSnapshot ? _self.boothNumberSnapshot : boothNumberSnapshot // ignore: cast_nullable_to_non_nullable
as String?,boothZoneSnapshot: freezed == boothZoneSnapshot ? _self.boothZoneSnapshot : boothZoneSnapshot // ignore: cast_nullable_to_non_nullable
as String?,visitedAt: null == visitedAt ? _self.visitedAt : visitedAt // ignore: cast_nullable_to_non_nullable
as DateTime,visitNote: freezed == visitNote ? _self.visitNote : visitNote // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,voidedAt: freezed == voidedAt ? _self.voidedAt : voidedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,voidedBy: freezed == voidedBy ? _self.voidedBy : voidedBy // ignore: cast_nullable_to_non_nullable
as String?,voidReason: freezed == voidReason ? _self.voidReason : voidReason // ignore: cast_nullable_to_non_nullable
as String?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
