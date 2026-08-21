// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fyp_audit_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FypAuditLog {

 String get id; String? get actorUid; String? get actorRole; String get action; String get targetType; String? get targetId; Map<String, dynamic> get metadataSafe; String get source; DateTime get createdAt;
/// Create a copy of FypAuditLog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FypAuditLogCopyWith<FypAuditLog> get copyWith => _$FypAuditLogCopyWithImpl<FypAuditLog>(this as FypAuditLog, _$identity);

  /// Serializes this FypAuditLog to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FypAuditLog&&(identical(other.id, id) || other.id == id)&&(identical(other.actorUid, actorUid) || other.actorUid == actorUid)&&(identical(other.actorRole, actorRole) || other.actorRole == actorRole)&&(identical(other.action, action) || other.action == action)&&(identical(other.targetType, targetType) || other.targetType == targetType)&&(identical(other.targetId, targetId) || other.targetId == targetId)&&const DeepCollectionEquality().equals(other.metadataSafe, metadataSafe)&&(identical(other.source, source) || other.source == source)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,actorUid,actorRole,action,targetType,targetId,const DeepCollectionEquality().hash(metadataSafe),source,createdAt);

@override
String toString() {
  return 'FypAuditLog(id: $id, actorUid: $actorUid, actorRole: $actorRole, action: $action, targetType: $targetType, targetId: $targetId, metadataSafe: $metadataSafe, source: $source, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $FypAuditLogCopyWith<$Res>  {
  factory $FypAuditLogCopyWith(FypAuditLog value, $Res Function(FypAuditLog) _then) = _$FypAuditLogCopyWithImpl;
@useResult
$Res call({
 String id, String? actorUid, String? actorRole, String action, String targetType, String? targetId, Map<String, dynamic> metadataSafe, String source, DateTime createdAt
});




}
/// @nodoc
class _$FypAuditLogCopyWithImpl<$Res>
    implements $FypAuditLogCopyWith<$Res> {
  _$FypAuditLogCopyWithImpl(this._self, this._then);

  final FypAuditLog _self;
  final $Res Function(FypAuditLog) _then;

/// Create a copy of FypAuditLog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? actorUid = freezed,Object? actorRole = freezed,Object? action = null,Object? targetType = null,Object? targetId = freezed,Object? metadataSafe = null,Object? source = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,actorUid: freezed == actorUid ? _self.actorUid : actorUid // ignore: cast_nullable_to_non_nullable
as String?,actorRole: freezed == actorRole ? _self.actorRole : actorRole // ignore: cast_nullable_to_non_nullable
as String?,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,targetType: null == targetType ? _self.targetType : targetType // ignore: cast_nullable_to_non_nullable
as String,targetId: freezed == targetId ? _self.targetId : targetId // ignore: cast_nullable_to_non_nullable
as String?,metadataSafe: null == metadataSafe ? _self.metadataSafe : metadataSafe // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [FypAuditLog].
extension FypAuditLogPatterns on FypAuditLog {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FypAuditLog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FypAuditLog() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FypAuditLog value)  $default,){
final _that = this;
switch (_that) {
case _FypAuditLog():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FypAuditLog value)?  $default,){
final _that = this;
switch (_that) {
case _FypAuditLog() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? actorUid,  String? actorRole,  String action,  String targetType,  String? targetId,  Map<String, dynamic> metadataSafe,  String source,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FypAuditLog() when $default != null:
return $default(_that.id,_that.actorUid,_that.actorRole,_that.action,_that.targetType,_that.targetId,_that.metadataSafe,_that.source,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? actorUid,  String? actorRole,  String action,  String targetType,  String? targetId,  Map<String, dynamic> metadataSafe,  String source,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _FypAuditLog():
return $default(_that.id,_that.actorUid,_that.actorRole,_that.action,_that.targetType,_that.targetId,_that.metadataSafe,_that.source,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? actorUid,  String? actorRole,  String action,  String targetType,  String? targetId,  Map<String, dynamic> metadataSafe,  String source,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _FypAuditLog() when $default != null:
return $default(_that.id,_that.actorUid,_that.actorRole,_that.action,_that.targetType,_that.targetId,_that.metadataSafe,_that.source,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FypAuditLog implements FypAuditLog {
  const _FypAuditLog({required this.id, this.actorUid, this.actorRole, required this.action, required this.targetType, this.targetId, required final  Map<String, dynamic> metadataSafe, required this.source, required this.createdAt}): _metadataSafe = metadataSafe;
  factory _FypAuditLog.fromJson(Map<String, dynamic> json) => _$FypAuditLogFromJson(json);

@override final  String id;
@override final  String? actorUid;
@override final  String? actorRole;
@override final  String action;
@override final  String targetType;
@override final  String? targetId;
 final  Map<String, dynamic> _metadataSafe;
@override Map<String, dynamic> get metadataSafe {
  if (_metadataSafe is EqualUnmodifiableMapView) return _metadataSafe;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadataSafe);
}

@override final  String source;
@override final  DateTime createdAt;

/// Create a copy of FypAuditLog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FypAuditLogCopyWith<_FypAuditLog> get copyWith => __$FypAuditLogCopyWithImpl<_FypAuditLog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FypAuditLogToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FypAuditLog&&(identical(other.id, id) || other.id == id)&&(identical(other.actorUid, actorUid) || other.actorUid == actorUid)&&(identical(other.actorRole, actorRole) || other.actorRole == actorRole)&&(identical(other.action, action) || other.action == action)&&(identical(other.targetType, targetType) || other.targetType == targetType)&&(identical(other.targetId, targetId) || other.targetId == targetId)&&const DeepCollectionEquality().equals(other._metadataSafe, _metadataSafe)&&(identical(other.source, source) || other.source == source)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,actorUid,actorRole,action,targetType,targetId,const DeepCollectionEquality().hash(_metadataSafe),source,createdAt);

@override
String toString() {
  return 'FypAuditLog(id: $id, actorUid: $actorUid, actorRole: $actorRole, action: $action, targetType: $targetType, targetId: $targetId, metadataSafe: $metadataSafe, source: $source, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$FypAuditLogCopyWith<$Res> implements $FypAuditLogCopyWith<$Res> {
  factory _$FypAuditLogCopyWith(_FypAuditLog value, $Res Function(_FypAuditLog) _then) = __$FypAuditLogCopyWithImpl;
@override @useResult
$Res call({
 String id, String? actorUid, String? actorRole, String action, String targetType, String? targetId, Map<String, dynamic> metadataSafe, String source, DateTime createdAt
});




}
/// @nodoc
class __$FypAuditLogCopyWithImpl<$Res>
    implements _$FypAuditLogCopyWith<$Res> {
  __$FypAuditLogCopyWithImpl(this._self, this._then);

  final _FypAuditLog _self;
  final $Res Function(_FypAuditLog) _then;

/// Create a copy of FypAuditLog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? actorUid = freezed,Object? actorRole = freezed,Object? action = null,Object? targetType = null,Object? targetId = freezed,Object? metadataSafe = null,Object? source = null,Object? createdAt = null,}) {
  return _then(_FypAuditLog(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,actorUid: freezed == actorUid ? _self.actorUid : actorUid // ignore: cast_nullable_to_non_nullable
as String?,actorRole: freezed == actorRole ? _self.actorRole : actorRole // ignore: cast_nullable_to_non_nullable
as String?,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,targetType: null == targetType ? _self.targetType : targetType // ignore: cast_nullable_to_non_nullable
as String,targetId: freezed == targetId ? _self.targetId : targetId // ignore: cast_nullable_to_non_nullable
as String?,metadataSafe: null == metadataSafe ? _self._metadataSafe : metadataSafe // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
