import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/errors/failure_text.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/timetable_repository.dart';
import '../domain/lesson.dart';
import 'timetable_providers.dart';

// shortcut: a plain list to check parsing against a real week; the week/day views replace it
// in step 3.
class TimetableScreen extends ConsumerWidget {
  const TimetableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    // On Saturday and Sunday, show the coming week.
    final monday = mondayOf(DateTime.now().add(const Duration(days: 2)));
    final provider = weekProvider(me, monday);
    final week = ref.watch(provider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.appTitle),
        actions: [
          IconButton(
            tooltip: l.signOut,
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: switch (week) {
        AsyncValue(:final Week value) => ListView(
            children: [
              ListTile(
                title: Text(l.lastUpdated(DateFormat.Md(locale).add_Hm().format(value.fetchedAt))),
                subtitle: value.refreshError == null
                    ? null
                    : Text(failureText(l, value.refreshError!),
                        style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
              if (value.lessons.isEmpty) ListTile(title: Text(l.noLessons)),
              for (final lesson in value.lessons) _LessonTile(lesson, locale),
            ],
          ),
        AsyncError(:final error) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: .min, children: [
                Text(failureText(l, error), textAlign: .center),
                const SizedBox(height: 16),
                FilledButton(onPressed: () => ref.invalidate(provider), child: Text(l.retry)),
              ]),
            ),
          ),
        _ => const Center(child: CircularProgressIndicator.adaptive()),
      },
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile(this.lesson, this.locale);

  final Lesson lesson;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    String names(List<Named> list) => list
        .map((n) => n.original == null ? n.name : '${n.name} (${n.original})')
        .join(', ');
    final status = switch (lesson.status) {
      .regular => null,
      .cancelled => l.statusCancelled,
      .substitution => l.statusSubstitution,
      .irregular => l.statusIrregular,
      .exam => l.statusExam,
    };
    final time = '${DateFormat.E(locale).add_Md().format(lesson.start)} '
        '${DateFormat.Hm(locale).format(lesson.start)}–${DateFormat.Hm(locale).format(lesson.end)}';
    return ListTile(
      title: Text([time, names(lesson.subjects), ?status].where((s) => s.isNotEmpty).join(' · ')),
      subtitle: Text([
        names(lesson.teachers),
        names(lesson.rooms),
        lesson.lessonText,
        lesson.substitutionText,
        lesson.info,
      ].where((s) => s.isNotEmpty).join(' · ')),
    );
  }
}
