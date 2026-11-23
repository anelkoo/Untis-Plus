import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors/failure_text.dart';
import '../../core/l10n/app_localizations.dart';
import 'absences.dart';

/// My absences this school year: a total of missed lessons, then each absence, newest first.
class AbsencesScreen extends ConsumerWidget {
  const AbsencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.absencesTitle)),
      body: RefreshIndicator.adaptive(
        onRefresh: () => ref.refresh(absencesProvider.future),
        child: switch (ref.watch(absencesProvider)) {
          AsyncValue(:final List<Absence> value) => _list(context, value),
          AsyncError(:final error) => ListView(padding: const EdgeInsets.all(24), children: [
              Text(failureText(l, error), textAlign: .center),
              const SizedBox(height: 16),
              Center(
                child: FilledButton(onPressed: () => ref.invalidate(absencesProvider), child: Text(l.retry)),
              ),
            ]),
          _ => const Center(child: CircularProgressIndicator.adaptive()),
        },
      ),
    );
  }

  Widget _list(BuildContext context, List<Absence> absences) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final theme = Theme.of(context);
    if (absences.isEmpty) {
      return ListView(padding: const EdgeInsets.all(48), children: [
        Text(l.absencesNone, textAlign: .center, style: theme.textTheme.bodyLarge),
      ]);
    }
    int sum(Iterable<Absence> list) => list.fold(0, (s, a) => s + (a.lessons ?? 0));
    final known = absences.every((a) => a.lessons != null);

    return ListView(padding: const EdgeInsets.only(bottom: 24), children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text(
          known
              ? l.absencesSummary(sum(absences), sum(absences.where((a) => !a.excused)))
              : l.absencesCount(absences.length),
          style: theme.textTheme.titleMedium,
        ),
      ),
      for (final a in absences)
        ListTile(
          leading: Icon(
            a.excused ? Icons.check_circle_outline : Icons.error_outline,
            color: a.excused ? theme.colorScheme.primary : theme.colorScheme.error,
          ),
          title: Text(DateUtils.isSameDay(a.start, a.end)
              ? DateFormat.MMMEd(locale).format(a.start)
              : '${DateFormat.MMMd(locale).format(a.start)} – ${DateFormat.MMMd(locale).format(a.end)}'),
          subtitle: Text([
            '${DateFormat.Hm(locale).format(a.start)}–${DateFormat.Hm(locale).format(a.end)}',
            if (a.lessons case final n?) l.absenceLessons(n),
            a.status.isNotEmpty ? a.status : (a.excused ? l.absenceExcused : l.absenceNotExcused),
            if (a.reason.isNotEmpty) a.reason,
          ].join(' · ')),
        ),
    ]);
  }
}
