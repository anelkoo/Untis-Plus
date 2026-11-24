import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In de, this message translates to:
  /// **'Untis+'**
  String get appTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Melde dich mit deinem WebUntis-Konto an.'**
  String get loginSubtitle;

  /// No description provided for @schoolLabel.
  ///
  /// In de, this message translates to:
  /// **'Schule'**
  String get schoolLabel;

  /// No description provided for @schoolHint.
  ///
  /// In de, this message translates to:
  /// **'Name oder Ort der Schule'**
  String get schoolHint;

  /// No description provided for @schoolChange.
  ///
  /// In de, this message translates to:
  /// **'Ändern'**
  String get schoolChange;

  /// No description provided for @schoolTooManyResults.
  ///
  /// In de, this message translates to:
  /// **'Zu viele Treffer. Gib mehr vom Namen ein.'**
  String get schoolTooManyResults;

  /// No description provided for @schoolNoResults.
  ///
  /// In de, this message translates to:
  /// **'Keine Schule gefunden.'**
  String get schoolNoResults;

  /// No description provided for @usernameLabel.
  ///
  /// In de, this message translates to:
  /// **'Benutzername'**
  String get usernameLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In de, this message translates to:
  /// **'Passwort'**
  String get passwordLabel;

  /// No description provided for @showPassword.
  ///
  /// In de, this message translates to:
  /// **'Passwort anzeigen'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In de, this message translates to:
  /// **'Passwort verbergen'**
  String get hidePassword;

  /// No description provided for @rememberMe.
  ///
  /// In de, this message translates to:
  /// **'Angemeldet bleiben'**
  String get rememberMe;

  /// No description provided for @signIn.
  ///
  /// In de, this message translates to:
  /// **'Anmelden'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In de, this message translates to:
  /// **'Abmelden'**
  String get signOut;

  /// No description provided for @signedInAs.
  ///
  /// In de, this message translates to:
  /// **'Angemeldet als {user}'**
  String signedInAs(String user);

  /// No description provided for @lastUpdated.
  ///
  /// In de, this message translates to:
  /// **'Stand {time}'**
  String lastUpdated(String time);

  /// No description provided for @noLessons.
  ///
  /// In de, this message translates to:
  /// **'Diese Woche keine Stunden.'**
  String get noLessons;

  /// No description provided for @previousWeek.
  ///
  /// In de, this message translates to:
  /// **'Vorige Woche'**
  String get previousWeek;

  /// No description provided for @nextWeek.
  ///
  /// In de, this message translates to:
  /// **'Nächste Woche'**
  String get nextWeek;

  /// No description provided for @viewDay.
  ///
  /// In de, this message translates to:
  /// **'Tag'**
  String get viewDay;

  /// No description provided for @viewWeek.
  ///
  /// In de, this message translates to:
  /// **'Woche'**
  String get viewWeek;

  /// No description provided for @nowLabel.
  ///
  /// In de, this message translates to:
  /// **'Jetzt'**
  String get nowLabel;

  /// No description provided for @nextLabel.
  ///
  /// In de, this message translates to:
  /// **'Danach'**
  String get nextLabel;

  /// No description provided for @noLessonsDay.
  ///
  /// In de, this message translates to:
  /// **'Kein Unterricht'**
  String get noLessonsDay;

  /// No description provided for @teachersLabel.
  ///
  /// In de, this message translates to:
  /// **'Lehrer'**
  String get teachersLabel;

  /// No description provided for @roomsLabel.
  ///
  /// In de, this message translates to:
  /// **'Raum'**
  String get roomsLabel;

  /// No description provided for @classesLabel.
  ///
  /// In de, this message translates to:
  /// **'Klasse'**
  String get classesLabel;

  /// No description provided for @previousDay.
  ///
  /// In de, this message translates to:
  /// **'Voriger Tag'**
  String get previousDay;

  /// No description provided for @nextDay.
  ///
  /// In de, this message translates to:
  /// **'Nächster Tag'**
  String get nextDay;

  /// No description provided for @untilTime.
  ///
  /// In de, this message translates to:
  /// **'bis {time}'**
  String untilTime(String time);

  /// No description provided for @insteadOf.
  ///
  /// In de, this message translates to:
  /// **'statt {name}'**
  String insteadOf(String name);

  /// No description provided for @teacherSearch.
  ///
  /// In de, this message translates to:
  /// **'Lehrer suchen'**
  String get teacherSearch;

  /// No description provided for @teacherSearchHint.
  ///
  /// In de, this message translates to:
  /// **'Name oder Kürzel'**
  String get teacherSearchHint;

  /// No description provided for @myTimetable.
  ///
  /// In de, this message translates to:
  /// **'Mein Stundenplan'**
  String get myTimetable;

  /// No description provided for @addFavourite.
  ///
  /// In de, this message translates to:
  /// **'Zu Favoriten'**
  String get addFavourite;

  /// No description provided for @removeFavourite.
  ///
  /// In de, this message translates to:
  /// **'Aus Favoriten entfernen'**
  String get removeFavourite;

  /// No description provided for @loadingClasses.
  ///
  /// In de, this message translates to:
  /// **'Lade alle Klassen-Stundenpläne. Das dauert pro Woche beim ersten Mal kurz.'**
  String get loadingClasses;

  /// No description provided for @noTeachersFound.
  ///
  /// In de, this message translates to:
  /// **'Keine Lehrkraft gefunden.'**
  String get noTeachersFound;

  /// No description provided for @favouritesLabel.
  ///
  /// In de, this message translates to:
  /// **'Favoriten'**
  String get favouritesLabel;

  /// No description provided for @allTeachersLabel.
  ///
  /// In de, this message translates to:
  /// **'Alle Lehrkräfte'**
  String get allTeachersLabel;

  /// No description provided for @roomSearch.
  ///
  /// In de, this message translates to:
  /// **'Raum suchen'**
  String get roomSearch;

  /// No description provided for @roomSearchHint.
  ///
  /// In de, this message translates to:
  /// **'Raumname'**
  String get roomSearchHint;

  /// No description provided for @noRoomsFound.
  ///
  /// In de, this message translates to:
  /// **'Kein Raum gefunden.'**
  String get noRoomsFound;

  /// No description provided for @allRoomsLabel.
  ///
  /// In de, this message translates to:
  /// **'Alle Räume'**
  String get allRoomsLabel;

  /// No description provided for @absencesTitle.
  ///
  /// In de, this message translates to:
  /// **'Fehlstunden'**
  String get absencesTitle;

  /// No description provided for @absencesSummary.
  ///
  /// In de, this message translates to:
  /// **'{lessons} Fehlstunden, davon {unexcused} nicht entschuldigt'**
  String absencesSummary(int lessons, int unexcused);

  /// No description provided for @absencesCount.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Abwesenheit} other{{count} Abwesenheiten}}'**
  String absencesCount(int count);

  /// No description provided for @absenceLessons.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Stunde} other{{count} Stunden}}'**
  String absenceLessons(int count);

  /// No description provided for @absencesNone.
  ///
  /// In de, this message translates to:
  /// **'Keine Fehlstunden in diesem Schuljahr.'**
  String get absencesNone;

  /// No description provided for @absenceExcused.
  ///
  /// In de, this message translates to:
  /// **'Entschuldigt'**
  String get absenceExcused;

  /// No description provided for @absenceNotExcused.
  ///
  /// In de, this message translates to:
  /// **'Nicht entschuldigt'**
  String get absenceNotExcused;

  /// No description provided for @changesTitle.
  ///
  /// In de, this message translates to:
  /// **'Stundenplan geändert'**
  String get changesTitle;

  /// No description provided for @changeCancelled.
  ///
  /// In de, this message translates to:
  /// **'{lesson}: entfällt'**
  String changeCancelled(String lesson);

  /// No description provided for @changeSubstitution.
  ///
  /// In de, this message translates to:
  /// **'{lesson}: Vertretung {teacher}'**
  String changeSubstitution(String lesson, String teacher);

  /// No description provided for @changeRoom.
  ///
  /// In de, this message translates to:
  /// **'{lesson}: jetzt in {room}'**
  String changeRoom(String lesson, String room);

  /// No description provided for @changeExam.
  ///
  /// In de, this message translates to:
  /// **'{lesson}: Prüfung'**
  String changeExam(String lesson);

  /// No description provided for @changeAdded.
  ///
  /// In de, this message translates to:
  /// **'{lesson}: zusätzlich'**
  String changeAdded(String lesson);

  /// No description provided for @changesMore.
  ///
  /// In de, this message translates to:
  /// **'+{count} weitere'**
  String changesMore(int count);

  /// No description provided for @changesChannel.
  ///
  /// In de, this message translates to:
  /// **'Stundenplan-Änderungen'**
  String get changesChannel;

  /// No description provided for @moreOptions.
  ///
  /// In de, this message translates to:
  /// **'Weitere Optionen'**
  String get moreOptions;

  /// No description provided for @lookSameColor.
  ///
  /// In de, this message translates to:
  /// **'Einfaches Design (alle Stunden in einer Farbe)'**
  String get lookSameColor;

  /// No description provided for @lookModern.
  ///
  /// In de, this message translates to:
  /// **'Modernes Design für Stunden (Streifen statt Farbfläche)'**
  String get lookModern;

  /// No description provided for @widgetNoLessons.
  ///
  /// In de, this message translates to:
  /// **'Keine Stunden in den nächsten Tagen'**
  String get widgetNoLessons;

  /// No description provided for @exportCalendar.
  ///
  /// In de, this message translates to:
  /// **'In Kalender exportieren'**
  String get exportCalendar;

  /// No description provided for @exportSaved.
  ///
  /// In de, this message translates to:
  /// **'Gespeichert: {path}'**
  String exportSaved(String path);

  /// No description provided for @exportFailed.
  ///
  /// In de, this message translates to:
  /// **'Export fehlgeschlagen: {error}'**
  String exportFailed(String error);

  /// No description provided for @retry.
  ///
  /// In de, this message translates to:
  /// **'Nochmal versuchen'**
  String get retry;

  /// No description provided for @statusCancelled.
  ///
  /// In de, this message translates to:
  /// **'Entfällt'**
  String get statusCancelled;

  /// No description provided for @statusSubstitution.
  ///
  /// In de, this message translates to:
  /// **'Vertretung'**
  String get statusSubstitution;

  /// No description provided for @statusIrregular.
  ///
  /// In de, this message translates to:
  /// **'Geändert'**
  String get statusIrregular;

  /// No description provided for @statusRoomChange.
  ///
  /// In de, this message translates to:
  /// **'Raumänderung'**
  String get statusRoomChange;

  /// No description provided for @settings.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get settings;

  /// No description provided for @settingsLook.
  ///
  /// In de, this message translates to:
  /// **'Darstellung'**
  String get settingsLook;

  /// No description provided for @settingsColors.
  ///
  /// In de, this message translates to:
  /// **'Farben'**
  String get settingsColors;

  /// No description provided for @settingsLessonColors.
  ///
  /// In de, this message translates to:
  /// **'Stunden'**
  String get settingsLessonColors;

  /// No description provided for @colorAccent.
  ///
  /// In de, this message translates to:
  /// **'Akzentfarbe der App'**
  String get colorAccent;

  /// No description provided for @colorExam.
  ///
  /// In de, this message translates to:
  /// **'Prüfung'**
  String get colorExam;

  /// No description provided for @colorSubstitution.
  ///
  /// In de, this message translates to:
  /// **'Vertretung (Lehrer oder Fach)'**
  String get colorSubstitution;

  /// No description provided for @colorRoomChange.
  ///
  /// In de, this message translates to:
  /// **'Raumänderung'**
  String get colorRoomChange;

  /// No description provided for @colorCancelled.
  ///
  /// In de, this message translates to:
  /// **'Entfall'**
  String get colorCancelled;

  /// No description provided for @colorIrregular.
  ///
  /// In de, this message translates to:
  /// **'Geändert'**
  String get colorIrregular;

  /// No description provided for @colorHoliday.
  ///
  /// In de, this message translates to:
  /// **'Ferien'**
  String get colorHoliday;

  /// No description provided for @colorDefault.
  ///
  /// In de, this message translates to:
  /// **'Standard'**
  String get colorDefault;

  /// No description provided for @colorSample.
  ///
  /// In de, this message translates to:
  /// **'Beispiel'**
  String get colorSample;

  /// No description provided for @colorHue.
  ///
  /// In de, this message translates to:
  /// **'Farbton'**
  String get colorHue;

  /// No description provided for @colorSaturation.
  ///
  /// In de, this message translates to:
  /// **'Sättigung'**
  String get colorSaturation;

  /// No description provided for @colorBrightness.
  ///
  /// In de, this message translates to:
  /// **'Helligkeit'**
  String get colorBrightness;

  /// No description provided for @colorDone.
  ///
  /// In de, this message translates to:
  /// **'Fertig'**
  String get colorDone;

  /// No description provided for @statusExam.
  ///
  /// In de, this message translates to:
  /// **'Prüfung'**
  String get statusExam;

  /// No description provided for @navTimetable.
  ///
  /// In de, this message translates to:
  /// **'Stundenplan'**
  String get navTimetable;

  /// No description provided for @navHomework.
  ///
  /// In de, this message translates to:
  /// **'Hausübung'**
  String get navHomework;

  /// No description provided for @navTests.
  ///
  /// In de, this message translates to:
  /// **'Tests'**
  String get navTests;

  /// No description provided for @navMore.
  ///
  /// In de, this message translates to:
  /// **'Mehr'**
  String get navMore;

  /// No description provided for @homeworkNone.
  ///
  /// In de, this message translates to:
  /// **'Keine Hausübung in Sicht.'**
  String get homeworkNone;

  /// No description provided for @homeworkOverdue.
  ///
  /// In de, this message translates to:
  /// **'Überfällig'**
  String get homeworkOverdue;

  /// No description provided for @homeworkToday.
  ///
  /// In de, this message translates to:
  /// **'Heute'**
  String get homeworkToday;

  /// No description provided for @homeworkTomorrow.
  ///
  /// In de, this message translates to:
  /// **'Morgen'**
  String get homeworkTomorrow;

  /// No description provided for @homeworkWeek.
  ///
  /// In de, this message translates to:
  /// **'Diese Woche'**
  String get homeworkWeek;

  /// No description provided for @homeworkLater.
  ///
  /// In de, this message translates to:
  /// **'Später'**
  String get homeworkLater;

  /// No description provided for @homeworkDone.
  ///
  /// In de, this message translates to:
  /// **'Erledigt'**
  String get homeworkDone;

  /// No description provided for @testsNone.
  ///
  /// In de, this message translates to:
  /// **'Keine Tests in Sicht.'**
  String get testsNone;

  /// No description provided for @errorNetwork.
  ///
  /// In de, this message translates to:
  /// **'Keine Verbindung zu WebUntis. Prüfe deine Internetverbindung.'**
  String get errorNetwork;

  /// No description provided for @errorWrongCredentials.
  ///
  /// In de, this message translates to:
  /// **'Benutzername oder Passwort ist falsch.'**
  String get errorWrongCredentials;

  /// No description provided for @errorAuthExpired.
  ///
  /// In de, this message translates to:
  /// **'Deine Sitzung ist abgelaufen. Melde dich neu an.'**
  String get errorAuthExpired;

  /// No description provided for @errorSchoolNotFound.
  ///
  /// In de, this message translates to:
  /// **'WebUntis kennt diese Schule nicht mehr. Such sie neu.'**
  String get errorSchoolNotFound;

  /// No description provided for @errorNoPermission.
  ///
  /// In de, this message translates to:
  /// **'Deine Schule gibt diese Daten nicht frei.'**
  String get errorNoPermission;

  /// No description provided for @errorServer.
  ///
  /// In de, this message translates to:
  /// **'WebUntis meldet einen Fehler: {message}'**
  String errorServer(String message);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
