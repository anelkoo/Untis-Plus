import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/db/app_database.dart';
import '../../core/l10n/app_localizations.dart';
import '../auth/presentation/auth_providers.dart';
import '../more/more_drawer.dart';
import '../timetable/data/timetable_repository.dart';
import '../timetable/domain/lesson.dart';

/// My coming tests: the stored list first, then a fresh one (refreshExams ignores failures).
final examsProvider = StreamProvider<List<Exam>>((ref) async* {
  final client = await ref.watch(authProvider.future);
  if (client == null) return;
  final repo = TimetableRepository(ref.watch(appDatabaseProvider), client);
  yield await repo.cachedExams();
  await repo.refreshExams(minAge: const Duration(minutes: 1));
  yield await repo.cachedExams();
});

class ExamsScreen extends ConsumerWidget {
  const ExamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final now = DateTime.now();
    final exams = [for (final e in ref.watch(examsProvider).value ?? const <Exam>[]) if (e.end.isAfter(now)) e];
    return Scaffold(
      appBar: AppBar(leading: const MenuButton(), title: Text(l.navTests)),
      body: RefreshIndicator.adaptive(
        onRefresh: () async => ref.invalidate(examsProvider),
        child: exams.isEmpty
            ? ListView(padding: const EdgeInsets.all(48), children: [
                Text(l.testsNone, textAlign: .center, style: Theme.of(context).textTheme.bodyLarge),
              ])
            : ListView(children: [
                for (final e in exams)
                  ListTile(
                    leading: const Icon(Icons.edit_note),
                    title: Text(e.subject),
                    subtitle: e.type.isEmpty ? null : Text(e.type),
                    trailing: Text('${DateFormat.MMMEd(locale).format(e.start)}\n${DateFormat.Hm(locale).format(e.start)}',
                        textAlign: .end),
                  ),
              ]),
      ),
    );
  }
}
