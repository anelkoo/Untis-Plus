import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/db/app_database.dart';
import '../../core/network/webuntis_client.dart';
import '../auth/presentation/auth_providers.dart';
import '../timetable/data/timetable_repository.dart';
import '../timetable/domain/lesson.dart';

part 'absences.g.dart';

/// One absence from the class register. [status] is the school's excuse text, e.g.
/// "Arztbestätigung vorgelegt"; [lessons] is how many of my lessons it covers, null if the
/// timetable for those days could not be loaded.
typedef Absence = ({DateTime start, DateTime end, bool excused, String status, String reason, int? lessons});

/// Parses `/api/classreg/absences/students`, newest first. Entries that don't parse are skipped.
List<Absence> parseAbsences(Map<String, dynamic> json) => [
      for (final a in (json['data']?['absences'] as List?) ?? const []) ?_tryAbsence(a),
    ]..sort((a, b) => b.start.compareTo(a.start));

Absence? _tryAbsence(Object? a) {
  try {
    final m = a as Map;
    return (
      start: _at((m['startDate'] as num).toInt(), (m['startTime'] as num).toInt()),
      end: _at((m['endDate'] as num).toInt(), (m['endTime'] as num).toInt()),
      excused: m['isExcused'] == true,
      status: '${m['excuseStatus'] ?? ''}',
      reason: [m['reason'], m['text']].where((s) => s != null && '$s'.isNotEmpty).join(' · '),
      lessons: null,
    );
  } on Object {
    return null;
  }
}

// Same encoding as getTimetable: dates like 20261123, times like 755.
DateTime _at(int date, int hhmm) => DateTime(date ~/ 10000, date ~/ 100 % 100, date % 100, hhmm ~/ 100, hhmm % 100);

/// Lessons of mine that [a] overlaps; cancelled ones don't count.
int missedLessons(Absence a, List<Lesson> lessons) =>
    lessons.where((l) => l.status != .cancelled && l.start.isBefore(a.end) && a.start.isBefore(l.end)).length;

/// My absences this school year, each with the lessons it covers (from the timetable of those weeks).
Future<List<Absence>> loadAbsences(WebUntisClient client, TimetableRepository repo, DateTime now) async {
  final session = await client.session();
  var from = DateTime(now.month >= 9 ? now.year : now.year - 1, 9, 1);
  try {
    final year = await client.call('getCurrentSchoolyear') as Map;
    from = _at((year['startDate'] as num).toInt(), 0);
  } on Object {
    // Keeps the 1 September guess.
  }
  final json = await client.getRest('/WebUntis/api/classreg/absences/students', {
    'startDate': '${untisDate(from)}',
    'endDate': '${untisDate(now)}',
    'studentId': '${session.personId}',
    'excuseStatusId': '-1',
  });

  final weeks = <DateTime, List<Lesson>?>{};
  Future<List<Lesson>?> week(DateTime monday) async {
    if (weeks.containsKey(monday)) return weeks[monday];
    // Any stored copy will do (past weeks hardly change). Fetching only weeks never stored also
    // keeps this from refreshing a stored week without the change notifications.
    if (await repo.cached(me, monday) case final week?) return weeks[monday] = week.lessons;
    try {
      return weeks[monday] = (await repo.refresh(me, monday)).lessons;
    } on Object {
      return weeks[monday] = null;
    }
  }

  return [
    for (final a in parseAbsences((json as Map).cast<String, dynamic>()))
      (
        start: a.start,
        end: a.end,
        excused: a.excused,
        status: a.status,
        reason: a.reason,
        lessons: await () async {
          var count = 0;
          for (var m = mondayOf(a.start); !m.isAfter(a.end); m = DateTime(m.year, m.month, m.day + 7)) {
            final lessons = await week(m);
            if (lessons == null) return null;
            count += missedLessons(a, lessons);
          }
          return count;
        }(),
      ),
  ];
}

@riverpod
Future<List<Absence>> absences(Ref ref) async {
  final client = await ref.watch(authProvider.future);
  if (client == null) return const [];
  return loadAbsences(client, TimetableRepository(ref.watch(appDatabaseProvider), client), DateTime.now());
}
