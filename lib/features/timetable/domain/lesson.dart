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
    /// The school's exam type, e.g. "SMÜP", when an exam falls on this lesson.
    @Default('') String examType,
  }) = _Lesson;
}

/// Parses a raw `getTimetable` result, sorted by start. A period that doesn't parse is
/// skipped so one odd entry can't hide the whole week. getTimetable doesn't mark exams, so
/// lessons overlapping an entry of [exams] (from `/api/exams`) become exams.
List<Lesson> parseLessons(List<dynamic> periods, [List<dynamic> exams = const []]) {
  final spans = [for (final e in exams) ?_tryExam(e)];
  return [
    for (final p in periods)
      if (_tryParse(p) case final lesson?)
        switch (spans.where((e) => e.start.isBefore(lesson.end) && lesson.start.isBefore(e.end))) {
          final hits when hits.isNotEmpty && lesson.status != .cancelled =>
            lesson.copyWith(status: .exam, examType: hits.first.type),
          _ => lesson,
        },
  ]..sort((a, b) => a.start.compareTo(b.start));
}

({DateTime start, DateTime end, String type})? _tryExam(Object? e) {
  try {
    final m = e as Map;
    final date = (m['examDate'] as num).toInt();
    return (
      start: _at(date, (m['startTime'] as num).toInt()),
      end: _at(date, (m['endTime'] as num).toInt()),
      type: '${m['examType'] ?? ''}',
    );
  } on Object {
    return null;
  }
}

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

/// A school holiday from `getHolidays`, by day: [start] and [end] are both included.
typedef Holiday = ({String name, DateTime start, DateTime end});

/// Parses a raw `getHolidays` result, skipping entries that don't parse.
List<Holiday> parseHolidays(List<dynamic> raw) => [for (final h in raw) ?_tryHoliday(h)];

Holiday? _tryHoliday(Object? h) {
  try {
    final m = h as Map;
    final long = '${m['longName'] ?? ''}';
    return (
      name: long.isNotEmpty ? long : '${m['name'] ?? ''}',
      start: _at((m['startDate'] as num).toInt(), 0),
      end: _at((m['endDate'] as num).toInt(), 0),
    );
  } on Object {
    return null;
  }
}

/// The holiday that covers [day], if any.
Holiday? holidayOn(List<Holiday> holidays, DateTime day) {
  final d = DateTime(day.year, day.month, day.day);
  return holidays.where((h) => !d.isBefore(h.start) && !d.isAfter(h.end)).firstOrNull;
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

/// Parses the REST timetable view (`/api/rest/view/v1/timetable/entries`) of one class. Unlike
/// getTimetable it is open to students for other classes and includes teachers, which is
/// what teacher timetables are built from. [klass] is added to every lesson's classes.
List<Lesson> parseRestWeek(Map<String, dynamic> json, Named klass) => [
      for (final day in (json['days'] as List?) ?? const [])
        for (final entry in (day['gridEntries'] as List?) ?? const []) ?_tryParseRest(entry, klass),
    ]..sort((a, b) => a.start.compareTo(b.start));

Lesson? _tryParseRest(Object? e, Named klass) {
  try {
    final m = (e as Map).cast<String, dynamic>();
    final byType = <String, List<Named>>{};
    for (var i = 1; i <= 7; i++) {
      for (final p in (m['position$i'] as List?) ?? const []) {
        final current = p['current'] as Map?;
        final removed = p['removed'] as Map?;
        final shown = current ?? removed!;
        byType.putIfAbsent('${shown['type']}', () => []).add(Named(
              id: 0,
              name: '${shown['shortName'] ?? ''}',
              longName: '${shown['longName'] ?? ''}',
              original: current != null && removed != null ? '${removed['shortName'] ?? ''}' : null,
            ));
      }
    }
    final classes = byType['CLASS'] ?? [];
    final duration = m['duration'] as Map;
    final status = '${m['status']}';
    final type = '${m['type']}';
    final replaced = byType.values.expand((l) => l).any((n) => n.original != null);
    return Lesson(
      id: ((m['ids'] as List).first as num).toInt(),
      start: DateTime.parse('${duration['start']}'),
      end: DateTime.parse('${duration['end']}'),
      status: switch (status) {
        'CANCELLED' => .cancelled,
        _ when type == 'EXAM' => .exam,
        _ when replaced => .substitution,
        'REGULAR' when type == 'NORMAL_TEACHING_PERIOD' => .regular,
        _ => .irregular,
      },
      subjects: byType['SUBJECT'] ?? const [],
      teachers: byType['TEACHER'] ?? const [],
      rooms: byType['ROOM'] ?? const [],
      classes: [klass, ...classes.where((c) => c.name != klass.name)],
      lessonText: '${m['lessonText'] ?? ''}',
      substitutionText: '${m['substitutionText'] ?? ''}',
      info: '${m['lessonInfo'] ?? ''}',
    );
  } on Object {
    return null;
  }
}

/// Joins the weeks of all classes. A lesson shared by several classes (same time, subject,
/// teachers and rooms) appears once, listing all of them.
List<Lesson> mergeClassLessons(Iterable<Lesson> lessons) {
  final merged = <String, Lesson>{};
  for (final l in lessons) {
    final key = [l.start, l.end, joinNamesOf(l.subjects), joinNamesOf(l.teachers), joinNamesOf(l.rooms)].join('|');
    final seen = merged[key];
    merged[key] = seen == null
        ? l
        : seen.copyWith(classes: [...seen.classes, ...l.classes.where((c) => !seen.classes.any((s) => s.name == c.name))]);
  }
  return merged.values.toList()..sort((a, b) => a.start.compareTo(b.start));
}

String joinNamesOf(List<Named> names) => names.map((n) => n.name).join(',');
