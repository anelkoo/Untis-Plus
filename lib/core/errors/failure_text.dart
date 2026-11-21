import '../l10n/app_localizations.dart';
import 'app_failure.dart';

/// User-facing text for any error thrown by the data layer.
String failureText(AppLocalizations l, Object error) => switch (error) {
      NetworkFailure() => l.errorNetwork,
      WrongCredentialsFailure() => l.errorWrongCredentials,
      AuthExpiredFailure() => l.errorAuthExpired,
      SchoolNotFoundFailure() => l.errorSchoolNotFound,
      TooManySchoolsFailure() => l.schoolTooManyResults,
      NoPermissionFailure() => l.errorNoPermission,
      ServerFailure(:final message) => l.errorServer(message),
      _ => l.errorServer('$error'),
    };
