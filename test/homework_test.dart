import 'package:flutter_test/flutter_test.dart';
import 'package:untis_plus/features/homework/homework.dart';

void main() {
  final data = {
    'records': [
      {'homeworkId': 1, 'teacherId': 9, 'elementIds': [5]},
    ],
    'homeworks': [
      {'id': 2, 'lessonId': 7, 'dueDate': 20261130, 'text': 'Später', 'remark': '', 'completed': false},
      {'id': 1, 'lessonId': 7, 'dueDate': 20261125, 'text': 'Aufgabe 4', 'remark': 'Seite 12', 'completed': false},
      {'id': 3, 'lessonId': 8, 'dueDate': 20261124, 'text': 'Fertig', 'completed': true},
      {'id': 4, 'dueDate': 'kaputt'},
    ],
    'teachers': [
      {'id': 9, 'name': 'MUS'},
    ],
    'lessons': [
      {'id': 7, 'subject': 'M'},
      {'id': 8, 'subject': ''},
    ],
  };

  test('parses homework, joins subject and teacher, sorts by due date, skips broken entries', () {
    final list = parseHomework(data);
    expect(list.map((h) => h.id), [3, 1, 2]);
    expect(list[1], (id: 1, subject: 'M', teacher: 'MUS', text: 'Aufgabe 4\nSeite 12', due: DateTime(2026, 11, 25), done: false));
    expect(list[0].done, isTrue);
  });

  test('groups by due day; Wednesday 2026-11-25 is in the same week as Sunday the 29th', () {
    final now = DateTime(2026, 11, 24, 15); // Tuesday
    HomeworkGroup g(int id) => groupOf(parseHomework(data).firstWhere((h) => h.id == id), now);
    expect(g(3), HomeworkGroup.done);
    expect(g(1), HomeworkGroup.tomorrow);
    expect(g(2), HomeworkGroup.later); // Monday the 30th starts next week
    final yesterday = (id: 0, subject: '', teacher: '', text: '', due: DateTime(2026, 11, 23), done: false);
    expect(groupOf(yesterday, now), HomeworkGroup.overdue);
    expect(groupOf((id: 0, subject: '', teacher: '', text: '', due: DateTime(2026, 11, 29), done: false), now), HomeworkGroup.week);
    expect(nextMonday(DateTime(2026, 11, 29)), DateTime(2026, 11, 30)); // Sunday
  });
}
