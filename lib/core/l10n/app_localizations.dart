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
