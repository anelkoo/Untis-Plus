import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:untis_plus/features/timetable/domain/lesson.dart';

import 'fake_server.dart';

// The fixture is hand-written from the documented getTimetable format: JSON-RPC needs a real
// login, so no recorded response is available. Check new parsing against a real week too.
List<Lesson> _week() =>
    parseLessons((jsonDecode(fixture('getTimetable_week.json')) as Map)['result'] as List);

void main() {
  test('sorts by start, skips the broken period, reads unpadded times as local time', () {
    final lessons = _week();
    expect(lessons.map((l) => l.id), [101, 102, 103, 104, 105, 106]);
    expect(lessons.first.start, DateTime(2026, 11, 23, 7, 55));
    expect(lessons.first.end, DateTime(2026, 11, 23, 8, 45));
    expect(lessons.first.start.isUtc, isFalse);
  });

  test('maps status codes', () {
    final status = {for (final l in _week()) l.id: l.status};
    expect(status, {
      101: LessonStatus.regular,
      102: LessonStatus.cancelled,
      103: LessonStatus.roomChange,
      104: LessonStatus.exam,
      105: LessonStatus.substitution, // other teacher
      106: LessonStatus.irregular,
    });
  });

  test('keeps names, originals and texts; ids alone are fine', () {
    final byId = {for (final l in _week()) l.id: l};
    expect(byId[101]!.subjects.single.longName, 'Deutsch');
    expect(byId[101]!.lessonText, 'Buch mitnehmen');
    expect(byId[105]!.teachers.single, const Named(id: 7, name: 'MUE', longName: 'Müller', original: 'HUB'));
    expect(byId[103]!.rooms.single.original, 'E12');
    expect(byId[102]!.subjects.single, const Named(id: 22));
    expect(byId[102]!.info, 'Lehrer krank');
  });

  test('lessons overlapping an /api/exams entry become exams, cancelled ones stay cancelled', () {
    final periods = (jsonDecode(fixture('getTimetable_week.json')) as Map)['result'] as List;
    final exams = [
      ...((jsonDecode(fixture('api_exams.json')) as Map)['data']['exams'] as List),
      {'examDate': 20261123, 'startTime': 845, 'endTime': 935, 'examType': 'SA'},
      {'broken': true},
    ];
    final byId = {for (final l in parseLessons(periods, exams)) l.id: l};
    expect(byId[101]!.status, LessonStatus.exam);
    expect(byId[101]!.examType, 'SMÜP');
    expect(byId[102]!.status, LessonStatus.cancelled);
    expect(byId[103]!.status, LessonStatus.roomChange); // starts as the exam ends
  });
}
