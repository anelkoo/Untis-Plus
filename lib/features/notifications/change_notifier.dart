import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/l10n/device_localizations.dart';
import '../timetable/domain/lesson.dart';
import '../timetable/domain/timetable_diff.dart';

/// One line per change, e.g. "Mo 08:50 AM: entfällt".
String changeText(AppLocalizations l, String locale, LessonChange change) {
  final lesson = change.lesson;
  String names(List<Named> list) => list.map((n) => n.name).join(', ');
  final label = [
    DateFormat.E(locale).format(lesson.start),
    DateFormat.Hm(locale).format(lesson.start),
    if (lesson.subjects.isNotEmpty) names(lesson.subjects) else lesson.lessonText,
  ].where((s) => s.isNotEmpty).join(' ');
  return switch (change.kind) {
    .cancelled => l.changeCancelled(label),
    .substitution => l.changeSubstitution(label, names(lesson.teachers)),
    .roomChanged => l.changeRoom(label, names(lesson.rooms)),
    .exam => l.changeExam(label),
    .added => l.changeAdded(label),
  };
}

/// Notification body: the first few changes, then "+N more".
String changesBody(AppLocalizations l, String locale, List<LessonChange> changes, {int max = 5}) => [
      for (final c in changes.take(max)) changeText(l, locale, c),
      if (changes.length > max) l.changesMore(changes.length - max),
    ].join('\n');

final _plugin = FlutterLocalNotificationsPlugin();
var _ready = false;


Future<void> initNotifications() async {
  if (_ready) return;
  _ready = await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
          linux: LinuxInitializationSettings(defaultActionName: 'Open'),
          windows: WindowsInitializationSettings(
            appName: 'Untis+',
            appUserModelId: 'anelkoo.UntisPlus',
            guid: '6e1b7c52-4d0a-4c1f-9c55-3b1d8b2e7a10',
          ),
        ),
      ) ??
      false;
}

/// Asks for permission where the OS requires it (Android 13+, iOS). No-op once decided.
Future<void> requestNotificationPermission() async {
  try {
    await initNotifications();
    if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } else if (Platform.isIOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, sound: true);
    }
  } on Object {
    // Without permission the app works the same, only without notifications.
  }
}

/// Shows one notification summing up [changes]; false if that failed. Never throws: a failed
/// notification must not break a refresh.
Future<bool> notifyChanges(List<LessonChange> changes) async {
  if (changes.isEmpty) return false;
  try {
    await initNotifications();
    final l = deviceLocalizations();
    final body = changesBody(l, l.localeName, changes);
    await _plugin.show(
      id: 1,
      title: l.changesTitle,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'timetable_changes',
          l.changesChannel,
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(body),
        ),
      ),
    );
    return true;
  } on Object {
    return false;
  }
}
