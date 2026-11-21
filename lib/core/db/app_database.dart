import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_database.g.dart';

/// Raw `getTimetable` results per target and week. [fetchedAt] is also the rate-limit state.
class CachedWeeks extends Table {
  TextColumn get target => text()();
  IntColumn get monday => integer()(); // yyyymmdd
  TextColumn get json => text()();
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {target, monday};
}

@DriftDatabase(tables: [CachedWeeks])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? driftDatabase(name: 'untis_plus'));

  @override
  int get schemaVersion => 1;
}

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}
