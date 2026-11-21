import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untis_plus/core/db/app_database.dart';
import 'package:untis_plus/core/network/webuntis_client.dart';
import 'package:untis_plus/features/auth/domain/credentials.dart';
import 'package:untis_plus/features/auth/domain/school.dart';
import 'package:untis_plus/features/timetable/data/timetable_repository.dart';
import 'package:untis_plus/features/timetable/domain/lesson.dart';

import 'fake_server.dart';

const _creds = Credentials(
  school: School(server: 's.webuntis.com', loginName: 's', displayName: 'S'),
  username: 'max',
  password: 'secret',
);
final _monday = DateTime(2026, 11, 23);

void main() {
  late AppDatabase db;
  late FakeServer server;
  late DateTime now;
  late TimetableRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    server = FakeServer(schoolHandler);
    now = DateTime(2026, 11, 23, 7);
    repo = TimetableRepository(db, WebUntisClient(server.dio, _creds), now: () => now);
  });
  tearDown(() => db.close());

  Map<String, dynamic> lastOptions() => ((server.requests.lastWhere((r) => r.data is Map).data
          as Map)['params'] as Map)['options'] as Map<String, dynamic>;
  List<String> calls() => [for (final r in server.requests) r.data is Map ? (r.data as Map)['method'] as String : r.uri.path];

  test('fetches my week by person id, stores it, and reads it back offline', () async {
    expect(await repo.cached(me, _monday), isNull);
    final week = await repo.refresh(me, _monday);
    expect(week.lessons, hasLength(6));
    expect(lastOptions()['element'], {'id': 4711, 'type': 5});
    expect(lastOptions()['startDate'], 20261123);
    expect(lastOptions()['endDate'], 20261129);

    final cached = await repo.cached(me, _monday);
    expect(cached!.lessons, week.lessons);
    expect(cached.fetchedAt, now);
  });

  test('does not ask the server again within minAge', () async {
    await repo.refresh(me, _monday);
    final count = server.requests.length;
    now = now.add(const Duration(seconds: 30));
    await repo.refresh(me, _monday);
    expect(server.requests, hasLength(count));
    now = now.add(const Duration(minutes: 1));
    await repo.refresh(me, _monday);
    expect(calls().skip(count), contains('getTimetable'));
  });

  test('a teacher has a separate cache entry', () async {
    await repo.refresh(me, _monday);
    expect(await repo.cached((type: 2, id: 42), _monday), isNull);
    await repo.refresh((type: 2, id: 42), _monday);
    expect(lastOptions()['element'], {'id': 42, 'type': 2});
  });

  test('marks my exams from /api/exams, keeps them offline, not on other timetables', () async {
    final week = await repo.refresh(me, _monday);
    final exam = week.lessons.firstWhere((l) => l.id == 101);
    expect(exam.status, LessonStatus.exam);
    expect(exam.examType, 'SMÜP');
    final rest = server.requests.firstWhere((r) => r.uri.path == '/WebUntis/api/exams');
    expect(rest.uri.queryParameters['startDate'], '20261123');
    expect(rest.headers['Authorization'], 'Bearer header.payload.signature');
    expect((await repo.cached(me, _monday))!.lessons.firstWhere((l) => l.id == 101).status, LessonStatus.exam);

    final before = calls().length;
    final teacher = await repo.refresh((type: 2, id: 42), _monday);
    expect(calls().skip(before), isNot(contains('/WebUntis/api/exams')));
    expect(teacher.lessons.firstWhere((l) => l.id == 101).status, LessonStatus.regular);
  });

  test('a failing exam endpoint still gives the timetable', () async {
    server = FakeServer((m, r) => m == '/WebUntis/api/exams' ? throw Exception('down') : schoolHandler(m, r));
    repo = TimetableRepository(db, WebUntisClient(server.dio, _creds), now: () => now);
    final week = await repo.refresh(me, _monday);
    expect(week.lessons, hasLength(6));
    expect(week.lessons.first.status, LessonStatus.regular);
  });

  test('mondayOf', () {
    expect(mondayOf(DateTime(2026, 11, 29, 23)), _monday);
    expect(mondayOf(_monday), _monday);
  });
}
