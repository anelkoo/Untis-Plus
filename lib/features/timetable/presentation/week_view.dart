import 'dart:math' as math;

import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/app_localizations.dart';
import '../domain/day_layout.dart';
import '../domain/lesson.dart';
import 'lesson_widgets.dart';

/// Calendar-style week: one column per school day, lessons placed by their real times.
/// Rows come from the lessons themselves, so no separate timegrid call is needed.
class WeekGrid extends StatelessWidget {
  const WeekGrid({
    super.key,
    required this.monday,
    required this.lessons,
    required this.now,
    this.showClasses = false,
  });

  final DateTime monday;

  /// In a teacher's timetable, cards name the class instead of the teacher.
  final bool showClasses;
  final List<Lesson> lessons;
  final DateTime now;

  static const _headerHeight = 44.0; // estimate, only used to fit the grid to the screen

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final theme = Theme.of(context);
    final weekend = lessons.where((l) => l.start.weekday > 5);
    final dayCount = weekend.isEmpty ? 5 : weekend.map((l) => l.start.weekday).reduce(math.max);
    final days = [for (var i = 0; i < dayCount; i++) DateTime(monday.year, monday.month, monday.day + i)];

    int minuteOf(DateTime t) => t.hour * 60 + t.minute;
    final from = lessons.isEmpty ? 8 * 60 : lessons.map((l) => minuteOf(l.start)).reduce(math.min);
    final to = lessons.isEmpty ? 16 * 60 : lessons.map((l) => minuteOf(l.end)).reduce(math.max);

    return LayoutBuilder(builder: (context, constraints) {
      // Tall enough that the shortest lesson fits subject, room and teacher at the user's text
      // size; taller when the screen has room. Odd 5-minute slots don't stretch the whole grid.
      final text = Theme.of(context).textTheme;
      final scaler = MediaQuery.textScalerOf(context);
      double line(TextStyle? s) => scaler.scale((s?.fontSize ?? 14) * (s?.height ?? 1.4));
      final axisWidth = scaler.scale(40) + 6;
      final cardHeight = line(text.labelLarge) + 2 * line(text.labelSmall) + 8;
      final shortest = lessons.isEmpty
          ? 50
          : math.max(lessons.map((l) => l.end.difference(l.start).inMinutes).reduce(math.min), 40);
      final scale = math.max((constraints.maxHeight - _headerHeight - 8) / (to - from), cardHeight / shortest);
      final height = (to - from) * scale;
      double y(DateTime t) => (minuteOf(t) - from) * scale;

      final starts = {for (final l in lessons) minuteOf(l.start)}.toList()..sort();
      final labels = <int>[];
      for (final s in starts) {
        if (labels.isEmpty || (s - labels.last) * scale >= 16) labels.add(s);
      }

      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(children: [
          // Sized by its text, so it grows with larger font settings.
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(children: [
              SizedBox(width: axisWidth),
              for (final day in days)
                Expanded(child: _DayHeader(day: day, locale: locale, today: DateUtils.isSameDay(day, now))),
            ]),
          ),
          SizedBox(
            height: height + 8,
            child: Row(crossAxisAlignment: .start, children: [
              SizedBox(
                width: axisWidth,
                height: height,
                child: Stack(children: [
                  for (final m in labels)
                    Positioned(
                      top: (m - from) * scale,
                      right: 6,
                      child: Text(
                        '${m ~/ 60}:${(m % 60).toString().padLeft(2, '0')}',
                        style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ),
                ]),
              ),
              for (final day in days)
                Expanded(
                  child: SizedBox(
                    height: height,
                    child: LayoutBuilder(builder: (context, column) {
                      final placed = layoutDay(lessons.where((l) => DateUtils.isSameDay(l.start, day)).toList());
                      final today = DateUtils.isSameDay(day, now);
                      return Stack(children: [
                        for (final p in placed)
                          Positioned(
                            top: y(p.lesson.start),
                            height: math.max(y(p.lesson.end) - y(p.lesson.start) - 2, 18),
                            left: column.maxWidth / p.columns * p.column + 1,
                            width: column.maxWidth / p.columns - 2,
                            child: _LessonCard(lesson: p.lesson, locale: locale, showClasses: showClasses),
                          ),
                        if (today && minuteOf(now) > from && minuteOf(now) < to)
                          Positioned(
                            top: y(now) - 1,
                            left: 0,
                            right: 0,
                            child: IgnorePointer(child: Container(height: 2, color: theme.colorScheme.error)),
                          ),
                      ]);
                    }),
                  ),
                ),
            ]),
          ),
        ]),
      );
    });
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.day, required this.locale, required this.today});

  final DateTime day;
  final String locale;
  final bool today;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = today ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant;
    final style = theme.textTheme.labelMedium?.copyWith(color: color, fontWeight: today ? .bold : null);
    return Column(mainAxisAlignment: .center, children: [
      Text(DateFormat.E(locale).format(day), style: style),
      Text(DateFormat.Md(locale).format(day), style: style),
    ]);
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({required this.lesson, required this.locale, required this.showClasses});

  final Lesson lesson;
  final String locale;
  final bool showClasses;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = lessonColors(context, lesson);
    final status = lessonStatus(l, lesson);
    final text = Theme.of(context).textTheme;
    final cancelled = lesson.status == .cancelled;
    return Semantics(
      button: true,
      label: semanticsLabel(l, lesson, locale),
      excludeSemantics: true,
      child: Material(
        color: colors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: colors.border == null ? BorderSide.none : BorderSide(color: colors.border!, width: 2),
        ),
        clipBehavior: .antiAlias,
        child: InkWell(
          onTap: () => showLessonDetails(context, lesson),
          // One text block, clipped by the card, so short lessons can't overflow.
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Text.rich(
              TextSpan(children: [
                if (status != null)
                  WidgetSpan(
                    alignment: .middle,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 2),
                      child: Icon(status.icon, size: 13, color: colors.border ?? colors.foreground),
                    ),
                  ),
                TextSpan(
                  text: lessonTitle(lesson),
                  style: text.labelLarge?.copyWith(
                    color: colors.foreground,
                    fontWeight: .w600,
                    decoration: cancelled ? TextDecoration.lineThrough : null,
                  ),
                ),
                for (final line in [joinNames(lesson.rooms), joinNames(showClasses ? lesson.classes : lesson.teachers)])
                  if (line.isNotEmpty)
                    TextSpan(text: '\n$line', style: text.labelSmall?.copyWith(color: colors.foreground)),
              ]),
              overflow: .clip,
            ),
          ),
        ),
      ),
    );
  }
}
