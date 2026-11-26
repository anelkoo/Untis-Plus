import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../timetable/data/timetable_repository.dart';
import '../timetable/domain/lesson.dart';
import '../timetable/presentation/jump.dart';
import '../timetable/presentation/timetable_providers.dart';
import 'homework.dart';
import 'homework_screen.dart';

/// My open homework that belongs to [lesson]. Homework only has a due day, so it sits on the
/// first lesson of its subject on that day.
final lessonHomeworkProvider = Provider.autoDispose.family<List<Homework>, Lesson>((ref, lesson) {
  final open = (ref.watch(homeworkProvider).value ?? const <Homework>[]).where((h) => !h.done);
  final lessons = ref.watch(weekProvider(me, mondayOf(lesson.start))).value?.lessons ?? const <Lesson>[];
  return [
    for (final h in open)
      if (lessonFor((start: h.due, end: null, subject: h.subject), lessons) == lesson) h,
  ];
});
