import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../../core/network/webuntis_client.dart';
import '../domain/lesson.dart';

/// Whose timetable: [me] or another element, e.g. a teacher `(type: 2, id: 42)`.
typedef TimetableTarget = ({int type, int id});
const TimetableTarget me = (type: 0, id: 0);

DateTime mondayOf(DateTime d) => DateTime(d.year, d.month, d.day - (d.weekday - 1));
int untisDate(DateTime d) => d.year * 10000 + d.month * 100 + d.day;

class Week {
  const Week(this.lessons, this.fetchedAt, [this.refreshError]);

  final List<Lesson> lessons;
  final DateTime fetchedAt;

  /// Set when the cached copy is shown because fetching a newer one failed.
  final Object? refreshError;
}

class TimetableRepository {
  TimetableRepository(this._db, this._client, {DateTime Function()? now}) : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final WebUntisClient _client;
  final DateTime Function() _now;

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
    return Week(parseLessons(raw, exams), now);
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
}
