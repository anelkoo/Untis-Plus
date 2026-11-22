import 'lesson.dart';

enum ChangeKind { cancelled, substitution, roomChanged, exam, added }

typedef LessonChange = ({ChangeKind kind, Lesson lesson});

/// What changed between the stored and the fresh copy of a week, for lessons that haven't
/// ended at [now]. Lessons are matched by their WebUntis period id.
List<LessonChange> diffLessons(List<Lesson> old, List<Lesson> fresh, DateTime now) {
  String names(List<Named> list) => list.map((n) => n.name).join(',');
  final before = {for (final l in old) l.id: l};
  final freshIds = {for (final l in fresh) l.id};
  final changes = <LessonChange>[];

  for (final l in fresh.where((l) => l.end.isAfter(now))) {
    final o = before[l.id];
    final kind = switch (o) {
      null when l.status == .regular || l.status == .cancelled => null,
      null => ChangeKind.added,
      _ when l.status == .cancelled => o.status == .cancelled ? null : ChangeKind.cancelled,
      _ when l.status == .exam && o.status != .exam => ChangeKind.exam,
      _ when names(l.teachers) != names(o.teachers) => ChangeKind.substitution,
      _ when names(l.rooms) != names(o.rooms) => ChangeKind.roomChanged,
      _ => null,
    };
    if (kind != null) changes.add((kind: kind, lesson: l));
  }
  // A lesson that vanished from the timetable is cancelled too.
  for (final o in old) {
    if (!freshIds.contains(o.id) && o.end.isAfter(now) && o.status != .cancelled) {
      changes.add((kind: ChangeKind.cancelled, lesson: o));
    }
  }
  return changes..sort((a, b) => a.lesson.start.compareTo(b.lesson.start));
}
