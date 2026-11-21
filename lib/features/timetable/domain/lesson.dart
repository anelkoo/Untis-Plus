import 'package:freezed_annotation/freezed_annotation.dart';

part 'lesson.freezed.dart';

enum LessonStatus { regular, cancelled, substitution, irregular, exam }

/// A class, teacher, subject or room. [original] is set when it replaces another one
/// (WebUntis `orgid`/`orgname`), e.g. the teacher who was planned before a substitution.
@freezed
abstract class Named with _$Named {
  const factory Named({
    required int id,
    @Default('') String name,
    @Default('') String longName,
    String? original,
  }) = _Named;
}

@freezed
abstract class Lesson with _$Lesson {
  const factory Lesson({
    required int id,
    required DateTime start,
    required DateTime end,
    @Default(LessonStatus.regular) LessonStatus status,
    @Default([]) List<Named> subjects,
    @Default([]) List<Named> teachers,
    @Default([]) List<Named> rooms,
    @Default([]) List<Named> classes,
    @Default('') String lessonText,
    @Default('') String substitutionText,
    @Default('') String info,
  }) = _Lesson;
}

/// Parses a raw `getTimetable` result, sorted by start. A period that doesn't parse is
/// skipped so one odd entry can't hide the whole week.
List<Lesson> parseLessons(List<dynamic> periods) =>
    [for (final p in periods) ?_tryParse(p)]..sort((a, b) => a.start.compareTo(b.start));

Lesson? _tryParse(Object? p) {
  try {
    return _parse((p as Map).cast<String, dynamic>());
  } on Object {
    return null;
  }
}

Lesson _parse(Map<String, dynamic> p) {
  final date = (p['date'] as num).toInt();
  final teachers = _names(p['te']);
  final rooms = _names(p['ro']);
  final subjects = _names(p['su']);
  final replaced = [...teachers, ...rooms, ...subjects].any((n) => n.original != null);
  return Lesson(
    id: (p['id'] as num).toInt(),
    start: _at(date, (p['startTime'] as num).toInt()),
    end: _at(date, (p['endTime'] as num).toInt()),
    status: switch (p['code']) {
      'cancelled' => .cancelled,
      _ when p['lstype'] == 'ex' => .exam,
      _ when replaced => .substitution,
      'irregular' => .irregular,
      _ => .regular,
    },
    subjects: subjects,
    teachers: teachers,
    rooms: rooms,
    classes: _names(p['kl']),
    lessonText: '${p['lstext'] ?? ''}',
    substitutionText: '${p['substText'] ?? ''}',
    info: '${p['info'] ?? ''}',
  );
}

/// WebUntis dates are ints like 20261123 and times ints like 755 (07:55). Local time.
DateTime _at(int date, int hhmm) =>
    DateTime(date ~/ 10000, date ~/ 100 % 100, date % 100, hhmm ~/ 100, hhmm % 100);

List<Named> _names(Object? list) => [
      for (final e in (list as List?) ?? const [])
        Named(
          id: (e['id'] as num).toInt(),
          name: '${e['name'] ?? ''}',
          longName: '${e['longname'] ?? ''}',
          original: e['orgid'] == null ? null : '${e['orgname'] ?? ''}',
        ),
    ];
