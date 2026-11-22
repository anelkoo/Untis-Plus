import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/db/app_database.dart';
import '../../background/background_refresh.dart';
import '../../notifications/change_notifier.dart';
import '../../widgets/widget_bridge.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/timetable_repository.dart';
import '../domain/lesson.dart';

part 'timetable_providers.g.dart';

/// One week: the cached copy first (works offline), then a fresh one from the server. If the
/// fetch fails over a cache, the cache stays with [Week.refreshError] set.
@riverpod
Stream<Week> week(Ref ref, TimetableTarget target, DateTime monday) async* {
  final repo = await _repo(ref);
  if (repo == null) return;
  yield* _cachedThenFresh(repo.cached(target, monday), () => repo.refresh(target, monday));
}

/// All classes' lessons in a week, the source of teacher timetables. Same caching as [week].
@riverpod
Stream<Week> classesWeek(Ref ref, DateTime monday) async* {
  final repo = await _repo(ref);
  if (repo == null) return;
  yield* _cachedThenFresh(repo.cachedClasses(monday), () => repo.refreshClasses(monday));
}

Future<TimetableRepository?> _repo(Ref ref) async {
  final client = await ref.watch(authProvider.future);
  return client == null
      ? null
      : TimetableRepository(ref.watch(appDatabaseProvider), client, onChanges: notifyChanges);
}

Stream<Week> _cachedThenFresh(Future<Week?> cachedWeek, Future<Week> Function() refresh) async* {
  final cached = await cachedWeek;
  if (cached != null) yield cached;
  try {
    yield await refresh();
  } on Object catch (e) {
    if (cached == null) rethrow;
    yield Week(cached.lessons, cached.fetchedAt, e);
  }
}

@riverpod
Stream<List<Named>> favouriteTeachers(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.favouriteTeachers)..orderBy([(t) => OrderingTerm(expression: t.longName)]))
      .map((t) => Named(id: 0, name: t.name, longName: t.longName))
      .watch();
}

Future<void> toggleFavourite(WidgetRef ref, Named teacher, {required bool favourite}) async {
  final db = ref.read(appDatabaseProvider);
  if (favourite) {
    await db.into(db.favouriteTeachers).insertOnConflictUpdate(
        FavouriteTeachersCompanion.insert(name: teacher.name, longName: teacher.longName));
  } else {
    await (db.delete(db.favouriteTeachers)..where((t) => t.name.equals(teacher.name))).go();
  }
}

/// Pull-to-refresh: fetches the week (at most once a minute), then reloads [weekProvider] from
/// the fresh cache. Throws an AppFailure when the fetch fails.
Future<void> refreshWeek(WidgetRef ref, TimetableTarget target, DateTime monday) async {
  final client = await ref.read(authProvider.future);
  if (client == null) return;
  await TimetableRepository(ref.read(appDatabaseProvider), client, onChanges: notifyChanges).refresh(target, monday);
  ref.invalidate(weekProvider(target, monday));
}

/// Refreshes my relevant weeks (on resume and on the desktop timer) and reloads what's shown.
Future<void> refreshMineNow(WidgetRef ref, {required Duration minAge}) async {
  final client = await ref.read(authProvider.future);
  if (client == null) return;
  final repo = TimetableRepository(ref.read(appDatabaseProvider), client, onChanges: notifyChanges);
  try {
    await refreshMine(repo, minAge: minAge);
  } finally {
    // Also offline: the widgets then show the cached lessons, moved on to the current one.
    await publishWidgets(repo);
  }
  ref.invalidate(weekProvider);
}

/// Pull-to-refresh for teacher timetables: all classes, at most every 15 minutes.
Future<void> refreshClassesWeek(WidgetRef ref, DateTime monday) async {
  final client = await ref.read(authProvider.future);
  if (client == null) return;
  await TimetableRepository(ref.read(appDatabaseProvider), client)
      .refreshClasses(monday, minAge: const Duration(minutes: 15));
  ref.invalidate(classesWeekProvider(monday));
}
