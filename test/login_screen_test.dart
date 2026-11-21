import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:untis_plus/app.dart';
import 'package:untis_plus/features/auth/data/credentials_store.dart';
import 'package:untis_plus/features/auth/domain/credentials.dart';
import 'package:untis_plus/features/auth/presentation/auth_providers.dart';

class _EmptyStore implements CredentialsStore {
  @override
  Future<Credentials?> read() async => null;
  @override
  Future<void> write(Credentials c) async {}
  @override
  Future<void> delete() async {}
}

Widget _app() => ProviderScope(
      overrides: [credentialsStoreProvider.overrideWithValue(_EmptyStore())],
      child: const UntisPlusApp(),
    );

void main() {
  testWidgets('shows the login screen when nothing is stored, sign-in disabled until filled',
      (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('School'), findsOneWidget);
    final button = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Sign in'));
    expect(button.onPressed, isNull);
  });

  testWidgets('German strings when the device is German', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('de', 'AT')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('Schule'), findsOneWidget);
    expect(find.text('Angemeldet bleiben'), findsOneWidget);
  });
}
