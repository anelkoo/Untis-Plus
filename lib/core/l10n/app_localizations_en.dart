// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Untis+';

  @override
  String get loginSubtitle => 'Sign in with your WebUntis account.';

  @override
  String get schoolLabel => 'School';

  @override
  String get schoolHint => 'School name or city';

  @override
  String get schoolChange => 'Change';

  @override
  String get schoolTooManyResults => 'Too many results. Type more of the name.';

  @override
  String get schoolNoResults => 'No school found.';

  @override
  String get usernameLabel => 'Username';

  @override
  String get passwordLabel => 'Password';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get rememberMe => 'Stay signed in';

  @override
  String get signIn => 'Sign in';

  @override
  String get signOut => 'Sign out';

  @override
  String signedInAs(String user) {
    return 'Signed in as $user';
  }

  @override
  String get errorNetwork =>
      'Can\'t reach WebUntis. Check your internet connection.';

  @override
  String get errorWrongCredentials => 'Wrong username or password.';

  @override
  String get errorAuthExpired => 'Your session expired. Sign in again.';

  @override
  String get errorSchoolNotFound =>
      'WebUntis no longer knows this school. Search for it again.';

  @override
  String get errorNoPermission => 'Your school doesn\'t share this data.';

  @override
  String errorServer(String message) {
    return 'WebUntis reported an error: $message';
  }
}
