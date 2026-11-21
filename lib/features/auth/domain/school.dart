import 'package:freezed_annotation/freezed_annotation.dart';

part 'school.freezed.dart';
part 'school.g.dart';

/// A school as returned by the public WebUntis school search.
@freezed
abstract class School with _$School {
  const factory School({
    required String server,
    required String loginName,
    required String displayName,
    @Default('') String address,
  }) = _School;

  factory School.fromJson(Map<String, dynamic> json) => _$SchoolFromJson(json);
}
