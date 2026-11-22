import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/errors/failure_text.dart';
import '../../../core/l10n/app_localizations.dart';
import '../domain/lesson.dart';
import 'timetable_providers.dart';

/// Sheet to pick a teacher: favourites first, then everyone teaching in [monday]'s week.
Future<Named?> showTeacherPicker(BuildContext context, DateTime monday) => showModalBottomSheet<Named>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) => FractionallySizedBox(heightFactor: 0.9, child: _TeacherPicker(monday)),
    );

class _TeacherPicker extends ConsumerStatefulWidget {
  const _TeacherPicker(this.monday);

  final DateTime monday;

  @override
  ConsumerState<_TeacherPicker> createState() => _TeacherPickerState();
}

class _TeacherPickerState extends ConsumerState<_TeacherPicker> {
  var _query = '';

  bool _matches(Named t) {
    final q = _query.trim().toLowerCase();
    return q.isEmpty || t.name.toLowerCase().contains(q) || t.longName.toLowerCase().contains(q);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final favourites = ref.watch(favouriteTeachersProvider).value ?? const [];
    final week = ref.watch(classesWeekProvider(widget.monday));
    final favouriteNames = {for (final f in favourites) f.name};

    Widget tile(Named t) {
      final favourite = favouriteNames.contains(t.name);
      return ListTile(
        title: Text(t.longName.isEmpty ? t.name : t.longName),
        subtitle: Text(t.name),
        onTap: () => Navigator.pop(context, t),
        trailing: IconButton(
          tooltip: favourite ? l.removeFavourite : l.addFavourite,
          icon: Icon(favourite ? Icons.star : Icons.star_border),
          color: favourite ? theme.colorScheme.primary : null,
          onPressed: () => toggleFavourite(ref, t, favourite: !favourite),
        ),
      );
    }

    Widget header(String text) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(text, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary)),
        );

    final shownFavourites = favourites.where(_matches).toList();
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextField(
          autofocus: true,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            labelText: l.teacherSearch,
            hintText: l.teacherSearchHint,
          ),
          onChanged: (q) => setState(() => _query = q),
        ),
      ),
      Expanded(
        child: ListView(children: [
          if (shownFavourites.isNotEmpty) ...[header(l.favouritesLabel), ...shownFavourites.map(tile)],
          ...switch (week) {
            AsyncValue(:final value?) => () {
                final all = {
                  for (final lesson in value.lessons)
                    for (final t in lesson.teachers)
                      if (t.name.isNotEmpty) t.name: Named(id: 0, name: t.name, longName: t.longName),
                }.values.where((t) => !favouriteNames.contains(t.name) && _matches(t)).toList()
                  ..sort((a, b) => a.longName.compareTo(b.longName));
                return [
                  header(l.allTeachersLabel),
                  if (all.isEmpty && shownFavourites.isEmpty)
                    ListTile(title: Text(l.noTeachersFound)),
                  ...all.map(tile),
                ];
              }(),
            AsyncError(:final error) => [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(failureText(l, error), style: TextStyle(color: theme.colorScheme.error)),
                ),
              ],
            _ => [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(children: [
                    const CircularProgressIndicator.adaptive(),
                    const SizedBox(height: 16),
                    Text(l.loadingClasses, textAlign: .center),
                  ]),
                ),
              ],
          },
        ]),
      ),
    ]);
  }
}
