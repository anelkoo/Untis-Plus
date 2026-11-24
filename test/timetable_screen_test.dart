import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untis_plus/core/settings.dart';
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
Future<FakeServer> _open(WidgetTester tester, {required double width, DateTime? now}) async {
  tester.platformDispatcher.localesTestValue = const [Locale('de', 'AT')];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  screen.clock = () => now ?? DateTime(2026, 11, 23, 8);
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

  testWidgets('keyboard: D and arrow right go a week forward, S jumps a week', (tester) async {
    final server = await _open(tester, width: 1000);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyD);
    await _settle(tester);
    expect(_startDate(server), 20261130);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await _settle(tester);
    expect(_startDate(server), 20261207);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
    await _settle(tester);
    expect(_startDate(server), 20261214);
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

  testWidgets('teacher search: star a favourite, open their week with classes instead of teachers',
      (tester) async {
    await _open(tester, width: 1000, now: DateTime(2026, 11, 16, 8));
    await tester.tap(find.byTooltip('Lehrer suchen'));
    await _settle(tester);
    expect(find.text('Moser'), findsOneWidget);
    expect(find.text('Leitner'), findsNothing); // replaced, not teaching

    await tester.tap(find.descendant(of: find.widgetWithText(ListTile, 'Moser'), matching: find.byTooltip('Zu Favoriten')));
    await _settle(tester);
    expect(find.text('Favoriten'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'jed');
    await tester.pumpAndSettle();
    expect(find.text('Moser'), findsNothing);
    await tester.tap(find.text('Jedinger'));
    await _settle(tester);

    expect(find.text('Jedinger (JEDA)'), findsOneWidget);
    expect(find.textContaining('1M\n1AHIT, 2AHIT', findRichText: true), findsOneWidget);
    expect(find.textContaining('E1', findRichText: true), findsNothing); // Moser's lesson

    await tester.tap(find.byTooltip('Mein Stundenplan'));
    await _settle(tester);
    expect(find.text('Jedinger (JEDA)'), findsNothing);
  });

  testWidgets('room search: open a room\'s week, filtered from all classes', (tester) async {
    await _open(tester, width: 1000, now: DateTime(2026, 11, 16, 8));
    await tester.tap(find.byTooltip('Raum suchen'));
    await _settle(tester);
    expect(find.text('1M'), findsOneWidget);
    expect(find.byTooltip('Zu Favoriten'), findsNothing);

    await tester.enterText(find.byType(TextField), 'turn');
    await tester.pumpAndSettle();
    expect(find.text('1M'), findsNothing);
    await tester.tap(find.text('TURN2'));
    await _settle(tester);

    expect(find.widgetWithText(InputChip, 'TURN2'), findsOneWidget);
    expect(find.textContaining('BSPK', findRichText: true), findsOneWidget);
    expect(find.textContaining('E1', findRichText: true), findsNothing); // in room 1M
  });

  testWidgets('day view: the running lesson shows progress, finished ones fade', (tester) async {
    await _open(tester, width: 400, now: DateTime(2026, 11, 23, 8, 20)); // Deutsch 07:55-08:45 is running
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    await tester.pumpWidget(const SizedBox()); // fresh app for the second clock
    await _open(tester, width: 400, now: DateTime(2026, 11, 23, 23));
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.byType(Opacity), findsWidgets);
  });

  testWidgets('the bottom bar opens the homework and tests tabs', (tester) async {
    await _open(tester, width: 400);
    for (final tab in ['Hausübung', 'Tests']) {
      await tester.tap(find.text(tab));
      await tester.pumpAndSettle();
      expect(find.text(tab), findsNWidgets(2)); // bar label and app bar title
    }
  });

  testWidgets('the menu has settings and sign out, no test notification', (tester) async {
    await _open(tester, width: 400);
    await tester.tap(find.text('Mehr'));
    await tester.pumpAndSettle();
    expect(find.text('Testbenachrichtigung senden'), findsNothing);
    expect(find.text('Einstellungen'), findsOneWidget);
    expect(find.text('Abmelden'), findsOneWidget);
  });

  testWidgets('settings: a picked colour replaces the default', (tester) async {
    await _open(tester, width: 400);
    await tester.tap(find.text('Mehr'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Einstellungen'));
    await _settle(tester);
    await tester.tap(find.text('Raumänderung'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fertig'));
    await tester.pumpAndSettle();
    expect(colors.value.keys, [Slot.roomChange]);
    colors.value = {};
  });

  testWidgets('settings: one switch picks the modern lesson design for day and week', (tester) async {
    await _open(tester, width: 400);
    await tester.tap(find.text('Mehr'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Einstellungen'));
    await _settle(tester);
    expect(find.textContaining('Tagesansicht'), findsNothing);
    expect(find.textContaining('Wochenansicht'), findsNothing);
    await tester.tap(find.text('Modernes Design für Stunden (Streifen statt Farbfläche)'));
    await tester.pumpAndSettle();
    expect(look.value, {Look.modernCards});
    look.value = {};
  });

  testWidgets('the menu opens the absences with missed lessons counted', (tester) async {
    await _open(tester, width: 360); // narrow phone: the app bar with four actions must still fit
    await tester.tap(find.text('Mehr'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fehlstunden'));
    await _settle(tester);
    expect(find.text('4 Fehlstunden, davon 1 nicht entschuldigt'), findsOneWidget);
    expect(find.textContaining('1 Stunde · Nicht entschuldigt · Verschlafen'), findsOneWidget);
    expect(find.textContaining('3 Stunden · Arztbestätigung vorgelegt'), findsOneWidget);
  });
}
