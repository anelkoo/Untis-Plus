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
  String get previousWeek => 'Vorige Woche';

  @override
  String get nextWeek => 'Nächste Woche';

  @override
  String get viewDay => 'Tag';

  @override
  String get viewWeek => 'Woche';

  @override
  String get nowLabel => 'Jetzt';

  @override
  String get nextLabel => 'Danach';

  @override
  String get noLessonsDay => 'Kein Unterricht';

  @override
  String get teachersLabel => 'Lehrer';

  @override
  String get roomsLabel => 'Raum';

  @override
  String get classesLabel => 'Klasse';

  @override
  String get previousDay => 'Voriger Tag';

  @override
  String get nextDay => 'Nächster Tag';

  @override
  String untilTime(String time) {
    return 'bis $time';
  }

  @override
  String insteadOf(String name) {
    return 'statt $name';
  }

  @override
  String get teacherSearch => 'Lehrer suchen';

  @override
  String get teacherSearchHint => 'Name oder Kürzel';

  @override
  String get myTimetable => 'Mein Stundenplan';

  @override
  String get addFavourite => 'Zu Favoriten';

  @override
  String get removeFavourite => 'Aus Favoriten entfernen';

  @override
  String get loadingClasses =>
      'Lade alle Klassen-Stundenpläne. Das dauert pro Woche beim ersten Mal kurz.';

  @override
  String get noTeachersFound => 'Keine Lehrkraft gefunden.';

  @override
  String get favouritesLabel => 'Favoriten';

  @override
  String get allTeachersLabel => 'Alle Lehrkräfte';

  @override
  String get changesTitle => 'Stundenplan geändert';

  @override
  String changeCancelled(String lesson) {
    return '$lesson: entfällt';
  }

  @override
  String changeSubstitution(String lesson, String teacher) {
    return '$lesson: Vertretung $teacher';
  }

  @override
  String changeRoom(String lesson, String room) {
    return '$lesson: jetzt in $room';
  }

  @override
  String changeExam(String lesson) {
    return '$lesson: Prüfung';
  }

  @override
  String changeAdded(String lesson) {
    return '$lesson: zusätzlich';
  }

  @override
  String changesMore(int count) {
    return '+$count weitere';
  }

  @override
  String get changesChannel => 'Stundenplan-Änderungen';

  @override
  String get moreOptions => 'Weitere Optionen';

  @override
  String get testNotification => 'Testbenachrichtigung senden';

  @override
  String get testNotificationSent =>
      'Testbenachrichtigung gesendet. Falls nichts erscheint, prüf die Benachrichtigungs-Einstellungen der App.';

  @override
  String get testNotificationFailed =>
      'Benachrichtigung konnte nicht gesendet werden.';

  @override
  String get widgetNoLessons => 'Keine Stunden in den nächsten Tagen';

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
