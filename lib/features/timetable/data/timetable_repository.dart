import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../../core/network/webuntis_client.dart';
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
  const Week(this.lessons, this.fetchedAt, [this.refreshError]);

  final List<Lesson> lessons;
  final DateTime fetchedAt;

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
  final Future<void> Function(List<LessonChange> changes)? onChanges;

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
        : Week(parseLessons(data['periods'] as List, data['exams'] as List), row.fetchedAt);
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
          json: jsonEncode({'periods': raw, 'exams': exams}),
          fetchedAt: now,
        ));
    final fresh = Week(parseLessons(raw, exams), now);
    // No stored copy means a first fetch: nothing to compare, so no flood of notifications.
    if (old != null && target == me && onChanges != null) {
      final changes = diffLessons(old.lessons, fresh.lessons, now);
      if (changes.isNotEmpty) await onChanges!(changes);
    }
    return fresh;
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
