import 'package:material_ui/material_ui.dart';

import '../domain/lesson.dart';

/// Where a test or homework entry points to: the lesson that overlaps [start]–[end], or, without
/// an [end], the lesson of [subject] on [start]'s day.
typedef Jump = ({DateTime start, DateTime? end, String subject});

/// Set by the tests and homework lists. The shell then shows the timetable, which goes to that
/// day and opens the lesson.
final timetableJump = ValueNotifier<Jump?>(null);

/// The lesson [jump] points to, if [lessons] has it.
Lesson? lessonFor(Jump jump, List<Lesson> lessons) {
  final end = jump.end;
  bool sameDay(Lesson l) => l.start.year == jump.start.year && l.start.month == jump.start.month && l.start.day == jump.start.day;
  bool bySubject(Lesson l) => l.subjects.any((s) => s.name == jump.subject || s.longName == jump.subject);
  return lessons
      .where((l) => end != null ? l.start.isBefore(end) && jump.start.isBefore(l.end) : sameDay(l) && bySubject(l))
      .firstOrNull;
}
