// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fyp_form_evaluation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FypFormEvaluation {

 String get id; String get formSubmissionId; String? get rubricTemplateId; String get evaluatorId; Map<String, dynamic> get scores; double get weightedTotal; String? get comments; String get status;// 'draft', 'submitted', 'completed'
 DateTime? get evaluatedAt; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of FypFormEvaluation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FypFormEvaluationCopyWith<FypFormEvaluation> get copyWith => _$FypFormEvaluationCopyWithImpl<FypFormEvaluation>(this as FypFormEvaluation, _$identity);

  /// Serializes this FypFormEvaluation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FypFormEvaluation&&(identical(other.id, id) || other.id == id)&&(identical(other.formSubmissionId, formSubmissionId) || other.formSubmissionId == formSubmissionId)&&(identical(other.rubricTemplateId, rubricTemplateId) || other.rubricTemplateId == rubricTemplateId)&&(identical(other.evaluatorId, evaluatorId) || other.evaluatorId == evaluatorId)&&const DeepCollectionEquality().equals(other.scores, scores)&&(identical(other.weightedTotal, weightedTotal) || other.weightedTotal == weightedTotal)&&(identical(other.comments, comments) || other.comments == comments)&&(identical(other.status, status) || other.status == status)&&(identical(other.evaluatedAt, evaluatedAt) || other.evaluatedAt == evaluatedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,formSubmissionId,rubricTemplateId,evaluatorId,const DeepCollectionEquality().hash(scores),weightedTotal,comments,status,evaluatedAt,createdAt,updatedAt);

