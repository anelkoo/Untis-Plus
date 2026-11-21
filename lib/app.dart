import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'core/l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_providers.dart';
import 'features/auth/presentation/login_screen.dart';

class UntisPlusApp extends ConsumerWidget {
  const UntisPlusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: appTheme(.light),
      darkTheme: appTheme(.dark),
      // Flutter's generated list still points at the old flutter_localizations delegates, which
      // material_ui widgets don't read, so Material/Cupertino strings come from material_ui.
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: switch (auth) {
        AsyncData(value: null) => const LoginScreen(),
        AsyncData() => const _SignedInPlaceholder(),
        _ => const Scaffold(body: Center(child: CircularProgressIndicator.adaptive())),
      },
    );
  }
}

// shortcut: placeholder until the timetable screen lands in step 3.
class _SignedInPlaceholder extends ConsumerWidget {
  const _SignedInPlaceholder();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final creds = ref.watch(authProvider).value!.credentials;
    return Scaffold(
      appBar: AppBar(title: Text(l.appTitle)),
      body: ListTile(
        title: Text(l.signedInAs(creds.username)),
        subtitle: Text(creds.school.displayName),
        trailing: TextButton(
          onPressed: () => ref.read(authProvider.notifier).logout(),
          child: Text(l.signOut),
        ),
      ),
    );
  }
}
