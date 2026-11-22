import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:untis_plus/app.dart';
import 'package:untis_plus/core/db/app_database.dart';
import 'package:untis_plus/features/auth/data/credentials_store.dart';
import 'package:untis_plus/features/auth/domain/credentials.dart';
import 'package:untis_plus/features/auth/domain/school.dart';
import 'package:untis_plus/features/auth/presentation/auth_providers.dart';
import 'package:untis_plus/features/timetable/presentation/timetable_screen.dart' as screen;

import 'fake_server.dart';

class _StoredStore implements CredentialsStore {
  @override
  Future<Credentials?> read() async => const Credentials(
        school: School(server: 's.webuntis.com', loginName: 's', displayName: 'S'),
        username: 'max',
        password: 'secret',
      );
  @override
  Future<void> write(Credentials c) async {}
  @override
  Future<void> delete() async {}
}

/// Opens the app signed in, in German, on Monday 23.11.2026 at 08:00 (the fixture week).
Future<FakeServer> _open(WidgetTester tester, {required double width}) async {
  tester.platformDispatcher.localesTestValue = const [Locale('de', 'AT')];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  screen.clock = () => DateTime(2026, 11, 23, 8);
  addTearDown(() => screen.clock = DateTime.now);

  final server = FakeServer(schoolHandler);
  final db = AppDatabase(NativeDatabase.memory());
  addTearDown(db.close);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      credentialsStoreProvider.overrideWithValue(_StoredStore()),
      dioProvider.overrideWithValue(server.dio),
      appDatabaseProvider.overrideWithValue(db),
    ],
    child: const UntisPlusApp(),
  ));
  await _settle(tester);
  return server;
}

// Drift and the fake server complete outside the fake clock.
Future<void> _settle(WidgetTester tester) async {
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
  await tester.pumpAndSettle();
}

int _startDate(FakeServer server) =>
    (((server.requests.lastWhere((r) => r.data is Map).data as Map)['params'] as Map)['options'] as Map)['startDate']
        as int;

void main() {
  testWidgets('wide screens open the week grid; tapping a lesson shows its details', (tester) async {
    final server = await _open(tester, width: 1000);
    expect(_startDate(server), 20261123);
    expect(find.textContaining('Stand'), findsOneWidget);
    expect(find.textContaining('AM', findRichText: true), findsOneWidget); // Tuesday
    expect(find.bySemanticsLabel(RegExp(r'^Deutsch, 07:55–08:45, E12, HUB, Prüfung$')), findsOneWidget);
    expect(find.textContaining('E12\nHUB', findRichText: true), findsOneWidget);

    await tester.tap(find.bySemanticsLabel(RegExp('^Deutsch')));
    await tester.pumpAndSettle();
    expect(find.text('Buch mitnehmen'), findsOneWidget);
    expect(find.text('Prüfung · SMÜP'), findsOneWidget);
    expect(find.text('HUB (Huber)'), findsOneWidget);
  });

  testWidgets('phones open today as a list with Now/Next; arrows and swipes move by day', (tester) async {
    final server = await _open(tester, width: 400);
    expect(find.text('Jetzt'), findsOneWidget);
    expect(find.text('Danach'), findsOneWidget);
    expect(find.text('Englisch'), findsNWidgets(3)); // Next card, substitution and exam rows
    expect(find.text('Entfällt'), findsOneWidget);

    await tester.tap(find.byTooltip('Nächster Tag'));
    await _settle(tester);
    expect(find.text('Angewandte Mathematik'), findsOneWidget);
    expect(find.text('Jetzt'), findsNothing);

    await tester.tap(find.text('Woche'));
    await _settle(tester);
    await tester.tap(find.byTooltip('Nächste Woche'));
    await _settle(tester);
    expect(_startDate(server), 20261130);
  });
}
