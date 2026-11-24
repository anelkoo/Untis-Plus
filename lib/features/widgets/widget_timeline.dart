import 'package:intl/intl.dart';

import '../../core/l10n/app_localizations.dart';
import '../timetable/domain/lesson.dart';

/// What a home screen widget shows from [from] on. The native widgets show the last entry
/// whose [from] has passed, so they move on to the next lesson without the app running.
typedef WidgetEntry = ({
  int from, // epoch milliseconds
  String label, // "Jetzt", "Danach" or the weekday
  String title,
  String time,
  String place, // room · teacher
  String status,
  List<String> later, // the rest of that day, for the medium widget
});

Map<String, Object> widgetEntryToJson(WidgetEntry e) => {
      'from': e.from,
      'label': e.label,
      'title': e.title,
      'time': e.time,
      'place': e.place,
      'status': e.status,
      'later': e.later,
    };

/// One entry per lesson boundary from [now] on, at most [max]. Cancelled lessons are never
/// "now" or "next", but show in the medium widget's list.
List<WidgetEntry> buildWidgetTimeline(
  List<Lesson> lessons,
  DateTime now,
  AppLocalizations l,
  String locale, {
  int max = 20,
}) {
  final sorted = [...lessons]..sort((a, b) => a.start.compareTo(b.start));
  final active = sorted.where((x) => x.status != .cancelled).toList();
  String hm(DateTime t) => DateFormat.Hm(locale).format(t);
  String names(List<Named> list) => list.map((n) => n.name).join(', ');
  bool sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
  String title(Lesson x) => x.subjects.isEmpty ? x.lessonText : names(x.subjects);
  String status(Lesson x) => switch (x.status) {
        .cancelled => l.statusCancelled,
        .substitution => l.statusSubstitution,
        .roomChange => l.statusRoomChange,
        .irregular => l.statusIrregular,
        .exam => l.statusExam,
        .regular => '',
      };

  WidgetEntry at(DateTime t) {
    final current = active.where((x) => !x.start.isAfter(t) && x.end.isAfter(t)).firstOrNull;
    final main = current ?? active.where((x) => x.start.isAfter(t)).firstOrNull;
    if (main == null) {
      return (from: 0, label: '', title: l.widgetNoLessons, time: '', place: '', status: '', later: const []);
    }
    final label = current != null ? l.nowLabel : (sameDay(main.start, t) ? l.nextLabel : DateFormat.E(locale).format(main.start));
    return (
      from: 0,
      label: label,
      title: title(main),
      time: '${hm(main.start)}–${hm(main.end)}',
      place: [names(main.rooms), names(main.teachers)].where((s) => s.isNotEmpty).join(' · '),
      status: status(main),
      later: [
        for (final x in sorted.where((x) => sameDay(x.start, main.start) && x.start.isAfter(main.start)).take(3))
          [hm(x.start), title(x), names(x.rooms), status(x)].where((s) => s.isNotEmpty).join(' · '),
      ],
    );
  }

  final boundaries = {
    now,
    for (final x in active)
      for (final t in [x.start, x.end])
        if (t.isAfter(now)) t,
  }.toList()
    ..sort();
  final entries = <WidgetEntry>[];
  for (final t in boundaries) {
    final e = at(t);
    final previous = entries.lastOrNull;
    final same = previous != null &&
        previous.label == e.label &&
        previous.title == e.title &&
        previous.time == e.time;
    if (!same) {
      entries.add((
        from: t.millisecondsSinceEpoch,
        label: e.label,
        title: e.title,
        time: e.time,
        place: e.place,
        status: e.status,
        later: e.later,
      ));
    }
    if (entries.length == max) break;
  }
  return entries;
}
