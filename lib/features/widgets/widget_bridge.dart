import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';

import '../../core/l10n/device_localizations.dart';
import '../timetable/data/timetable_repository.dart';
import 'widget_timeline.dart';

/// Android AppWidgetProvider class names (android/app/src/main/kotlin/.../widget).
const _androidWidgets = ['NextLessonWidget', 'TodayWidget'];
const _iosWidget = 'UntisPlusWidget';
// SideStore may rename the app group when it signs the app; AppDelegate reads the real one.
const _appGroupChannel = MethodChannel('untis_plus/app_group');

/// Hands the widgets a timeline of my coming lessons from the cache. Widgets never go online.
/// Best effort: the app works the same without widgets.
Future<void> publishWidgets(TimetableRepository repo, {DateTime? now}) async {
  if (!Platform.isAndroid && !Platform.isIOS) return;
  try {
    final t = now ?? DateTime.now();
    final lessons = [
      for (final monday in {mondayOf(t), mondayOf(t.add(const Duration(days: 7)))})
        ...?(await repo.cached(me, monday))?.lessons,
    ];
    final l = deviceLocalizations();
    final timeline = buildWidgetTimeline(lessons, t, l, l.localeName);
    await _save(jsonEncode(timeline.map(widgetEntryToJson).toList()));
    if (Platform.isAndroid) {
      // Wake the widgets at each lesson boundary (inexact, may be a few minutes late).
      final times = [for (final e in timeline.skip(1)) DateTime.fromMillisecondsSinceEpoch(e.from)];
      for (final name in _androidWidgets) {
        await HomeWidget.scheduleWidgetUpdates(times, androidName: name);
      }
    }
  } on Object {
    // See above.
  }
}

/// On sign-out: the next account must not see this one's lessons on the home screen.
Future<void> clearWidgets() async {
  if (!Platform.isAndroid && !Platform.isIOS) return;
  try {
    await _save(null);
  } on Object {
    // See publishWidgets.
  }
}

Future<void> _save(String? timeline) async {
  if (Platform.isIOS) {
    final group = await _appGroupChannel.invokeMethod<String>('appGroup');
    await HomeWidget.setAppGroupId(group ?? 'group.at.anelkoo.untisPlus');
  }
  await HomeWidget.saveWidgetData<String>('timeline', timeline);
  if (Platform.isIOS) {
    await HomeWidget.updateWidget(iOSName: _iosWidget);
  } else {
    for (final name in _androidWidgets) {
      await HomeWidget.updateWidget(androidName: name);
    }
  }
}
