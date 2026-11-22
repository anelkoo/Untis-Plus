import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:untis_plus/features/timetable/domain/lesson.dart';

import 'fake_server.dart';

// Shaped like a recorded REST-view response for another class (names anonymized). The
// cancelled entry's status value is assumed: the recorded week had no cancellation.
const _klass = Named(id: 1074, name: '1AHIT', longName: '1a Muster');
List<Lesson> _week() =>
    parseRestWeek((jsonDecode(fixture('rest_class_week.json')) as Map).cast<String, dynamic>(), _klass);

void main() {
  test('parses entries with names, local times, double lessons; skips broken ones', () {
    final lessons = _week();
    expect(lessons.map((l) => l.id), [11, 13, 14, 15, 16]);
    expect(lessons.first.start, DateTime(2026, 11, 16, 8));
    expect(lessons.first.end, DateTime(2026, 11, 16, 9, 40));
    expect(lessons.first.teachers.single, const Named(id: 0, name: 'MOSA', longName: 'Moser'));
    expect(lessons.first.rooms.single.name, '1M');
    expect(lessons.first.classes, [_klass]);
  });

  test('maps status and replaced teachers', () {
    final byId = {for (final l in _week()) l.id: l};
    expect(byId[11]!.status, LessonStatus.regular);
    expect(byId[13]!.status, LessonStatus.substitution);
    expect(byId[13]!.teachers.single.original, 'LEIA');
    expect(byId[13]!.substitutionText, 'Supplierung');
    expect(byId[14]!.status, LessonStatus.exam);
    expect(byId[14]!.info, 'Test 1');
    expect(byId[15]!.status, LessonStatus.cancelled);
    expect(byId[16]!.classes.map((c) => c.name), ['1AHIT', '2AHIT']);
  });

  test('merging two classes keeps a shared lesson once with both classes', () {
    final other = _week().map((l) => l.copyWith(classes: const [Named(id: 1, name: '2AHIT')]));
    final merged = mergeClassLessons([..._week(), ...other]);
    expect(merged, hasLength(5));
    expect(merged.firstWhere((l) => l.id == 16).classes.map((c) => c.name), ['1AHIT', '2AHIT']);
    expect(merged.firstWhere((l) => l.id == 11).classes.map((c) => c.name), ['1AHIT', '2AHIT']);
  });
}
