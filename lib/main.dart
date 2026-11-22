import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'app.dart';
import 'features/background/background_refresh.dart';
import 'features/notifications/change_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initNotifications().catchError((Object _) {});
  unawaited(scheduleBackgroundRefresh());
  runApp(const ProviderScope(child: UntisPlusApp()));
}
