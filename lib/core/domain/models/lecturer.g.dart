// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lecturer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Lecturer _$LecturerFromJson(Map<String, dynamic> json) => _Lecturer(
  id: json['id'] as String,
  uid: json['uid'] as String,
  displayName: json['displayName'] as String,
  email: json['email'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$LecturerToJson(_Lecturer instance) => <String, dynamic>{
  'id': instance.id,
  'uid': instance.uid,
  'displayName': instance.displayName,
  'email': instance.email,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
