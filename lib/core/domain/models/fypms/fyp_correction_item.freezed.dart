// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fyp_correction_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FypCorrectionItem {

 String get id; String get fypRecordId; String? get itemCode; String get description; String get severity;// 'minor', 'major'
 String get status;// 'open', 'in_progress', 'evidence_submitted', 'confirmed', 'closed'
 String? get createdBy; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of FypCorrectionItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FypCorrectionItemCopyWith<FypCorrectionItem> get copyWith => _$FypCorrectionItemCopyWithImpl<FypCorrectionItem>(this as FypCorrectionItem, _$identity);

  /// Serializes this FypCorrectionItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FypCorrectionItem&&(identical(other.id, id) || other.id == id)&&(identical(other.fypRecordId, fypRecordId) || other.fypRecordId == fypRecordId)&&(identical(other.itemCode, itemCode) || other.itemCode == itemCode)&&(identical(other.description, description) || other.description == description)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fypRecordId,itemCode,description,severity,status,createdBy,createdAt,updatedAt);

@override
String toString() {
  return 'FypCorrectionItem(id: $id, fypRecordId: $fypRecordId, itemCode: $itemCode, description: $description, severity: $severity, status: $status, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $FypCorrectionItemCopyWith<$Res>  {
  factory $FypCorrectionItemCopyWith(FypCorrectionItem value, $Res Function(FypCorrectionItem) _then) = _$FypCorrectionItemCopyWithImpl;
@useResult
$Res call({
 String id, String fypRecordId, String? itemCode, String description, String severity, String status, String? createdBy, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$FypCorrectionItemCopyWithImpl<$Res>
    implements $FypCorrectionItemCopyWith<$Res> {
  _$FypCorrectionItemCopyWithImpl(this._self, this._then);

  final FypCorrectionItem _self;
  final $Res Function(FypCorrectionItem) _then;

/// Create a copy of FypCorrectionItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fypRecordId = null,Object? itemCode = freezed,Object? description = null,Object? severity = null,Object? status = null,Object? createdBy = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fypRecordId: null == fypRecordId ? _self.fypRecordId : fypRecordId // ignore: cast_nullable_to_non_nullable
as String,itemCode: freezed == itemCode ? _self.itemCode : itemCode // ignore: cast_nullable_to_non_nullable
as String?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [FypCorrectionItem].
extension FypCorrectionItemPatterns on FypCorrectionItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FypCorrectionItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FypCorrectionItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FypCorrectionItem value)  $default,){
final _that = this;
switch (_that) {
case _FypCorrectionItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FypCorrectionItem value)?  $default,){
final _that = this;
switch (_that) {
case _FypCorrectionItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fypRecordId,  String? itemCode,  String description,  String severity,  String status,  String? createdBy,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FypCorrectionItem() when $default != null:
return $default(_that.id,_that.fypRecordId,_that.itemCode,_that.description,_that.severity,_that.status,_that.createdBy,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fypRecordId,  String? itemCode,  String description,  String severity,  String status,  String? createdBy,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _FypCorrectionItem():
return $default(_that.id,_that.fypRecordId,_that.itemCode,_that.description,_that.severity,_that.status,_that.createdBy,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fypRecordId,  String? itemCode,  String description,  String severity,  String status,  String? createdBy,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _FypCorrectionItem() when $default != null:
return $default(_that.id,_that.fypRecordId,_that.itemCode,_that.description,_that.severity,_that.status,_that.createdBy,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FypCorrectionItem implements FypCorrectionItem {
  const _FypCorrectionItem({required this.id, required this.fypRecordId, this.itemCode, required this.description, required this.severity, required this.status, this.createdBy, required this.createdAt, required this.updatedAt});
  factory _FypCorrectionItem.fromJson(Map<String, dynamic> json) => _$FypCorrectionItemFromJson(json);

@override final  String id;
@override final  String fypRecordId;
@override final  String? itemCode;
@override final  String description;
@override final  String severity;
// 'minor', 'major'
@override final  String status;
// 'open', 'in_progress', 'evidence_submitted', 'confirmed', 'closed'
@override final  String? createdBy;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of FypCorrectionItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FypCorrectionItemCopyWith<_FypCorrectionItem> get copyWith => __$FypCorrectionItemCopyWithImpl<_FypCorrectionItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FypCorrectionItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FypCorrectionItem&&(identical(other.id, id) || other.id == id)&&(identical(other.fypRecordId, fypRecordId) || other.fypRecordId == fypRecordId)&&(identical(other.itemCode, itemCode) || other.itemCode == itemCode)&&(identical(other.description, description) || other.description == description)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fypRecordId,itemCode,description,severity,status,createdBy,createdAt,updatedAt);

@override
String toString() {
  return 'FypCorrectionItem(id: $id, fypRecordId: $fypRecordId, itemCode: $itemCode, description: $description, severity: $severity, status: $status, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$FypCorrectionItemCopyWith<$Res> implements $FypCorrectionItemCopyWith<$Res> {
  factory _$FypCorrectionItemCopyWith(_FypCorrectionItem value, $Res Function(_FypCorrectionItem) _then) = __$FypCorrectionItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String fypRecordId, String? itemCode, String description, String severity, String status, String? createdBy, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$FypCorrectionItemCopyWithImpl<$Res>
    implements _$FypCorrectionItemCopyWith<$Res> {
  __$FypCorrectionItemCopyWithImpl(this._self, this._then);

  final _FypCorrectionItem _self;
  final $Res Function(_FypCorrectionItem) _then;

/// Create a copy of FypCorrectionItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fypRecordId = null,Object? itemCode = freezed,Object? description = null,Object? severity = null,Object? status = null,Object? createdBy = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_FypCorrectionItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fypRecordId: null == fypRecordId ? _self.fypRecordId : fypRecordId // ignore: cast_nullable_to_non_nullable
as String,itemCode: freezed == itemCode ? _self.itemCode : itemCode // ignore: cast_nullable_to_non_nullable
as String?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
