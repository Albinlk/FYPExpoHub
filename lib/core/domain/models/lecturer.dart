import 'package:freezed_annotation/freezed_annotation.dart';

part 'lecturer.freezed.dart';
part 'lecturer.g.dart';

@freezed
abstract class Lecturer with _$Lecturer {
  const factory Lecturer({
    required String id,
    required String uid,
    required String displayName,
    String? email,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Lecturer;

  factory Lecturer.fromJson(Map<String, dynamic> json) => _$LecturerFromJson(json);
}
