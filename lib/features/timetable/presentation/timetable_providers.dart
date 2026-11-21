import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/db/app_database.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/timetable_repository.dart';

part 'timetable_providers.g.dart';

/// One week: the cached copy first (works offline), then a fresh one from the server. If the
/// fetch fails over a cache, the cache stays with [Week.refreshError] set.
@riverpod
Stream<Week> week(Ref ref, TimetableTarget target, DateTime monday) async* {
  final client = await ref.watch(authProvider.future);
  if (client == null) return;
  final repo = TimetableRepository(ref.watch(appDatabaseProvider), client);
  final cached = await repo.cached(target, monday);
  if (cached != null) yield cached;
  try {
    yield await repo.refresh(target, monday);
  } on Object catch (e) {
    if (cached == null) rethrow;
    yield Week(cached.lessons, cached.fetchedAt, e);
  }
}
