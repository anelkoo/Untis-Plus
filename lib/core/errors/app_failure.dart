import 'package:dio/dio.dart';

/// Every error the app shows to the user. Messages never contain credentials.
sealed class AppFailure implements Exception {
  const AppFailure();

  /// Maps a JSON-RPC error object from WebUntis to a typed failure.
  factory AppFailure.fromRpc(int code, String message) => switch (code) {
        -8504 => const WrongCredentialsFailure(),
        -8520 => const AuthExpiredFailure(),
        -8500 => const SchoolNotFoundFailure(),
        -8509 => const NoPermissionFailure(),
        -6003 => const TooManySchoolsFailure(),
        _ => ServerFailure(code, message),
      };

  factory AppFailure.fromDio(DioException e) => switch (e.type) {
        .badResponse => ServerFailure(e.response?.statusCode, 'HTTP ${e.response?.statusCode}'),
        .cancel => ServerFailure(null, 'cancelled'),
        _ => const NetworkFailure(),
      };
}

class NetworkFailure extends AppFailure {
  const NetworkFailure();
}

class WrongCredentialsFailure extends AppFailure {
  const WrongCredentialsFailure();
}

class AuthExpiredFailure extends AppFailure {
  const AuthExpiredFailure();
}

class SchoolNotFoundFailure extends AppFailure {
  const SchoolNotFoundFailure();
}

class TooManySchoolsFailure extends AppFailure {
  const TooManySchoolsFailure();
}

class NoPermissionFailure extends AppFailure {
  const NoPermissionFailure();
}

class ServerFailure extends AppFailure {
  const ServerFailure(this.code, this.message);
  final int? code;
  final String message;

  @override
  String toString() => 'ServerFailure($code, $message)';
}
