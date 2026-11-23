import 'dart:io';

import 'package:workmanager/workmanager.dart';

import '../../core/db/app_database.dart';
import '../../core/network/dio_factory.dart';
import '../../core/network/webuntis_client.dart';
import '../auth/data/credentials_store.dart';
import '../notifications/change_notifier.dart';
import '../timetable/data/timetable_repository.dart';
import '../widgets/widget_bridge.dart';

const _task = 'at.anelkoo.untis_plus.refresh';

/// Background refresh while the app is closed. Every 2 hours on Android to save battery; on
/// iOS 15 minutes is only the earliest, iOS decides on its own and usually runs far less often.
Duration get backgroundInterval => Platform.isAndroid ? const Duration(hours: 2) : const Duration(minutes: 15);

/// Refresh while the desktop app is open (desktop has no background jobs).
const desktopInterval = Duration(minutes: 15);

/// Refreshes my timetable for the weeks that matter now: this week and, from Friday on,
/// next week. Each week is skipped if it was fetched less than [minAge] ago.
Future<void> refreshMine(TimetableRepository repo, {required Duration minAge, DateTime? now}) async {
  final t = now ?? DateTime.now();
  for (final monday in {mondayOf(t), mondayOf(t.add(const Duration(days: 3)))}) {
    await repo.refresh(me, monday, minAge: minAge);
  }
  await repo.refreshExams();
}

@pragma('vm:entry-point')
void backgroundDispatcher() => Workmanager().executeTask((task, _) async {
      final credentials = await CredentialsStore().read();
      if (credentials == null) return true;
      final db = AppDatabase();
      try {
        final repo = TimetableRepository(db, WebUntisClient(createDio(), credentials), onChanges: notifyChanges);
        try {
          await refreshMine(repo, minAge: backgroundInterval);
        } finally {
          // iOS: skipped, the background engine has no app group channel. The iOS widget
          // timeline moves on by itself and gets new data whenever the app opens.
          if (Platform.isAndroid) await publishWidgets(repo);
        }
      } on Object {
        // Offline or the server failed: try again next time.
      } finally {
        await db.close();
      }
      return true;
    });

/// Registers the periodic background refresh on Android and iOS. Desktop apps refresh on a
/// timer while they run instead.
Future<void> scheduleBackgroundRefresh() async {
  if (!Platform.isAndroid && !Platform.isIOS) return;
  try {
    await Workmanager().initialize(backgroundDispatcher);
    await Workmanager().registerPeriodicTask(
      _task,
      _task,
      frequency: backgroundInterval,
      constraints: Constraints(networkType: NetworkType.connected),
      // update, not keep: an install that registered a shorter interval switches to this one.
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
    );
  } on Object {
    // Without background refresh the app still refreshes when opened.
  }
}
