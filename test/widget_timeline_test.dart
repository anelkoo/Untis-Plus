import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:untis_plus/core/l10n/app_localizations.dart';
import 'package:untis_plus/features/timetable/domain/lesson.dart';
import 'package:untis_plus/features/widgets/widget_timeline.dart';

Lesson _l(int id, int day, int from, int to, String subject, {LessonStatus status = .regular}) => Lesson(
      id: id,
      start: DateTime(2026, 11, day, from ~/ 100, from % 100),
      end: DateTime(2026, 11, day, to ~/ 100, to % 100),
      status: status,
      subjects: [Named(id: 0, name: subject)],
      teachers: const [Named(id: 0, name: 'HUB')],
      rooms: const [Named(id: 0, name: 'E12')],
    );

final _week = [
  _l(1, 23, 800, 850, 'D'),
  _l(2, 23, 850, 940, 'E', status: .cancelled),
  _l(3, 23, 945, 1035, 'AM', status: .exam),
  _l(4, 24, 800, 850, 'POS'),
];

void main() {
  setUpAll(() => initializeDateFormatting());
  final l = lookupAppLocalizations(const Locale('de'));

  test('one entry per boundary: now, next (skipping cancelled), then the next school day', () {
    final t = buildWidgetTimeline(_week, DateTime(2026, 11, 23, 7), l, 'de');
    String show(WidgetEntry e) => '${DateTime.fromMillisecondsSinceEpoch(e.from).hour}:${e.label} ${e.title} ${e.status}'.trim();
    expect(t.map(show), [
      '7:Danach D',
      '8:Jetzt D',
      '8:Danach AM Prüfung', // at 08:50 the cancelled E is skipped
      '9:Jetzt AM Prüfung',
      '10:Di POS', // after the last lesson: tomorrow's first
      '8:Jetzt POS',
      '8: Keine Stunden in den nächsten Tagen', // after Tuesday's last lesson
    ]);
    expect(t.first.time, '08:00–08:50');
    expect(t.first.place, 'E12 · HUB');
    expect(t.first.later, ['08:50 · E · E12 · Entfällt', '09:45 · AM · E12 · Prüfung']);
  });

  test('nothing ahead gives the empty entry', () {
    final t = buildWidgetTimeline(_week, DateTime(2026, 11, 25), l, 'de');
    expect(t.single.title, 'Keine Stunden in den nächsten Tagen');
    expect(t.single.label, '');
  });

  test('stops at max entries', () {
    expect(buildWidgetTimeline(_week, DateTime(2026, 11, 23, 7), l, 'de', max: 3), hasLength(3));
  });
}
