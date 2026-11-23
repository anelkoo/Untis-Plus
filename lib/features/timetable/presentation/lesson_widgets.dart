import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/app_localizations.dart';
import '../domain/lesson.dart';

/// Colours for a lesson card. Each subject gets its own stable hue; the container/on-container
/// pair from Material's tonal palette keeps the text readable in light and dark mode.
({Color background, Color foreground, Color accent, Color? border}) lessonColors(BuildContext context, Lesson lesson) {
  final scheme = Theme.of(context).colorScheme;
  if (lesson.status == .cancelled) {
    return (
      background: scheme.surfaceContainerHighest,
      foreground: scheme.onSurfaceVariant,
      accent: scheme.outlineVariant,
      border: null,
    );
  }
  // Exams must be impossible to miss: pure yellow with black text (19.6:1), in light and dark mode.
  if (lesson.status == .exam) {
    return (background: examYellow, foreground: Colors.black, accent: Colors.black, border: Colors.black);
  }
  final subject = _subjectScheme(_subjectKey(lesson), scheme.brightness);
  return (
    background: subject.primaryContainer,
    foreground: subject.onPrimaryContainer,
    accent: subject.primary,
    border: switch (lesson.status) {
      .exam => scheme.error,
      .substitution || .irregular => scheme.tertiary,
      _ => null,
    },
  );
}

const examYellow = Color(0xFFFFFF00);

String _subjectKey(Lesson l) => l.subjects.isEmpty ? l.lessonText : l.subjects.first.name;

final _schemes = <(String, Brightness), ColorScheme>{};
ColorScheme _subjectScheme(String key, Brightness brightness) => _schemes.putIfAbsent((key, brightness), () {
      // Golden-angle steps, so similar names like "D" and "E" get clearly different hues.
      final hash = key.codeUnits.fold(7, (h, c) => (h * 31 + c) % 1000003);
      final hue = hash * 137.508 % 360;
      return ColorScheme.fromSeed(
        seedColor: HSVColor.fromAHSV(1, hue, 0.55, 0.85).toColor(),
        brightness: brightness,
      );
    });

/// Status as icon plus text, so it never depends on colour alone.
({IconData icon, String label})? lessonStatus(AppLocalizations l, Lesson lesson) => switch (lesson.status) {
      .regular => null,
      .cancelled => (icon: Icons.block, label: l.statusCancelled),
      .substitution => (icon: Icons.swap_horiz, label: l.statusSubstitution),
      .irregular => (icon: Icons.info_outline, label: l.statusIrregular),
      .exam => (icon: Icons.assignment_outlined, label: l.statusExam),
    };

/// Short title: subject, or the lesson text for events without a subject.
String lessonTitle(Lesson l, {bool long = false}) {
  if (l.subjects.isEmpty) return l.lessonText.isNotEmpty ? l.lessonText : l.substitutionText;
  return l.subjects.map((s) => long && s.longName.isNotEmpty ? s.longName : s.name).join(', ');
}

String joinNames(List<Named> names) => names.map((n) => n.name).join(', ');

String timeRange(Lesson l, String locale) =>
    '${DateFormat.Hm(locale).format(l.start)}–${DateFormat.Hm(locale).format(l.end)}';

String semanticsLabel(AppLocalizations l, Lesson lesson, String locale) => [
      lessonTitle(lesson, long: true),
      timeRange(lesson, locale),
      joinNames(lesson.rooms),
      joinNames(lesson.teachers),
      ?lessonStatus(l, lesson)?.label,
    ].where((s) => s.isNotEmpty).join(', ');

void showLessonDetails(BuildContext context, Lesson lesson) {
  final l = AppLocalizations.of(context);
  final locale = Localizations.localeOf(context).toString();
  final status = lessonStatus(l, lesson);
  final scheme = Theme.of(context).colorScheme;

  Widget names(IconData icon, String label, List<Named> list) => ListTile(
        leading: Icon(icon),
        title: Text(list
            .map((n) => [
                  if (n.longName.isNotEmpty && n.longName != n.name) '${n.name} (${n.longName})' else n.name,
                  if (n.original != null && n.original!.isNotEmpty) l.insteadOf(n.original!),
                ].join(' · '))
            .join('\n')),
        subtitle: Text(label),
      );
  Widget text(IconData icon, String value) => ListTile(leading: Icon(icon), title: Text(value));

  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          ListTile(
            title: Text(lessonTitle(lesson, long: true), style: Theme.of(context).textTheme.titleLarge),
            subtitle: Text('${DateFormat.MMMMEEEEd(locale).format(lesson.start)} · ${timeRange(lesson, locale)}'),
          ),
          if (status != null)
            ListTile(
              leading: Icon(status.icon, color: lesson.status == .exam ? scheme.error : scheme.tertiary),
              title: Text([status.label, lesson.examType].where((s) => s.isNotEmpty).join(' · ')),
            ),
          if (lesson.teachers.isNotEmpty) names(Icons.person_outline, l.teachersLabel, lesson.teachers),
          if (lesson.rooms.isNotEmpty) names(Icons.meeting_room_outlined, l.roomsLabel, lesson.rooms),
          if (lesson.classes.isNotEmpty) names(Icons.groups_outlined, l.classesLabel, lesson.classes),
          for (final t in {lesson.lessonText, lesson.substitutionText, lesson.info})
            if (t.isNotEmpty) text(Icons.notes, t),
        ],
      ),
    ),
  );
}
