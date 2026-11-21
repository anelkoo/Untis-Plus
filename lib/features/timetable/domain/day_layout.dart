import 'lesson.dart';

/// Where a lesson sits in a day column: lane [column] of [columns] side-by-side lanes, so
/// parallel lessons (group splits, events) don't cover each other.
typedef Placed = ({Lesson lesson, int column, int columns});

/// Lays out one day's lessons. Overlapping lessons form a cluster that shares its lanes.
List<Placed> layoutDay(List<Lesson> lessons) {
  final sorted = [...lessons]..sort((a, b) => a.start.compareTo(b.start));
  final result = <Placed>[];
  var cluster = <({Lesson lesson, int column})>[];
  var clusterEnd = DateTime(0);
  void flush() {
    final columns = cluster.fold(0, (m, p) => p.column >= m ? p.column + 1 : m);
    result.addAll([for (final p in cluster) (lesson: p.lesson, column: p.column, columns: columns)]);
    cluster = [];
  }

  for (final lesson in sorted) {
    if (cluster.isNotEmpty && !lesson.start.isBefore(clusterEnd)) flush();
    // First lane whose last lesson has ended.
    var column = 0;
    while (cluster.any((p) => p.column == column && p.lesson.end.isAfter(lesson.start))) {
      column++;
    }
    cluster.add((lesson: lesson, column: column));
    if (lesson.end.isAfter(clusterEnd) || cluster.length == 1) clusterEnd = lesson.end;
  }
  if (cluster.isNotEmpty) flush();
  return result;
}

/// The lesson running at [now] and the next one starting later today. Cancelled lessons don't
/// count.
({Lesson? now, Lesson? next}) nowNext(List<Lesson> lessons, DateTime now) {
  final today = lessons
      .where((l) => l.status != .cancelled && _sameDay(l.start, now))
      .toList()
    ..sort((a, b) => a.start.compareTo(b.start));
  Lesson? current;
  for (final l in today) {
    if (!l.start.isAfter(now) && l.end.isAfter(now)) current = l;
  }
  final next = today.where((l) => l.start.isAfter(now)).firstOrNull;
  return (now: current, next: next);
}

bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
