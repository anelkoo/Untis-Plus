import '../timetable/data/timetable_repository.dart';

/// One homework entry. [due] is the due day at midnight; [done] is the school's `completed` flag.
typedef Homework = ({int id, String subject, String teacher, String text, DateTime due, bool done});

enum HomeworkGroup { overdue, today, tomorrow, week, later, done }

/// Parses the `data` of `/api/homeworks/lessons`, due soonest first. Entries that don't parse are skipped.
List<Homework> parseHomework(Map<dynamic, dynamic> data) {
  final subjects = {for (final l in (data['lessons'] as List?) ?? const []) l['id']: '${l['subject'] ?? ''}'};
  final teachers = {for (final t in (data['teachers'] as List?) ?? const []) t['id']: '${t['name'] ?? ''}'};
  final teacherOf = {for (final r in (data['records'] as List?) ?? const []) r['homeworkId']: r['teacherId']};
  final list = <Homework>[];
  for (final h in (data['homeworks'] as List?) ?? const []) {
    try {
      final due = (h['dueDate'] as num).toInt();
      list.add((
        id: (h['id'] as num).toInt(),
        subject: subjects[h['lessonId']] ?? '',
        teacher: teachers[teacherOf[h['id']]] ?? '',
        text: [h['text'], h['remark']].where((s) => s != null && '$s'.isNotEmpty).join('\n'),
        due: DateTime(due ~/ 10000, due ~/ 100 % 100, due % 100),
        done: h['completed'] == true,
      ));
    } on Object {
      // Skip this entry.
    }
  }
  return list..sort((a, b) => a.due.compareTo(b.due));
}

/// The first Monday after [now]'s day: "this week" ends before it.
DateTime nextMonday(DateTime now) => DateTime(now.year, now.month, now.day + 8 - now.weekday);

HomeworkGroup groupOf(Homework h, DateTime now) {
  if (h.done) return .done;
  final due = untisDate(h.due), today = untisDate(now);
  if (due < today) return .overdue;
  if (due == today) return .today;
  if (due == untisDate(DateTime(now.year, now.month, now.day + 1))) return .tomorrow;
  return due < untisDate(nextMonday(now)) ? .week : .later;
}
