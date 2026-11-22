import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:untis_plus/core/l10n/app_localizations.dart';
import 'package:untis_plus/features/notifications/change_notifier.dart';
import 'package:untis_plus/features/timetable/domain/lesson.dart';
import 'package:untis_plus/features/timetable/domain/timetable_diff.dart';

LessonChange _c(ChangeKind kind, {int hour = 8}) => (
      kind: kind,
      lesson: Lesson(
        id: 1,
        start: DateTime(2026, 11, 23, hour, 50),
        end: DateTime(2026, 11, 23, hour + 1, 40),
        subjects: const [Named(id: 1, name: 'AM')],
        teachers: const [Named(id: 2, name: 'MUE')],
        rooms: const [Named(id: 3, name: 'E14')],
      ),
    );

void main() {
  setUpAll(() => initializeDateFormatting());

  test('German lines name day, time and subject', () {
    final l = lookupAppLocalizations(const Locale('de'));
    expect(changeText(l, 'de', _c(.cancelled)), 'Mo 08:50 AM: entfällt');
    expect(changeText(l, 'de', _c(.substitution)), 'Mo 08:50 AM: Vertretung MUE');
    expect(changeText(l, 'de', _c(.roomChanged)), 'Mo 08:50 AM: jetzt in E14');
  });

  test('long lists are cut after five lines', () {
    final l = lookupAppLocalizations(const Locale('en'));
    final body = changesBody(l, 'en', [for (var i = 0; i < 7; i++) _c(.exam)]);
    expect(body.split('\n'), hasLength(6));
    expect(body, startsWith('Mon 08:50 AM: exam'));
    expect(body, endsWith('+2 more'));
  });
}
