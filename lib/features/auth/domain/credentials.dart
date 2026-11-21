import 'package:freezed_annotation/freezed_annotation.dart';

import 'school.dart';

part 'credentials.freezed.dart';
part 'credentials.g.dart';

/// Login data. toString is not generated, so the password can't end up in a log.
@Freezed(toStringOverride: false)
abstract class Credentials with _$Credentials {
  const factory Credentials({
    required School school,
    required String username,
    required String password,
  }) = _Credentials;

  factory Credentials.fromJson(Map<String, dynamic> json) => _$CredentialsFromJson(json);
}
