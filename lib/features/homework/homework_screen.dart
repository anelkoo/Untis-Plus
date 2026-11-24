import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/db/app_database.dart';
import '../../core/errors/failure_text.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/striped_row.dart';
import '../auth/presentation/auth_providers.dart';
import '../more/more_drawer.dart';
import '../timetable/presentation/jump.dart';
import '../timetable/data/timetable_repository.dart';
import 'homework.dart';

/// The stored homework first (works offline), then a fresh copy; a failed fetch over a stored copy is ignored.
final homeworkProvider = StreamProvider<List<Homework>>((ref) async* {
  final client = await ref.watch(authProvider.future);
  if (client == null) return;
  final repo = TimetableRepository(ref.watch(appDatabaseProvider), client);
  final cached = await repo.cachedHomework();
  if (cached != null) yield cached;
  try {
    await repo.refreshHomework(minAge: const Duration(minutes: 1));
    yield (await repo.cachedHomework())!;
  } on Object {
    if (cached == null) rethrow;
  }
});

/// My homework grouped by when it is due; finished ones come last.
class HomeworkScreen extends ConsumerWidget {
  const HomeworkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(leading: const MenuButton(), title: Text(l.navHomework)),
      body: RefreshIndicator.adaptive(
        onRefresh: () async => ref.invalidate(homeworkProvider),
        child: switch (ref.watch(homeworkProvider)) {
          AsyncValue(:final List<Homework> value) => _list(context, value),
          AsyncError(:final error) => ListView(padding: const EdgeInsets.all(24), children: [
              Text(failureText(l, error), textAlign: .center),
              const SizedBox(height: 16),
              Center(child: FilledButton(onPressed: () => ref.invalidate(homeworkProvider), child: Text(l.retry))),
            ]),
          _ => const Center(child: CircularProgressIndicator.adaptive()),
        },
      ),
    );
  }

  Widget _list(BuildContext context, List<Homework> homework) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final theme = Theme.of(context);
    final now = DateTime.now();
    // Finished homework from before today is old news.
    final shown = homework.where((h) => !h.done || untisDate(h.due) >= untisDate(now)).toList();
    if (shown.isEmpty) {
      return ListView(padding: const EdgeInsets.all(48), children: [
        Text(l.homeworkNone, textAlign: .center, style: theme.textTheme.bodyLarge),
      ]);
    }
    final titles = {
      HomeworkGroup.overdue: l.homeworkOverdue,
      HomeworkGroup.today: l.homeworkToday,
      HomeworkGroup.tomorrow: l.homeworkTomorrow,
      HomeworkGroup.week: l.homeworkWeek,
      HomeworkGroup.later: l.homeworkLater,
      HomeworkGroup.done: l.homeworkDone,
    };
    return ListView(padding: const EdgeInsets.only(bottom: 24), children: [
      for (final group in HomeworkGroup.values)
        if (shown.where((h) => groupOf(h, now) == group).toList() case final items when items.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              titles[group]!,
              style: theme.textTheme.titleSmall?.copyWith(
                color: group == HomeworkGroup.overdue ? theme.colorScheme.error : theme.colorScheme.primary,
              ),
            ),
          ),
          for (final (i, h) in items.indexed)
            stripedRow(
              context,
              i,
              ListTile(
                onTap: () => timetableJump.value = (start: h.due, end: null, subject: h.subject),
                leading: Icon(h.done ? Icons.check_circle_outline : Icons.radio_button_unchecked),
                title: Text(h.subject.isEmpty ? h.text : h.subject),
                subtitle: Text(
                  [if (h.subject.isNotEmpty) h.text, h.teacher].where((s) => s.isNotEmpty).join('\n'),
                  maxLines: 4,
                  overflow: .ellipsis,
                ),
                trailing: Text(DateFormat.MMMEd(locale).format(h.due)),
              ),
            ),
        ],
    ]);
  }
}
