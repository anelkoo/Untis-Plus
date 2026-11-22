import 'package:flutter_test/flutter_test.dart';
import 'package:untis_plus/features/timetable/domain/lesson.dart';
import 'package:untis_plus/features/timetable/domain/timetable_diff.dart';

final _now = DateTime(2026, 11, 23, 9);

Lesson _l(int id, int hour, {LessonStatus status = .regular, String teacher = 'HUB', String room = 'E12'}) => Lesson(
      id: id,
      start: DateTime(2026, 11, 23, hour),
      end: DateTime(2026, 11, 23, hour, 50),
      status: status,
      subjects: const [Named(id: 1, name: 'D')],
      teachers: [Named(id: 0, name: teacher)],
      rooms: [Named(id: 0, name: room)],
    );

Map<int, ChangeKind> _diff(List<Lesson> old, List<Lesson> fresh) =>
    {for (final c in diffLessons(old, fresh, _now)) c.lesson.id: c.kind};

void main() {
  test('no changes, no events', () {
    final week = [_l(1, 10), _l(2, 11)];
    expect(_diff(week, week), isEmpty);
  });

  test('detects cancelled, substitution, room change, exam, added and vanished lessons', () {
    final old = [_l(1, 10), _l(2, 11), _l(3, 12), _l(4, 13), _l(5, 14)];
    final fresh = [
      _l(1, 10, status: .cancelled),
      _l(2, 11, status: .substitution, teacher: 'MUE'),
      _l(3, 12, room: 'E14'),
      _l(4, 13, status: .exam),
      _l(6, 15, status: .irregular),
      _l(7, 16), // new regular period: not worth a notification
    ];
    expect(_diff(old, fresh), {
      1: ChangeKind.cancelled,
      2: ChangeKind.substitution,
      3: ChangeKind.roomChanged,
      4: ChangeKind.exam,
      5: ChangeKind.cancelled, // vanished
      6: ChangeKind.added,
    });
  });

  test('lessons that already ended are ignored; a known cancellation is not reported twice', () {
    final old = [_l(1, 8), _l(2, 10, status: .cancelled)];
    final fresh = [_l(1, 8, status: .cancelled), _l(2, 10, status: .cancelled)];
    expect(_diff(old, fresh), isEmpty);
  });
}
