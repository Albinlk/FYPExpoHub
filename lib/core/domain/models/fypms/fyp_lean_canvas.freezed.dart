// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fyp_lean_canvas.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FypLeanCanvas {

 String get id; String get fypRecordId; int get canvasVersion; Map<String, dynamic> get blocks; bool get isLatest; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of FypLeanCanvas
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FypLeanCanvasCopyWith<FypLeanCanvas> get copyWith => _$FypLeanCanvasCopyWithImpl<FypLeanCanvas>(this as FypLeanCanvas, _$identity);

  /// Serializes this FypLeanCanvas to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FypLeanCanvas&&(identical(other.id, id) || other.id == id)&&(identical(other.fypRecordId, fypRecordId) || other.fypRecordId == fypRecordId)&&(identical(other.canvasVersion, canvasVersion) || other.canvasVersion == canvasVersion)&&const DeepCollectionEquality().equals(other.blocks, blocks)&&(identical(other.isLatest, isLatest) || other.isLatest == isLatest)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fypRecordId,canvasVersion,const DeepCollectionEquality().hash(blocks),isLatest,createdAt,updatedAt);

@override
String toString() {
  return 'FypLeanCanvas(id: $id, fypRecordId: $fypRecordId, canvasVersion: $canvasVersion, blocks: $blocks, isLatest: $isLatest, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $FypLeanCanvasCopyWith<$Res>  {
  factory $FypLeanCanvasCopyWith(FypLeanCanvas value, $Res Function(FypLeanCanvas) _then) = _$FypLeanCanvasCopyWithImpl;
@useResult
$Res call({
 String id, String fypRecordId, int canvasVersion, Map<String, dynamic> blocks, bool isLatest, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$FypLeanCanvasCopyWithImpl<$Res>
    implements $FypLeanCanvasCopyWith<$Res> {
  _$FypLeanCanvasCopyWithImpl(this._self, this._then);

  final FypLeanCanvas _self;
  final $Res Function(FypLeanCanvas) _then;

/// Create a copy of FypLeanCanvas
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fypRecordId = null,Object? canvasVersion = null,Object? blocks = null,Object? isLatest = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fypRecordId: null == fypRecordId ? _self.fypRecordId : fypRecordId // ignore: cast_nullable_to_non_nullable
as String,canvasVersion: null == canvasVersion ? _self.canvasVersion : canvasVersion // ignore: cast_nullable_to_non_nullable
as int,blocks: null == blocks ? _self.blocks : blocks // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,isLatest: null == isLatest ? _self.isLatest : isLatest // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [FypLeanCanvas].
extension FypLeanCanvasPatterns on FypLeanCanvas {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FypLeanCanvas value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FypLeanCanvas() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FypLeanCanvas value)  $default,){
final _that = this;
switch (_that) {
case _FypLeanCanvas():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FypLeanCanvas value)?  $default,){
final _that = this;
switch (_that) {
case _FypLeanCanvas() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fypRecordId,  int canvasVersion,  Map<String, dynamic> blocks,  bool isLatest,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FypLeanCanvas() when $default != null:
return $default(_that.id,_that.fypRecordId,_that.canvasVersion,_that.blocks,_that.isLatest,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fypRecordId,  int canvasVersion,  Map<String, dynamic> blocks,  bool isLatest,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _FypLeanCanvas():
return $default(_that.id,_that.fypRecordId,_that.canvasVersion,_that.blocks,_that.isLatest,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fypRecordId,  int canvasVersion,  Map<String, dynamic> blocks,  bool isLatest,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _FypLeanCanvas() when $default != null:
return $default(_that.id,_that.fypRecordId,_that.canvasVersion,_that.blocks,_that.isLatest,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FypLeanCanvas implements FypLeanCanvas {
  const _FypLeanCanvas({required this.id, required this.fypRecordId, required this.canvasVersion, required final  Map<String, dynamic> blocks, required this.isLatest, required this.createdAt, required this.updatedAt}): _blocks = blocks;
  factory _FypLeanCanvas.fromJson(Map<String, dynamic> json) => _$FypLeanCanvasFromJson(json);

@override final  String id;
@override final  String fypRecordId;
@override final  int canvasVersion;
 final  Map<String, dynamic> _blocks;
@override Map<String, dynamic> get blocks {
  if (_blocks is EqualUnmodifiableMapView) return _blocks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_blocks);
}

@override final  bool isLatest;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of FypLeanCanvas
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FypLeanCanvasCopyWith<_FypLeanCanvas> get copyWith => __$FypLeanCanvasCopyWithImpl<_FypLeanCanvas>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FypLeanCanvasToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FypLeanCanvas&&(identical(other.id, id) || other.id == id)&&(identical(other.fypRecordId, fypRecordId) || other.fypRecordId == fypRecordId)&&(identical(other.canvasVersion, canvasVersion) || other.canvasVersion == canvasVersion)&&const DeepCollectionEquality().equals(other._blocks, _blocks)&&(identical(other.isLatest, isLatest) || other.isLatest == isLatest)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fypRecordId,canvasVersion,const DeepCollectionEquality().hash(_blocks),isLatest,createdAt,updatedAt);

@override
String toString() {
  return 'FypLeanCanvas(id: $id, fypRecordId: $fypRecordId, canvasVersion: $canvasVersion, blocks: $blocks, isLatest: $isLatest, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$FypLeanCanvasCopyWith<$Res> implements $FypLeanCanvasCopyWith<$Res> {
  factory _$FypLeanCanvasCopyWith(_FypLeanCanvas value, $Res Function(_FypLeanCanvas) _then) = __$FypLeanCanvasCopyWithImpl;
@override @useResult
$Res call({
 String id, String fypRecordId, int canvasVersion, Map<String, dynamic> blocks, bool isLatest, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$FypLeanCanvasCopyWithImpl<$Res>
    implements _$FypLeanCanvasCopyWith<$Res> {
  __$FypLeanCanvasCopyWithImpl(this._self, this._then);

  final _FypLeanCanvas _self;
  final $Res Function(_FypLeanCanvas) _then;

/// Create a copy of FypLeanCanvas
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fypRecordId = null,Object? canvasVersion = null,Object? blocks = null,Object? isLatest = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_FypLeanCanvas(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fypRecordId: null == fypRecordId ? _self.fypRecordId : fypRecordId // ignore: cast_nullable_to_non_nullable
as String,canvasVersion: null == canvasVersion ? _self.canvasVersion : canvasVersion // ignore: cast_nullable_to_non_nullable
as int,blocks: null == blocks ? _self._blocks : blocks // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,isLatest: null == isLatest ? _self.isLatest : isLatest // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
