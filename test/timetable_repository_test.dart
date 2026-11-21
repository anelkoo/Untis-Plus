import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untis_plus/core/db/app_database.dart';
import 'package:untis_plus/core/network/webuntis_client.dart';
import 'package:untis_plus/features/auth/domain/credentials.dart';
import 'package:untis_plus/features/auth/domain/school.dart';
import 'package:untis_plus/features/timetable/data/timetable_repository.dart';

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
    server = FakeServer((method, _) =>
        method == 'authenticate' ? fixture('authenticate_ok.json') : fixture('getTimetable_week.json'));
    now = DateTime(2026, 11, 23, 7);
    repo = TimetableRepository(db, WebUntisClient(server.dio, _creds), now: () => now);
  });
  tearDown(() => db.close());

  Map<String, dynamic> lastOptions() =>
      ((server.requests.last.data as Map)['params'] as Map)['options'] as Map<String, dynamic>;

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
    final calls = server.requests.length;
    now = now.add(const Duration(seconds: 30));
    await repo.refresh(me, _monday);
    expect(server.requests, hasLength(calls));
    now = now.add(const Duration(minutes: 1));
    await repo.refresh(me, _monday);
    expect(server.requests, hasLength(calls + 1));
  });

  test('a teacher has a separate cache entry', () async {
    await repo.refresh(me, _monday);
    expect(await repo.cached((type: 2, id: 42), _monday), isNull);
    await repo.refresh((type: 2, id: 42), _monday);
    expect(lastOptions()['element'], {'id': 42, 'type': 2});
  });

  test('mondayOf', () {
    expect(mondayOf(DateTime(2026, 11, 29, 23)), _monday);
    expect(mondayOf(_monday), _monday);
  });
}
