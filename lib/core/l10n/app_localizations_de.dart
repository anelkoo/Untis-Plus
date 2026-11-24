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
  String get roomSearch => 'Raum suchen';

  @override
  String get roomSearchHint => 'Raumname';

  @override
  String get noRoomsFound => 'Kein Raum gefunden.';

  @override
  String get allRoomsLabel => 'Alle Räume';

  @override
  String get absencesTitle => 'Fehlstunden';

  @override
  String absencesSummary(int lessons, int unexcused) {
    return '$lessons Fehlstunden, davon $unexcused nicht entschuldigt';
  }

  @override
  String absencesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Abwesenheiten',
      one: '1 Abwesenheit',
    );
    return '$_temp0';
  }

  @override
  String absenceLessons(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Stunden',
      one: '1 Stunde',
    );
    return '$_temp0';
  }

  @override
  String get absencesNone => 'Keine Fehlstunden in diesem Schuljahr.';

  @override
  String get absenceExcused => 'Entschuldigt';

  @override
  String get absenceNotExcused => 'Nicht entschuldigt';

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
  String get lookSameColor => 'Einfaches Design (alle Stunden in einer Farbe)';

  @override
  String get lookModern =>
      'Modernes Design für Stunden (Streifen statt Farbfläche)';

  @override
  String get widgetNoLessons => 'Keine Stunden in den nächsten Tagen';

  @override
  String get exportCalendar => 'In Kalender exportieren';

  @override
  String exportSaved(String path) {
    return 'Gespeichert: $path';
  }

  @override
  String exportFailed(String error) {
    return 'Export fehlgeschlagen: $error';
  }

  @override
  String get retry => 'Nochmal versuchen';

  @override
  String get statusCancelled => 'Entfällt';

  @override
  String get statusSubstitution => 'Vertretung';

  @override
  String get statusIrregular => 'Geändert';

  @override
  String get statusRoomChange => 'Raumänderung';

  @override
  String get settings => 'Einstellungen';

  @override
  String get settingsLook => 'Darstellung';

  @override
  String get settingsColors => 'Farben';

  @override
  String get settingsLessonColors => 'Stunden';

  @override
  String get colorAccent => 'Akzentfarbe der App';

  @override
  String get colorExam => 'Prüfung';

  @override
  String get colorSubstitution => 'Vertretung (Lehrer oder Fach)';

  @override
  String get colorRoomChange => 'Raumänderung';

  @override
  String get colorCancelled => 'Entfall';

  @override
  String get colorIrregular => 'Geändert';

  @override
  String get colorHoliday => 'Ferien';

  @override
  String get colorDefault => 'Standard';

  @override
  String get colorSample => 'Beispiel';

  @override
  String get colorHue => 'Farbton';

  @override
  String get colorSaturation => 'Sättigung';

  @override
  String get colorBrightness => 'Helligkeit';

  @override
  String get colorDone => 'Fertig';

  @override
  String get statusExam => 'Prüfung';

  @override
  String get navTimetable => 'Stundenplan';

  @override
  String get navHomework => 'Hausübung';

  @override
  String get navTests => 'Tests';

  @override
  String get navMore => 'Mehr';

  @override
  String get homeworkNone => 'Keine Hausübung in Sicht.';

  @override
  String get homeworkOverdue => 'Überfällig';

  @override
  String get homeworkToday => 'Heute';

  @override
  String get homeworkTomorrow => 'Morgen';

  @override
  String get homeworkWeek => 'Diese Woche';

  @override
  String get homeworkLater => 'Später';

  @override
  String get homeworkDone => 'Erledigt';

  @override
  String get testsNone => 'Keine Tests in Sicht.';

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
