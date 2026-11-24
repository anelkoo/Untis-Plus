import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'app.dart';
import 'core/settings.dart';
import 'features/background/background_refresh.dart';
import 'features/notifications/change_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initNotifications().catchError((Object _) {});
  unawaited(scheduleBackgroundRefresh());
  await loadSettings();
  runApp(const ProviderScope(child: UntisPlusApp()));
}
