import 'dart:ui';

import 'app_localizations.dart';

/// Strings in the device language, for code without a widget tree (background job, widgets).
AppLocalizations deviceLocalizations() =>
    lookupAppLocalizations(Locale(PlatformDispatcher.instance.locale.languageCode == 'de' ? 'de' : 'en'));
