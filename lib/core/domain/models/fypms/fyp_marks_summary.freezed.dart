// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fyp_marks_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FypMarksSummary {

 String get id; String get fypRecordId; String get academicSemesterId; String get courseCode; Map<String, dynamic> get marks; double get weightedTotal; String? get grade; bool get isFinalized; String? get finalizedBy; DateTime? get finalizedAt; Map<String, dynamic>? get exportPayload; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of FypMarksSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FypMarksSummaryCopyWith<FypMarksSummary> get copyWith => _$FypMarksSummaryCopyWithImpl<FypMarksSummary>(this as FypMarksSummary, _$identity);

  /// Serializes this FypMarksSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FypMarksSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.fypRecordId, fypRecordId) || other.fypRecordId == fypRecordId)&&(identical(other.academicSemesterId, academicSemesterId) || other.academicSemesterId == academicSemesterId)&&(identical(other.courseCode, courseCode) || other.courseCode == courseCode)&&const DeepCollectionEquality().equals(other.marks, marks)&&(identical(other.weightedTotal, weightedTotal) || other.weightedTotal == weightedTotal)&&(identical(other.grade, grade) || other.grade == grade)&&(identical(other.isFinalized, isFinalized) || other.isFinalized == isFinalized)&&(identical(other.finalizedBy, finalizedBy) || other.finalizedBy == finalizedBy)&&(identical(other.finalizedAt, finalizedAt) || other.finalizedAt == finalizedAt)&&const DeepCollectionEquality().equals(other.exportPayload, exportPayload)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fypRecordId,academicSemesterId,courseCode,const DeepCollectionEquality().hash(marks),weightedTotal,grade,isFinalized,finalizedBy,finalizedAt,const DeepCollectionEquality().hash(exportPayload),createdAt,updatedAt);

