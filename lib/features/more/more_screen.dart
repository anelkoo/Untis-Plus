import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors/failure_text.dart';
import '../../core/l10n/app_localizations.dart';
import '../absences/absences_screen.dart';
import '../auth/presentation/auth_providers.dart';
import '../settings/settings_screen.dart';
import '../timetable/presentation/timetable_providers.dart';

/// The rest of the app: what used to be in the timetable's menu.
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    void open(Widget screen) => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => screen));
    return Scaffold(
      appBar: AppBar(title: Text(l.navMore)),
      body: ListView(children: [
        ListTile(
          leading: const Icon(Icons.event_busy_outlined),
          title: Text(l.absencesTitle),
          onTap: () => open(const AbsencesScreen()),
        ),
        ListTile(
          leading: const Icon(Icons.event_outlined),
          title: Text(l.exportCalendar),
          onTap: () async {
            final messenger = ScaffoldMessenger.of(context);
            try {
              final path = await exportMyCalendar(ref);
              if (path != null) messenger.showSnackBar(SnackBar(content: Text(l.exportSaved(path))));
            } on Object catch (e) {
              messenger.showSnackBar(SnackBar(content: Text(l.exportFailed(failureText(l, e)))));
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.settings_outlined),
          title: Text(l.settings),
          onTap: () => open(const SettingsScreen()),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout),
          title: Text(l.signOut),
          onTap: () => ref.read(authProvider.notifier).logout(),
        ),
      ]),
    );
  }
}
