import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/app_localizations.dart';
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
  });

  final DateTime day;

  /// In a teacher's timetable, rows name the class instead of the teacher.
  final bool showClasses;
  final List<Lesson> lessons;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final today = lessons.where((x) => DateUtils.isSameDay(x.start, day)).toList();
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
              child: Column(children: [
                if (nn.now case final current?)
                  _NowNextRow(showClasses: showClasses, label: l.nowLabel, lesson: current, time: l.untilTime(DateFormat.Hm(locale).format(current.end))),
                if (nn.next case final next?)
                  _NowNextRow(showClasses: showClasses, label: l.nextLabel, lesson: next, time: DateFormat.Hm(locale).format(next.start)),
              ]),
            ),
          ),
        if (today.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 48),
            child: Text(l.noLessonsDay, textAlign: .center, style: Theme.of(context).textTheme.bodyLarge),
          ),
        for (final lesson in today) _LessonRow(lesson: lesson, locale: locale, showClasses: showClasses),
      ],
    );
  }
}

class _NowNextRow extends StatelessWidget {
  const _NowNextRow({required this.label, required this.lesson, required this.time, required this.showClasses});

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
      title: Text(lessonTitle(lesson, long: true), maxLines: 1, overflow: .ellipsis),
      subtitle: Text([time, joinNames(lesson.rooms), if (showClasses) joinNames(lesson.classes)].where((s) => s.isNotEmpty).join(' · ')),
    );
  }
}

class _LessonRow extends StatelessWidget {
  const _LessonRow({required this.lesson, required this.locale, required this.showClasses});

  final Lesson lesson;
  final String locale;
  final bool showClasses;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = lessonColors(context, lesson);
    final status = lessonStatus(l, lesson);
    final cancelled = lesson.status == .cancelled;
    final details = [
      lesson.examType,
      joinNames(showClasses ? lesson.classes : lesson.teachers),
      joinNames(lesson.rooms),
      ...{lesson.lessonText, lesson.substitutionText, lesson.info}.where((t) => t != lessonTitle(lesson)),
    ].where((s) => s.isNotEmpty).join(' · ');

    return Semantics(
      button: true,
      label: semanticsLabel(l, lesson, locale),
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => showLessonDetails(context, lesson),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: IntrinsicHeight(
            child: Row(crossAxisAlignment: .stretch, children: [
              SizedBox(
                width: 48,
                child: Column(crossAxisAlignment: .start, children: [
                  Text(DateFormat.Hm(locale).format(lesson.start), style: theme.textTheme.labelLarge),
                  Text(DateFormat.Hm(locale).format(lesson.end),
                      style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ]),
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
                child: Column(crossAxisAlignment: .start, children: [
                  Text(
                    lessonTitle(lesson, long: true),
                    style: theme.textTheme.titleMedium?.copyWith(
                      decoration: cancelled ? TextDecoration.lineThrough : null,
                      color: cancelled ? theme.colorScheme.onSurfaceVariant : null,
                    ),
                  ),
                  if (status != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(children: [
                        Icon(status.icon, size: 16, color: colors.border ?? theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(status.label,
                            style: theme.textTheme.labelMedium
                                ?.copyWith(color: colors.border ?? theme.colorScheme.onSurfaceVariant)),
                      ]),
                    ),
                  if (details.isNotEmpty)
                    Text(details, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