@override
String toString() {
  return 'FypMarksSummary(id: $id, fypRecordId: $fypRecordId, academicSemesterId: $academicSemesterId, courseCode: $courseCode, marks: $marks, weightedTotal: $weightedTotal, grade: $grade, isFinalized: $isFinalized, finalizedBy: $finalizedBy, finalizedAt: $finalizedAt, exportPayload: $exportPayload, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $FypMarksSummaryCopyWith<$Res>  {
  factory $FypMarksSummaryCopyWith(FypMarksSummary value, $Res Function(FypMarksSummary) _then) = _$FypMarksSummaryCopyWithImpl;
@useResult
$Res call({
 String id, String fypRecordId, String academicSemesterId, String courseCode, Map<String, dynamic> marks, double weightedTotal, String? grade, bool isFinalized, String? finalizedBy, DateTime? finalizedAt, Map<String, dynamic>? exportPayload, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$FypMarksSummaryCopyWithImpl<$Res>
    implements $FypMarksSummaryCopyWith<$Res> {
  _$FypMarksSummaryCopyWithImpl(this._self, this._then);

  final FypMarksSummary _self;
  final $Res Function(FypMarksSummary) _then;

/// Create a copy of FypMarksSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fypRecordId = null,Object? academicSemesterId = null,Object? courseCode = null,Object? marks = null,Object? weightedTotal = null,Object? grade = freezed,Object? isFinalized = null,Object? finalizedBy = freezed,Object? finalizedAt = freezed,Object? exportPayload = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fypRecordId: null == fypRecordId ? _self.fypRecordId : fypRecordId // ignore: cast_nullable_to_non_nullable
as String,academicSemesterId: null == academicSemesterId ? _self.academicSemesterId : academicSemesterId // ignore: cast_nullable_to_non_nullable
as String,courseCode: null == courseCode ? _self.courseCode : courseCode // ignore: cast_nullable_to_non_nullable
as String,marks: null == marks ? _self.marks : marks // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,weightedTotal: null == weightedTotal ? _self.weightedTotal : weightedTotal // ignore: cast_nullable_to_non_nullable
as double,grade: freezed == grade ? _self.grade : grade // ignore: cast_nullable_to_non_nullable
as String?,isFinalized: null == isFinalized ? _self.isFinalized : isFinalized // ignore: cast_nullable_to_non_nullable
as bool,finalizedBy: freezed == finalizedBy ? _self.finalizedBy : finalizedBy // ignore: cast_nullable_to_non_nullable
as String?,finalizedAt: freezed == finalizedAt ? _self.finalizedAt : finalizedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,exportPayload: freezed == exportPayload ? _self.exportPayload : exportPayload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [FypMarksSummary].
extension FypMarksSummaryPatterns on FypMarksSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FypMarksSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FypMarksSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FypMarksSummary value)  $default,){
final _that = this;
switch (_that) {
case _FypMarksSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FypMarksSummary value)?  $default,){
final _that = this;
switch (_that) {
case _FypMarksSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fypRecordId,  String academicSemesterId,  String courseCode,  Map<String, dynamic> marks,  double weightedTotal,  String? grade,  bool isFinalized,  String? finalizedBy,  DateTime? finalizedAt,  Map<String, dynamic>? exportPayload,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FypMarksSummary() when $default != null:
return $default(_that.id,_that.fypRecordId,_that.academicSemesterId,_that.courseCode,_that.marks,_that.weightedTotal,_that.grade,_that.isFinalized,_that.finalizedBy,_that.finalizedAt,_that.exportPayload,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fypRecordId,  String academicSemesterId,  String courseCode,  Map<String, dynamic> marks,  double weightedTotal,  String? grade,  bool isFinalized,  String? finalizedBy,  DateTime? finalizedAt,  Map<String, dynamic>? exportPayload,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _FypMarksSummary():
return $default(_that.id,_that.fypRecordId,_that.academicSemesterId,_that.courseCode,_that.marks,_that.weightedTotal,_that.grade,_that.isFinalized,_that.finalizedBy,_that.finalizedAt,_that.exportPayload,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fypRecordId,  String academicSemesterId,  String courseCode,  Map<String, dynamic> marks,  double weightedTotal,  String? grade,  bool isFinalized,  String? finalizedBy,  DateTime? finalizedAt,  Map<String, dynamic>? exportPayload,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _FypMarksSummary() when $default != null:
return $default(_that.id,_that.fypRecordId,_that.academicSemesterId,_that.courseCode,_that.marks,_that.weightedTotal,_that.grade,_that.isFinalized,_that.finalizedBy,_that.finalizedAt,_that.exportPayload,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FypMarksSummary implements FypMarksSummary {
  const _FypMarksSummary({required this.id, required this.fypRecordId, required this.academicSemesterId, required this.courseCode, required final  Map<String, dynamic> marks, required this.weightedTotal, this.grade, required this.isFinalized, this.finalizedBy, this.finalizedAt, final  Map<String, dynamic>? exportPayload, required this.createdAt, required this.updatedAt}): _marks = marks,_exportPayload = exportPayload;
  factory _FypMarksSummary.fromJson(Map<String, dynamic> json) => _$FypMarksSummaryFromJson(json);

@override final  String id;
@override final  String fypRecordId;
@override final  String academicSemesterId;
@override final  String courseCode;
 final  Map<String, dynamic> _marks;
@override Map<String, dynamic> get marks {
  if (_marks is EqualUnmodifiableMapView) return _marks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_marks);
}

@override final  double weightedTotal;
@override final  String? grade;
@override final  bool isFinalized;
@override final  String? finalizedBy;
@override final  DateTime? finalizedAt;
 final  Map<String, dynamic>? _exportPayload;
@override Map<String, dynamic>? get exportPayload {
  final value = _exportPayload;
  if (value == null) return null;
  if (_exportPayload is EqualUnmodifiableMapView) return _exportPayload;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of FypMarksSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FypMarksSummaryCopyWith<_FypMarksSummary> get copyWith => __$FypMarksSummaryCopyWithImpl<_FypMarksSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FypMarksSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FypMarksSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.fypRecordId, fypRecordId) || other.fypRecordId == fypRecordId)&&(identical(other.academicSemesterId, academicSemesterId) || other.academicSemesterId == academicSemesterId)&&(identical(other.courseCode, courseCode) || other.courseCode == courseCode)&&const DeepCollectionEquality().equals(other._marks, _marks)&&(identical(other.weightedTotal, weightedTotal) || other.weightedTotal == weightedTotal)&&(identical(other.grade, grade) || other.grade == grade)&&(identical(other.isFinalized, isFinalized) || other.isFinalized == isFinalized)&&(identical(other.finalizedBy, finalizedBy) || other.finalizedBy == finalizedBy)&&(identical(other.finalizedAt, finalizedAt) || other.finalizedAt == finalizedAt)&&const DeepCollectionEquality().equals(other._exportPayload, _exportPayload)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fypRecordId,academicSemesterId,courseCode,const DeepCollectionEquality().hash(_marks),weightedTotal,grade,isFinalized,finalizedBy,finalizedAt,const DeepCollectionEquality().hash(_exportPayload),createdAt,updatedAt);

@override
String toString() {
  return 'FypMarksSummary(id: $id, fypRecordId: $fypRecordId, academicSemesterId: $academicSemesterId, courseCode: $courseCode, marks: $marks, weightedTotal: $weightedTotal, grade: $grade, isFinalized: $isFinalized, finalizedBy: $finalizedBy, finalizedAt: $finalizedAt, exportPayload: $exportPayload, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$FypMarksSummaryCopyWith<$Res> implements $FypMarksSummaryCopyWith<$Res> {
  factory _$FypMarksSummaryCopyWith(_FypMarksSummary value, $Res Function(_FypMarksSummary) _then) = __$FypMarksSummaryCopyWithImpl;
@override @useResult
$Res call({
 String id, String fypRecordId, String academicSemesterId, String courseCode, Map<String, dynamic> marks, double weightedTotal, String? grade, bool isFinalized, String? finalizedBy, DateTime? finalizedAt, Map<String, dynamic>? exportPayload, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$FypMarksSummaryCopyWithImpl<$Res>
    implements _$FypMarksSummaryCopyWith<$Res> {
  __$FypMarksSummaryCopyWithImpl(this._self, this._then);

  final _FypMarksSummary _self;
  final $Res Function(_FypMarksSummary) _then;

/// Create a copy of FypMarksSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fypRecordId = null,Object? academicSemesterId = null,Object? courseCode = null,Object? marks = null,Object? weightedTotal = null,Object? grade = freezed,Object? isFinalized = null,Object? finalizedBy = freezed,Object? finalizedAt = freezed,Object? exportPayload = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_FypMarksSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fypRecordId: null == fypRecordId ? _self.fypRecordId : fypRecordId // ignore: cast_nullable_to_non_nullable
as String,academicSemesterId: null == academicSemesterId ? _self.academicSemesterId : academicSemesterId // ignore: cast_nullable_to_non_nullable
as String,courseCode: null == courseCode ? _self.courseCode : courseCode // ignore: cast_nullable_to_non_nullable
as String,marks: null == marks ? _self._marks : marks // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,weightedTotal: null == weightedTotal ? _self.weightedTotal : weightedTotal // ignore: cast_nullable_to_non_nullable
as double,grade: freezed == grade ? _self.grade : grade // ignore: cast_nullable_to_non_nullable
as String?,isFinalized: null == isFinalized ? _self.isFinalized : isFinalized // ignore: cast_nullable_to_non_nullable
as bool,finalizedBy: freezed == finalizedBy ? _self.finalizedBy : finalizedBy // ignore: cast_nullable_to_non_nullable
as String?,finalizedAt: freezed == finalizedAt ? _self.finalizedAt : finalizedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,exportPayload: freezed == exportPayload ? _self._exportPayload : exportPayload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