@override
String toString() {
  return 'FypFormEvaluation(id: $id, formSubmissionId: $formSubmissionId, rubricTemplateId: $rubricTemplateId, evaluatorId: $evaluatorId, scores: $scores, weightedTotal: $weightedTotal, comments: $comments, status: $status, evaluatedAt: $evaluatedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $FypFormEvaluationCopyWith<$Res>  {
  factory $FypFormEvaluationCopyWith(FypFormEvaluation value, $Res Function(FypFormEvaluation) _then) = _$FypFormEvaluationCopyWithImpl;
@useResult
$Res call({
 String id, String formSubmissionId, String? rubricTemplateId, String evaluatorId, Map<String, dynamic> scores, double weightedTotal, String? comments, String status, DateTime? evaluatedAt, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$FypFormEvaluationCopyWithImpl<$Res>
    implements $FypFormEvaluationCopyWith<$Res> {
  _$FypFormEvaluationCopyWithImpl(this._self, this._then);

  final FypFormEvaluation _self;
  final $Res Function(FypFormEvaluation) _then;

/// Create a copy of FypFormEvaluation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? formSubmissionId = null,Object? rubricTemplateId = freezed,Object? evaluatorId = null,Object? scores = null,Object? weightedTotal = null,Object? comments = freezed,Object? status = null,Object? evaluatedAt = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,formSubmissionId: null == formSubmissionId ? _self.formSubmissionId : formSubmissionId // ignore: cast_nullable_to_non_nullable
as String,rubricTemplateId: freezed == rubricTemplateId ? _self.rubricTemplateId : rubricTemplateId // ignore: cast_nullable_to_non_nullable
as String?,evaluatorId: null == evaluatorId ? _self.evaluatorId : evaluatorId // ignore: cast_nullable_to_non_nullable
as String,scores: null == scores ? _self.scores : scores // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,weightedTotal: null == weightedTotal ? _self.weightedTotal : weightedTotal // ignore: cast_nullable_to_non_nullable
as double,comments: freezed == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,evaluatedAt: freezed == evaluatedAt ? _self.evaluatedAt : evaluatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [FypFormEvaluation].
extension FypFormEvaluationPatterns on FypFormEvaluation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FypFormEvaluation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FypFormEvaluation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FypFormEvaluation value)  $default,){
final _that = this;
switch (_that) {
case _FypFormEvaluation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FypFormEvaluation value)?  $default,){
final _that = this;
switch (_that) {
case _FypFormEvaluation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String formSubmissionId,  String? rubricTemplateId,  String evaluatorId,  Map<String, dynamic> scores,  double weightedTotal,  String? comments,  String status,  DateTime? evaluatedAt,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FypFormEvaluation() when $default != null:
return $default(_that.id,_that.formSubmissionId,_that.rubricTemplateId,_that.evaluatorId,_that.scores,_that.weightedTotal,_that.comments,_that.status,_that.evaluatedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String formSubmissionId,  String? rubricTemplateId,  String evaluatorId,  Map<String, dynamic> scores,  double weightedTotal,  String? comments,  String status,  DateTime? evaluatedAt,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _FypFormEvaluation():
return $default(_that.id,_that.formSubmissionId,_that.rubricTemplateId,_that.evaluatorId,_that.scores,_that.weightedTotal,_that.comments,_that.status,_that.evaluatedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String formSubmissionId,  String? rubricTemplateId,  String evaluatorId,  Map<String, dynamic> scores,  double weightedTotal,  String? comments,  String status,  DateTime? evaluatedAt,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _FypFormEvaluation() when $default != null:
return $default(_that.id,_that.formSubmissionId,_that.rubricTemplateId,_that.evaluatorId,_that.scores,_that.weightedTotal,_that.comments,_that.status,_that.evaluatedAt,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FypFormEvaluation implements FypFormEvaluation {
  const _FypFormEvaluation({required this.id, required this.formSubmissionId, this.rubricTemplateId, required this.evaluatorId, required final  Map<String, dynamic> scores, required this.weightedTotal, this.comments, required this.status, this.evaluatedAt, required this.createdAt, required this.updatedAt}): _scores = scores;
  factory _FypFormEvaluation.fromJson(Map<String, dynamic> json) => _$FypFormEvaluationFromJson(json);

@override final  String id;
@override final  String formSubmissionId;
@override final  String? rubricTemplateId;
@override final  String evaluatorId;
 final  Map<String, dynamic> _scores;
@override Map<String, dynamic> get scores {
  if (_scores is EqualUnmodifiableMapView) return _scores;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_scores);
}

@override final  double weightedTotal;
@override final  String? comments;
@override final  String status;
// 'draft', 'submitted', 'completed'
@override final  DateTime? evaluatedAt;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of FypFormEvaluation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FypFormEvaluationCopyWith<_FypFormEvaluation> get copyWith => __$FypFormEvaluationCopyWithImpl<_FypFormEvaluation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FypFormEvaluationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FypFormEvaluation&&(identical(other.id, id) || other.id == id)&&(identical(other.formSubmissionId, formSubmissionId) || other.formSubmissionId == formSubmissionId)&&(identical(other.rubricTemplateId, rubricTemplateId) || other.rubricTemplateId == rubricTemplateId)&&(identical(other.evaluatorId, evaluatorId) || other.evaluatorId == evaluatorId)&&const DeepCollectionEquality().equals(other._scores, _scores)&&(identical(other.weightedTotal, weightedTotal) || other.weightedTotal == weightedTotal)&&(identical(other.comments, comments) || other.comments == comments)&&(identical(other.status, status) || other.status == status)&&(identical(other.evaluatedAt, evaluatedAt) || other.evaluatedAt == evaluatedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,formSubmissionId,rubricTemplateId,evaluatorId,const DeepCollectionEquality().hash(_scores),weightedTotal,comments,status,evaluatedAt,createdAt,updatedAt);

@override
String toString() {
  return 'FypFormEvaluation(id: $id, formSubmissionId: $formSubmissionId, rubricTemplateId: $rubricTemplateId, evaluatorId: $evaluatorId, scores: $scores, weightedTotal: $weightedTotal, comments: $comments, status: $status, evaluatedAt: $evaluatedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$FypFormEvaluationCopyWith<$Res> implements $FypFormEvaluationCopyWith<$Res> {
  factory _$FypFormEvaluationCopyWith(_FypFormEvaluation value, $Res Function(_FypFormEvaluation) _then) = __$FypFormEvaluationCopyWithImpl;
@override @useResult
$Res call({
 String id, String formSubmissionId, String? rubricTemplateId, String evaluatorId, Map<String, dynamic> scores, double weightedTotal, String? comments, String status, DateTime? evaluatedAt, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$FypFormEvaluationCopyWithImpl<$Res>
    implements _$FypFormEvaluationCopyWith<$Res> {
  __$FypFormEvaluationCopyWithImpl(this._self, this._then);

  final _FypFormEvaluation _self;
  final $Res Function(_FypFormEvaluation) _then;

/// Create a copy of FypFormEvaluation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? formSubmissionId = null,Object? rubricTemplateId = freezed,Object? evaluatorId = null,Object? scores = null,Object? weightedTotal = null,Object? comments = freezed,Object? status = null,Object? evaluatedAt = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_FypFormEvaluation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,formSubmissionId: null == formSubmissionId ? _self.formSubmissionId : formSubmissionId // ignore: cast_nullable_to_non_nullable
as String,rubricTemplateId: freezed == rubricTemplateId ? _self.rubricTemplateId : rubricTemplateId // ignore: cast_nullable_to_non_nullable
as String?,evaluatorId: null == evaluatorId ? _self.evaluatorId : evaluatorId // ignore: cast_nullable_to_non_nullable
as String,scores: null == scores ? _self._scores : scores // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,weightedTotal: null == weightedTotal ? _self.weightedTotal : weightedTotal // ignore: cast_nullable_to_non_nullable
as double,comments: freezed == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,evaluatedAt: freezed == evaluatedAt ? _self.evaluatedAt : evaluatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
