import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untis_plus/core/db/app_database.dart';
import 'package:untis_plus/core/network/webuntis_client.dart';
import 'package:untis_plus/features/absences/absences.dart';
import 'package:untis_plus/features/auth/domain/credentials.dart';
import 'package:untis_plus/features/auth/domain/school.dart';
import 'package:untis_plus/features/timetable/data/timetable_repository.dart';

import 'fake_server.dart';

const _creds = Credentials(
  school: School(server: 's.webuntis.com', loginName: 's', displayName: 'S'),
  username: 'max',
  password: 'secret',
);

void main() {
  test('parses absences newest first and skips broken entries', () {
    final list = parseAbsences((jsonDecode(fixture('absences.json')) as Map).cast<String, dynamic>());
    expect(list, hasLength(2));
    expect(list.first.start, DateTime(2026, 11, 24, 8));
    expect(list.first.excused, isFalse);
    expect(list.first.reason, 'Verschlafen');
    expect(list.last.status, 'Arztbestätigung vorgelegt');
    expect(list.last.end, DateTime(2026, 11, 23, 12));
  });

  test('counts the lessons each absence covers, not cancelled ones, for my student id', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final server = FakeServer(schoolHandler);
    final client = WebUntisClient(server.dio, _creds);
    final list = await loadAbsences(client, TimetableRepository(db, client), DateTime(2026, 11, 25));

    // 24.11. 08:00–11:00: AM. 23.11. 07:00–12:00: D, E, E (the cancelled lesson doesn't count).
    expect([for (final a in list) a.lessons], [1, 3]);
    final query = server.requests.lastWhere((r) => r.uri.path.endsWith('/absences/students')).uri.queryParameters;
    expect(query['startDate'], '20260914');
    expect(query['studentId'], '4711');
  });
}
