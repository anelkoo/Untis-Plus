import 'package:flutter_test/flutter_test.dart';
import 'package:untis_plus/features/timetable/domain/day_layout.dart';
import 'package:untis_plus/features/timetable/domain/lesson.dart';

Lesson _l(int id, int from, int to, [LessonStatus status = .regular]) => Lesson(
      id: id,
      start: DateTime(2026, 12, 3, from ~/ 100, from % 100),
      end: DateTime(2026, 12, 3, to ~/ 100, to % 100),
      status: status,
    );

Map<int, (int, int)> _lanes(List<Placed> placed) =>
    {for (final p in placed) p.lesson.id: (p.column, p.columns)};

void main() {
  test('lessons one after another each get the full width', () {
    expect(_lanes(layoutDay([_l(2, 850, 940), _l(1, 800, 850)])), {1: (0, 1), 2: (0, 1)});
  });

  test('parallel groups share lanes; a long event spans and keeps its lane', () {
    // Like the real Thursday: an event 13:25–16:50 next to SYP1/SYPF group lessons.
    final placed = layoutDay([
      _l(1, 1325, 1650),
      _l(2, 1415, 1505),
      _l(3, 1415, 1505),
      _l(4, 1510, 1600),
      _l(5, 1700, 1750),
    ]);
    expect(_lanes(placed), {1: (0, 3), 2: (1, 3), 3: (2, 3), 4: (1, 3), 5: (0, 1)});
  });

  test('now/next skips cancelled lessons and other days', () {
    final lessons = [
      _l(1, 800, 850),
      _l(2, 850, 940, .cancelled),
      _l(3, 945, 1035),
      Lesson(id: 4, start: DateTime(2026, 12, 4, 8), end: DateTime(2026, 12, 4, 9)),
    ];
    var r = nowNext(lessons, DateTime(2026, 12, 3, 8, 10));
    expect((r.now?.id, r.next?.id), (1, 3));
    r = nowNext(lessons, DateTime(2026, 12, 3, 9));
    expect((r.now?.id, r.next?.id), (null, 3));
    r = nowNext(lessons, DateTime(2026, 12, 3, 12));
    expect((r.now, r.next), (null, null));
  });
}
