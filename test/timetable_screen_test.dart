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

void main() {
  testWidgets('a stored login opens the week list, in German', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('de', 'AT')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    final server = FakeServer((method, _) =>
        method == 'authenticate' ? fixture('authenticate_ok.json') : fixture('getTimetable_week.json'));
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
    // Drift and the fake server complete outside the fake clock.
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pumpAndSettle();

    expect(find.textContaining('Stand'), findsOneWidget);
    expect(find.textContaining('Deutsch'), findsNothing); // short names are shown
    expect(find.textContaining('Mo 23.11. 07:55–08:45 · D'), findsOneWidget);
    expect(find.textContaining('Entfällt'), findsOneWidget);
    expect(find.textContaining('MUE (HUB)'), findsOneWidget);

    int startDate() =>
        (((server.requests.last.data as Map)['params'] as Map)['options'] as Map)['startDate'] as int;
    final first = startDate();
    await tester.tap(find.byTooltip('Nächste Woche'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pumpAndSettle();
    final next = DateTime(first ~/ 10000, first ~/ 100 % 100, first % 100 + 7);
    expect(startDate(), next.year * 10000 + next.month * 100 + next.day);
  });
}
