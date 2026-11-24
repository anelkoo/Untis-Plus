import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../../core/network/webuntis_client.dart';
import '../../homework/homework.dart';
import '../domain/lesson.dart';
import '../domain/timetable_diff.dart';

/// Whose timetable: [me] or another element, e.g. a teacher `(type: 2, id: 42)`.
typedef TimetableTarget = ({int type, int id});
const TimetableTarget me = (type: 0, id: 0);

DateTime mondayOf(DateTime d) => DateTime(d.year, d.month, d.day - (d.weekday - 1));
int untisDate(DateTime d) => d.year * 10000 + d.month * 100 + d.day;
String isoDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

class Week {
  const Week(this.lessons, this.fetchedAt, [this.refreshError, this.holidays = const []]);

  final List<Lesson> lessons;
  final DateTime fetchedAt;

  /// Holidays that touch this week; only filled for my own timetable.
  final List<Holiday> holidays;

  /// Set when the cached copy is shown because fetching a newer one failed.
  final Object? refreshError;
}

class TimetableRepository {
  TimetableRepository(this._db, this._client, {DateTime Function()? now, this.onChanges})
      : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final WebUntisClient _client;
  final DateTime Function() _now;

  /// Called with what changed in my own timetable since the stored copy, if anything did.
  final Future<Object?> Function(List<LessonChange> changes)? onChanges;

  static String _key(TimetableTarget t) => '${t.type}:${t.id}';

  /// The stored week, without any network call.
  Future<Week?> cached(TimetableTarget target, DateTime monday) async {
    final row = await (_db.select(_db.cachedWeeks)
          ..where((r) => r.target.equals(_key(target)) & r.monday.equals(untisDate(monday))))
        .getSingleOrNull();
    if (row == null) return null;
    final data = jsonDecode(row.json);
    // Rows from before exams were cached hold only the period list.
    return data is List
        ? Week(parseLessons(data), row.fetchedAt)
        : Week(
            parseLessons(data['periods'] as List, data['exams'] as List),
            row.fetchedAt,
            null,
            parseHolidays(data['holidays'] as List? ?? const []),
          );
  }

  /// Fetches the week from the server unless the stored copy is younger than [minAge], so
  /// repeated opens and refreshes don't hit the school server.
  Future<Week> refresh(
    TimetableTarget target,
    DateTime monday, {
    Duration minAge = const Duration(minutes: 1),
  }) async {
    final old = await cached(target, monday);
    if (old != null && _now().difference(old.fetchedAt) < minAge) return old;

    final session = await _client.session();
    final element = target == me
        ? {'id': session.personId, 'type': session.personType}
        : {'id': target.id, 'type': target.type};
    // Before getTimetable, so the timetable stays the last JSON-RPC call (tests read it).
    final holidays = target == me ? await _holidays(monday) : const [];
    const fields = ['id', 'name', 'longname'];
    final raw = await _client.call('getTimetable', {
      'options': {
        'element': element,
        'startDate': untisDate(monday),
        'endDate': untisDate(monday.add(const Duration(days: 6))),
        'showLsText': true,
        'showSubstText': true,
        'showInfo': true,
        // Names inline, so no master-data calls (students often may not make those).
        'klasseFields': fields,
        'teacherFields': fields,
        'subjectFields': fields,
        'roomFields': fields,
      },
    }) as List;
    // /api/exams lists the signed-in user's exams, so they only belong on their own timetable.
    final exams = target == me ? await _exams(monday) : const [];

    final now = _now();
    await _db.into(_db.cachedWeeks).insertOnConflictUpdate(CachedWeeksCompanion.insert(
          target: _key(target),
          monday: untisDate(monday),
          json: jsonEncode({'periods': raw, 'exams': exams, 'holidays': holidays}),
          fetchedAt: now,
        ));
    final fresh = Week(parseLessons(raw, exams), now, null, parseHolidays(holidays));
    // No stored copy means a first fetch: nothing to compare, so no flood of notifications.
    if (old != null && target == me && onChanges != null) {
      final changes = diffLessons(old.lessons, fresh.lessons, now);
      if (changes.isNotEmpty) await onChanges!(changes);
    }
    return fresh;
  }

  /// My exams from today on, stored as one row so the widgets can read them offline.
  static const _examsKey = 'exams';

  /// The stored exams list from [refreshExams], without any network call.
  Future<List<Exam>> cachedExams() async {
    final row = await (_db.select(_db.cachedWeeks)..where((r) => r.target.equals(_examsKey))).getSingleOrNull();
    return row == null ? const [] : parseExams(jsonDecode(row.json) as List);
  }

  /// Fetches my exams for the next half year, at most every [minAge]. Best effort: on a
  /// failure the stored list stays.
  Future<void> refreshExams({Duration minAge = const Duration(hours: 1)}) async {
    final row = await (_db.select(_db.cachedWeeks)..where((r) => r.target.equals(_examsKey))).getSingleOrNull();
    final now = _now();
    if (row != null && now.difference(row.fetchedAt) < minAge) return;
    try {
      final res = await _client.getRest('/WebUntis/api/exams', {
        'startDate': '${untisDate(now)}',
        'endDate': '${untisDate(now.add(const Duration(days: 183)))}',
        'klasseId': '-1',
        'withGrades': 'false',
      });
      await _db.into(_db.cachedWeeks).insertOnConflictUpdate(CachedWeeksCompanion.insert(
            target: _examsKey,
            monday: 0,
            json: jsonEncode(res['data']['exams'] as List),
            fetchedAt: now,
          ));
    } on Object {
      // See above.
    }
  }

