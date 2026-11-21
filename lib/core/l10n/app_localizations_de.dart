// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Untis+';

  @override
  String get loginSubtitle => 'Melde dich mit deinem WebUntis-Konto an.';

  @override
  String get schoolLabel => 'Schule';

  @override
  String get schoolHint => 'Name oder Ort der Schule';

  @override
  String get schoolChange => 'Ändern';

  @override
  String get schoolTooManyResults =>
      'Zu viele Treffer. Gib mehr vom Namen ein.';

  @override
  String get schoolNoResults => 'Keine Schule gefunden.';

  @override
  String get usernameLabel => 'Benutzername';

  @override
  String get passwordLabel => 'Passwort';

  @override
  String get showPassword => 'Passwort anzeigen';

  @override
  String get hidePassword => 'Passwort verbergen';

  @override
  String get rememberMe => 'Angemeldet bleiben';

  @override
  String get signIn => 'Anmelden';

  @override
  String get signOut => 'Abmelden';

  @override
  String signedInAs(String user) {
    return 'Angemeldet als $user';
  }

  @override
  String lastUpdated(String time) {
    return 'Stand $time';
  }

  @override
  String get noLessons => 'Diese Woche keine Stunden.';

  @override
  String get retry => 'Nochmal versuchen';

  @override
  String get statusCancelled => 'Entfällt';

  @override
  String get statusSubstitution => 'Vertretung';

  @override
  String get statusIrregular => 'Geändert';

  @override
  String get statusExam => 'Prüfung';

  @override
  String get errorNetwork =>
      'Keine Verbindung zu WebUntis. Prüfe deine Internetverbindung.';

  @override
  String get errorWrongCredentials => 'Benutzername oder Passwort ist falsch.';

  @override
  String get errorAuthExpired =>
      'Deine Sitzung ist abgelaufen. Melde dich neu an.';

  @override
  String get errorSchoolNotFound =>
      'WebUntis kennt diese Schule nicht mehr. Such sie neu.';

  @override
  String get errorNoPermission => 'Deine Schule gibt diese Daten nicht frei.';

  @override
  String errorServer(String message) {
    return 'WebUntis meldet einen Fehler: $message';
  }
}
