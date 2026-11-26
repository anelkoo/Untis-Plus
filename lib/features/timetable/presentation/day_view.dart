import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/settings.dart';
import '../../homework/lesson_homework.dart';
import '../domain/day_layout.dart';
import '../domain/lesson.dart';
import 'lesson_widgets.dart';

/// One day as a list with full details; today starts with the Now/Next card.
class DayList extends StatelessWidget {
  const DayList({
    super.key,
    required this.day,
    required this.lessons,
    required this.now,
    this.showClasses = false,
    this.holidays = const [],
  });

  final DateTime day;

  /// In a teacher's timetable, rows name the class instead of the teacher.
  final bool showClasses;
  final List<Lesson> lessons;
  final DateTime now;
  final List<Holiday> holidays;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final holiday = holidayOn(holidays, day);
    final locale = Localizations.localeOf(context).toString();
    final today = lessons
        .where((x) => DateUtils.isSameDay(x.start, day))
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));
    // Latest end so far, so a lesson running parallel to another doesn't fake a break.
    final latestEnd = <DateTime>[];
    for (final x in today) {
      latestEnd.add(
        latestEnd.isEmpty || x.end.isAfter(latestEnd.last) ? x.end : latestEnd.last,
      );
    }
    final nn = nowNext(today, now);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        if (nn.now != null || nn.next != null)
          Card.filled(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  if (nn.now case final current?)
                    _NowNextRow(
                      showClasses: showClasses,
                      label: l.nowLabel,
                      lesson: current,
                      time: l.untilTime(
                        DateFormat.Hm(locale).format(current.end),
                      ),
                    ),
                  if (nn.next case final next?)
                    _NowNextRow(
                      showClasses: showClasses,
                      label: l.nextLabel,
                      lesson: next,
                      time: DateFormat.Hm(locale).format(next.start),
                    ),
                ],
              ),
            ),
          ),
        if (today.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 48),
            child: holiday == null
                ? Text(
                    l.noLessonsDay,
                    textAlign: .center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  )
                : Builder(
                    builder: (context) {
                      final c = holidayColors(context);
                      return Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: c.background,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.beach_access_outlined,
                              size: 40,
                              color: c.foreground,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              holiday.name,
                              textAlign: .center,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(color: c.foreground),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        for (final (i, lesson) in today.indexed) ...[
          if (i > 0 && lesson.start.difference(latestEnd[i - 1]) >= _minBreak)
            _BreakRow(
              label: l.breakLabel(
                DateFormat.Hm(locale).format(latestEnd[i - 1]),
                DateFormat.Hm(locale).format(lesson.start),
              ),
            ),
          _LessonRow(
            lesson: lesson,
            locale: locale,
            showClasses: showClasses,
            now: now,
          ),
        ],
      ],
    );
  }
}

const _minBreak = Duration(minutes: 15);

class _BreakRow extends StatelessWidget {
  const _BreakRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const SizedBox(width: 48),
          Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
        ],
      ),
    );
  }
}

class _NowNextRow extends StatelessWidget {
  const _NowNextRow({
    required this.label,
    required this.lesson,
    required this.time,
    required this.showClasses,
  });

  final bool showClasses;
  final String label;
  final Lesson lesson;
  final String time;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ListTile(
      onTap: () => showLessonDetails(context, lesson),
      leading: SizedBox(width: 56, child: Text(label, style: text.labelLarge)),
      title: Text(
        lessonTitle(lesson, long: true),
        maxLines: 1,
        overflow: .ellipsis,
      ),
      subtitle: Text(
        [
          time,
          joinNames(lesson.rooms),
          if (showClasses) joinNames(lesson.classes),
        ].where((s) => s.isNotEmpty).join(' · '),
      ),
    );
  }
}

class _LessonRow extends ConsumerWidget {
  const _LessonRow({
    required this.lesson,
    required this.locale,
    required this.showClasses,
    required this.now,
  });

  final DateTime now;
  final Lesson lesson;
  final String locale;
  final bool showClasses;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final homework = ref.watch(lessonHomeworkProvider(lesson));
    final colors = lessonColors(context, lesson);
    // Exams and colours the user picked fill the row; with the week design every lesson sits on its colour.
    final filled = colors.solid || !look.value.contains(Look.modernCards);
    var theme = Theme.of(context);
    // On a filled background every text and icon takes the card's text colour.
    if (filled) {
      final fg = colors.foreground;
      theme = theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          onSurface: fg,
          onSurfaceVariant: fg,
        ),
        textTheme: theme.textTheme.apply(bodyColor: fg, displayColor: fg),
      );
    }
    final status = lessonStatus(l, lesson);
    final cancelled = lesson.status == .cancelled;
    final details = [
      lesson.examType,
      joinNames(showClasses ? lesson.classes : lesson.teachers),
      joinNames(lesson.rooms),
      ...{
        lesson.lessonText,
        lesson.substitutionText,
        lesson.info,
      }.where((t) => t != lessonTitle(lesson)),
    ].where((s) => s.isNotEmpty).join(' · ');

    final running = !now.isBefore(lesson.start) && now.isBefore(lesson.end);
    final row = Semantics(
      button: true,
      label: semanticsLabel(l, lesson, locale),
      excludeSemantics: true,
      child: Material(
        color: filled ? colors.background : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: filled && !colors.solid && colors.border != null
              ? BorderSide(color: colors.border!, width: 2)
              : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => showLessonDetails(context, lesson),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 8,
              horizontal: filled ? 8 : 0,
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: .stretch,
                children: [
                  SizedBox(
                    width: 48,
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        Text(
                          DateFormat.Hm(locale).format(lesson.start),
                          style: theme.textTheme.labelLarge,
                        ),
                        Text(
                          DateFormat.Hm(locale).format(lesson.end),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 6,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: colors.accent,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        Text(
                          lessonTitle(lesson, long: true),
                          style: theme.textTheme.titleMedium?.copyWith(
                            decoration: cancelled
                                ? TextDecoration.lineThrough
                                : null,
                            color: cancelled
                                ? theme.colorScheme.onSurfaceVariant
                                : null,
                          ),
                        ),
                        if (status != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Row(
                              children: [
                                Icon(
                                  status.icon,
                                  size: 16,
                                  color:
                                      colors.border ??
                                      theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  status.label,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color:
                                        colors.border ??
                                        theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (details.isNotEmpty)
                          Text(
                            details,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        for (final h in homework)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Row(
                              crossAxisAlignment: .start,
                              children: [
                                const Icon(Icons.menu_book_outlined, size: 16),
                                const SizedBox(width: 4),
                                Expanded(child: Text(h.text, maxLines: 2, overflow: .ellipsis)),
                              ],
                            ),
                          ),
                        // The lesson that is running: how far along it is.
                        if (running)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: LinearProgressIndicator(
                              value:
                                  now.difference(lesson.start).inSeconds /
                                  lesson.end.difference(lesson.start).inSeconds,
                              minHeight: 4,
                              borderRadius: BorderRadius.circular(2),
                              color: colors.accent,
                              backgroundColor: colors.accent.withValues(
                                alpha: 0.25,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    // Lessons that are over fade back.
    return now.isBefore(lesson.end) ? row : Opacity(opacity: 0.5, child: row);
  }
}