  static const _homeworkKey = 'homework';

  /// The stored homework from [refreshHomework]; null if it was never fetched.
  Future<List<Homework>?> cachedHomework() async {
    final row = await (_db.select(_db.cachedWeeks)..where((r) => r.target.equals(_homeworkKey))).getSingleOrNull();
    return row == null ? null : parseHomework(jsonDecode(row.json) as Map);
  }

  /// Fetches my homework (a week back, two months ahead) unless the stored copy is younger than
  /// [minAge]. Unlike exams this throws, so the screen can say the school doesn't share it.
  Future<void> refreshHomework({Duration minAge = const Duration(hours: 1)}) async {
    final row = await (_db.select(_db.cachedWeeks)..where((r) => r.target.equals(_homeworkKey))).getSingleOrNull();
    final now = _now();
    if (row != null && now.difference(row.fetchedAt) < minAge) return;
    final res = await _client.getRest('/WebUntis/api/homeworks/lessons', {
      'startDate': '${untisDate(now.subtract(const Duration(days: 7)))}',
      'endDate': '${untisDate(now.add(const Duration(days: 60)))}',
    });
    await _db.into(_db.cachedWeeks).insertOnConflictUpdate(CachedWeeksCompanion.insert(
          target: _homeworkKey,
          monday: 0,
          json: jsonEncode(res['data']),
          fetchedAt: now,
        ));
  }

  /// This account's exams in the week. Best effort: without them the timetable is still right,
  /// only exams show as normal lessons.
  Future<List<dynamic>> _exams(DateTime monday) async {
    try {
      final res = await _client.getRest('/WebUntis/api/exams', {
        'startDate': '${untisDate(monday)}',
        'endDate': '${untisDate(monday.add(const Duration(days: 6)))}',
        'klasseId': '-1',
        'withGrades': 'false',
      });
      return res['data']['exams'] as List;
    } on Object {
      return const [];
    }
  }

  /// The raw holidays overlapping [monday]'s week. Best effort, like [_exams].
  Future<List<dynamic>> _holidays(DateTime monday) async {
    try {
      final from = untisDate(monday), to = untisDate(monday.add(const Duration(days: 6)));
      return [
        for (final h in await _client.call('getHolidays') as List)
          if ((h['startDate'] as num) <= to && (h['endDate'] as num) >= from) h,
      ];
    } on Object {
      return const [];
    }
  }

  static const _classesKey = 'classes';

  /// Every class's lessons in the week, from the cache; null if never loaded.
  Future<Week?> cachedClasses(DateTime monday) async {
    final row = await (_db.select(_db.cachedWeeks)
          ..where((r) => r.target.equals(_classesKey) & r.monday.equals(untisDate(monday))))
        .getSingleOrNull();
    return row == null ? null : Week(_parseClasses(jsonDecode(row.json) as Map), row.fetchedAt);
  }

  /// Loads every class's week through the REST view, the only place students see other
  /// classes' teachers; teacher timetables are filtered from it. That is one request per
  /// class, so it only runs on demand and when the stored copy is older than [minAge].
  Future<Week> refreshClasses(DateTime monday, {Duration minAge = const Duration(hours: 6)}) async {
    final old = await cachedClasses(monday);
    if (old != null && _now().difference(old.fetchedAt) < minAge) return old;

    final config = await _client.getRest('/WebUntis/api/public/timetable/weekly/pageconfig', {
      'type': '1',
      'date': isoDate(monday),
    });
    final classes = [
      for (final e in config['data']['elements'] as List)
        {'id': e['id'], 'name': e['name'], 'longName': e['longName'] ?? ''},
    ];
    final weeks = <String, dynamic>{};
    // A few at a time, to go easy on the school server.
    for (var i = 0; i < classes.length; i += 4) {
      await Future.wait([
        for (final c in classes.skip(i).take(4))
          _client.getRest('/WebUntis/api/rest/view/v1/timetable/entries', {
            'start': isoDate(monday),
            'end': isoDate(monday.add(const Duration(days: 6))),
            'format': '1',
            'resourceType': 'CLASS',
            'resources': '${c['id']}',
            'timetableType': 'STANDARD',
          }).then((json) => weeks['${c['id']}'] = json),
      ]);
    }

    final data = {'classes': classes, 'weeks': weeks};
    final now = _now();
    await _db.into(_db.cachedWeeks).insertOnConflictUpdate(CachedWeeksCompanion.insert(
          target: _classesKey,
          monday: untisDate(monday),
          json: jsonEncode(data),
          fetchedAt: now,
        ));
    return Week(_parseClasses(data), now);
  }

  static List<Lesson> _parseClasses(Map<dynamic, dynamic> data) => mergeClassLessons([
        for (final c in data['classes'] as List)
          ...parseRestWeek(
            (data['weeks']['${c['id']}'] as Map).cast<String, dynamic>(),
            Named(id: (c['id'] as num).toInt(), name: '${c['name']}', longName: '${c['longName']}'),
          ),
      ]);
}
