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
  String lastUpdated(String time) {
    return 'Updated $time';
  }

  @override
  String get noLessons => 'No lessons this week.';

  @override
  String get previousWeek => 'Previous week';

  @override
  String get nextWeek => 'Next week';

  @override
  String get viewDay => 'Day';

  @override
  String get viewWeek => 'Week';

  @override
  String get nowLabel => 'Now';

  @override
  String get nextLabel => 'Next';

  @override
  String get noLessonsDay => 'No lessons';

  @override
  String get teachersLabel => 'Teacher';

  @override
  String get roomsLabel => 'Room';

  @override
  String get classesLabel => 'Class';

  @override
  String get previousDay => 'Previous day';

  @override
  String get nextDay => 'Next day';

  @override
  String untilTime(String time) {
    return 'until $time';
  }

  @override
  String insteadOf(String name) {
    return 'instead of $name';
  }

  @override
  String get retry => 'Try again';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusSubstitution => 'Substitution';

  @override
  String get statusIrregular => 'Changed';

  @override
  String get statusExam => 'Exam';

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
