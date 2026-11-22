import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untis_plus/core/db/app_database.dart';
import 'package:untis_plus/core/network/webuntis_client.dart';
import 'package:untis_plus/features/auth/domain/credentials.dart';
import 'package:untis_plus/features/auth/domain/school.dart';
import 'package:untis_plus/features/export/export_calendar.dart';
import 'package:untis_plus/features/timetable/data/timetable_repository.dart';

import 'fake_server.dart';

const _creds = Credentials(
  school: School(server: 's.webuntis.com', loginName: 's', displayName: 'S'),
  username: 'max',
  password: 'secret',
);

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  List<int> startDates(FakeServer s) => [
        for (final r in s.requests)
          if (r.data is Map && (r.data as Map)['method'] == 'getTimetable')
            ((r.data as Map)['params'] as Map)['options']['startDate'] as int,
      ];

  test('loads this week and the next three', () async {
    final server = FakeServer(schoolHandler);
    final lessons = await exportLessons(TimetableRepository(db, WebUntisClient(server.dio, _creds)), DateTime(2026, 11, 25));
    expect(startDates(server), [20261123, 20261130, 20261207, 20261214]);
    expect(lessons, hasLength(4 * 6)); // the fixture week is returned for every week
  });

  test('offline it uses the cache, and fails only without the current week', () async {
    final online = FakeServer(schoolHandler);
    await TimetableRepository(db, WebUntisClient(online.dio, _creds)).refresh(me, DateTime(2026, 11, 23));

    final offline = FakeServer((_, r) => throw DioException.connectionError(requestOptions: r, reason: 'offline'));
    final repo = TimetableRepository(db, WebUntisClient(offline.dio, _creds), now: () => DateTime(2026, 11, 25, 12));
    expect(await exportLessons(repo, DateTime(2026, 11, 25)), hasLength(6));
    expect(exportLessons(repo, DateTime(2027, 1, 13)), throwsA(anything));
  });
}
