// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fyp_correction_confirmation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FypCorrectionConfirmation {

 String get id; String get correctionItemId; String get confirmedBy; DateTime get confirmedAt; String? get comment; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of FypCorrectionConfirmation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FypCorrectionConfirmationCopyWith<FypCorrectionConfirmation> get copyWith => _$FypCorrectionConfirmationCopyWithImpl<FypCorrectionConfirmation>(this as FypCorrectionConfirmation, _$identity);

  /// Serializes this FypCorrectionConfirmation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FypCorrectionConfirmation&&(identical(other.id, id) || other.id == id)&&(identical(other.correctionItemId, correctionItemId) || other.correctionItemId == correctionItemId)&&(identical(other.confirmedBy, confirmedBy) || other.confirmedBy == confirmedBy)&&(identical(other.confirmedAt, confirmedAt) || other.confirmedAt == confirmedAt)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,correctionItemId,confirmedBy,confirmedAt,comment,createdAt,updatedAt);

@override
String toString() {
  return 'FypCorrectionConfirmation(id: $id, correctionItemId: $correctionItemId, confirmedBy: $confirmedBy, confirmedAt: $confirmedAt, comment: $comment, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $FypCorrectionConfirmationCopyWith<$Res>  {
  factory $FypCorrectionConfirmationCopyWith(FypCorrectionConfirmation value, $Res Function(FypCorrectionConfirmation) _then) = _$FypCorrectionConfirmationCopyWithImpl;
@useResult
$Res call({
 String id, String correctionItemId, String confirmedBy, DateTime confirmedAt, String? comment, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$FypCorrectionConfirmationCopyWithImpl<$Res>
    implements $FypCorrectionConfirmationCopyWith<$Res> {
  _$FypCorrectionConfirmationCopyWithImpl(this._self, this._then);

  final FypCorrectionConfirmation _self;
  final $Res Function(FypCorrectionConfirmation) _then;

/// Create a copy of FypCorrectionConfirmation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? correctionItemId = null,Object? confirmedBy = null,Object? confirmedAt = null,Object? comment = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,correctionItemId: null == correctionItemId ? _self.correctionItemId : correctionItemId // ignore: cast_nullable_to_non_nullable
as String,confirmedBy: null == confirmedBy ? _self.confirmedBy : confirmedBy // ignore: cast_nullable_to_non_nullable
as String,confirmedAt: null == confirmedAt ? _self.confirmedAt : confirmedAt // ignore: cast_nullable_to_non_nullable
as DateTime,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [FypCorrectionConfirmation].
extension FypCorrectionConfirmationPatterns on FypCorrectionConfirmation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FypCorrectionConfirmation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FypCorrectionConfirmation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FypCorrectionConfirmation value)  $default,){
final _that = this;
switch (_that) {
case _FypCorrectionConfirmation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FypCorrectionConfirmation value)?  $default,){
final _that = this;
switch (_that) {
case _FypCorrectionConfirmation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String correctionItemId,  String confirmedBy,  DateTime confirmedAt,  String? comment,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FypCorrectionConfirmation() when $default != null:
return $default(_that.id,_that.correctionItemId,_that.confirmedBy,_that.confirmedAt,_that.comment,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String correctionItemId,  String confirmedBy,  DateTime confirmedAt,  String? comment,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _FypCorrectionConfirmation():
return $default(_that.id,_that.correctionItemId,_that.confirmedBy,_that.confirmedAt,_that.comment,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String correctionItemId,  String confirmedBy,  DateTime confirmedAt,  String? comment,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _FypCorrectionConfirmation() when $default != null:
return $default(_that.id,_that.correctionItemId,_that.confirmedBy,_that.confirmedAt,_that.comment,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FypCorrectionConfirmation implements FypCorrectionConfirmation {
  const _FypCorrectionConfirmation({required this.id, required this.correctionItemId, required this.confirmedBy, required this.confirmedAt, this.comment, required this.createdAt, required this.updatedAt});
  factory _FypCorrectionConfirmation.fromJson(Map<String, dynamic> json) => _$FypCorrectionConfirmationFromJson(json);

@override final  String id;
@override final  String correctionItemId;
@override final  String confirmedBy;
@override final  DateTime confirmedAt;
@override final  String? comment;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of FypCorrectionConfirmation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FypCorrectionConfirmationCopyWith<_FypCorrectionConfirmation> get copyWith => __$FypCorrectionConfirmationCopyWithImpl<_FypCorrectionConfirmation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FypCorrectionConfirmationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FypCorrectionConfirmation&&(identical(other.id, id) || other.id == id)&&(identical(other.correctionItemId, correctionItemId) || other.correctionItemId == correctionItemId)&&(identical(other.confirmedBy, confirmedBy) || other.confirmedBy == confirmedBy)&&(identical(other.confirmedAt, confirmedAt) || other.confirmedAt == confirmedAt)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,correctionItemId,confirmedBy,confirmedAt,comment,createdAt,updatedAt);

@override
String toString() {
  return 'FypCorrectionConfirmation(id: $id, correctionItemId: $correctionItemId, confirmedBy: $confirmedBy, confirmedAt: $confirmedAt, comment: $comment, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$FypCorrectionConfirmationCopyWith<$Res> implements $FypCorrectionConfirmationCopyWith<$Res> {
  factory _$FypCorrectionConfirmationCopyWith(_FypCorrectionConfirmation value, $Res Function(_FypCorrectionConfirmation) _then) = __$FypCorrectionConfirmationCopyWithImpl;
@override @useResult
$Res call({
 String id, String correctionItemId, String confirmedBy, DateTime confirmedAt, String? comment, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$FypCorrectionConfirmationCopyWithImpl<$Res>
    implements _$FypCorrectionConfirmationCopyWith<$Res> {
  __$FypCorrectionConfirmationCopyWithImpl(this._self, this._then);

  final _FypCorrectionConfirmation _self;
  final $Res Function(_FypCorrectionConfirmation) _then;

/// Create a copy of FypCorrectionConfirmation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? correctionItemId = null,Object? confirmedBy = null,Object? confirmedAt = null,Object? comment = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_FypCorrectionConfirmation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,correctionItemId: null == correctionItemId ? _self.correctionItemId : correctionItemId // ignore: cast_nullable_to_non_nullable
as String,confirmedBy: null == confirmedBy ? _self.confirmedBy : confirmedBy // ignore: cast_nullable_to_non_nullable
as String,confirmedAt: null == confirmedAt ? _self.confirmedAt : confirmedAt // ignore: cast_nullable_to_non_nullable
as DateTime,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
