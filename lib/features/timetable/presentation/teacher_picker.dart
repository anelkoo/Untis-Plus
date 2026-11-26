import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/errors/failure_text.dart';
import '../../../core/adaptive_sheet.dart';
import '../../../core/l10n/app_localizations.dart';
import '../domain/lesson.dart';
import 'timetable_providers.dart';

enum Pick { teacher, room, klass }

/// Sheet to pick a teacher: favourites first, then everyone teaching in [monday]'s week. [kind]
/// lists the rooms or classes in use that week instead.
/// shortcut: favourites for teachers only.
Future<Named?> showTeacherPicker(BuildContext context, DateTime monday, {Pick kind = Pick.teacher}) =>
    showAdaptiveSheet<Named>(
      context,
      (context) => FractionallySizedBox(heightFactor: 0.9, child: _TeacherPicker(monday, kind: kind)),
    );

class _TeacherPicker extends ConsumerStatefulWidget {
  const _TeacherPicker(this.monday, {required this.kind});

  final DateTime monday;
  final Pick kind;

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
    final kind = widget.kind;
    final teachers = kind == Pick.teacher;
    final favourites = teachers ? ref.watch(favouriteTeachersProvider).value ?? const <Named>[] : const <Named>[];
    final names = ref.watch(classesWeekProvider(widget.monday)).whenData(
          (w) => [
            for (final lesson in w.lessons)
              for (final t in switch (kind) {
                Pick.room => lesson.rooms,
                Pick.klass => lesson.classes,
                _ => lesson.teachers,
              })
                if (t.name.isNotEmpty) Named(id: t.id, name: t.name, longName: t.longName),
          ],
        );
    final favouriteNames = {for (final f in favourites) f.name};

    Widget tile(Named t) {
      final favourite = favouriteNames.contains(t.name);
      return ListTile(
        title: Text(t.longName.isEmpty ? t.name : t.longName),
        // Rooms often have the same long and short name; show it once.
        subtitle: t.longName.isEmpty || t.longName == t.name ? null : Text(t.name),
        onTap: () => Navigator.pop(context, t),
        trailing: !teachers ? null : IconButton(
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
            labelText: switch (kind) {
              Pick.room => l.roomSearch,
              Pick.klass => l.classSearch,
              _ => l.teacherSearch,
            },
            hintText: switch (kind) {
              Pick.room => l.roomSearchHint,
              Pick.klass => l.classSearchHint,
              _ => l.teacherSearchHint,
            },
          ),
          onChanged: (q) => setState(() => _query = q),
        ),
      ),
      Expanded(
        child: ListView(children: [
          if (shownFavourites.isNotEmpty) ...[header(l.favouritesLabel), ...shownFavourites.map(tile)],
          ...switch (names) {
            AsyncValue(:final value?) => () {
                final all = {for (final t in value) t.name: t}
                    .values
                    .where((t) => !favouriteNames.contains(t.name) && _matches(t))
                    .toList()
                  ..sort((a, b) => (a.longName.isEmpty ? a.name : a.longName).compareTo(b.longName.isEmpty ? b.name : b.longName));
                return [
                  header(switch (kind) {
                    Pick.room => l.allRoomsLabel,
                    Pick.klass => l.allClassesLabel,
                    _ => l.allTeachersLabel,
                  }),
                  if (all.isEmpty && shownFavourites.isEmpty)
                    ListTile(title: Text(switch (kind) {
                      Pick.room => l.noRoomsFound,
                      Pick.klass => l.noClassesFound,
                      _ => l.noTeachersFound,
                    })),
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
