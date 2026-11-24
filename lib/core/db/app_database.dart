import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data_dir.dart';

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

/// Teachers starred in the teacher search, by short name.
class FavouriteTeachers extends Table {
  TextColumn get name => text()();
  TextColumn get longName => text()();

  @override
  Set<Column> get primaryKey => {name};
}

@DriftDatabase(tables: [CachedWeeks, FavouriteTeachers])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ??
            driftDatabase(
              name: 'untis_plus',
              // The background refresh opens the database while the app may be open too.
              native: const DriftNativeOptions(shareAcrossIsolates: true, databasePath: _databasePath),
            ));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) await m.createTable(favouriteTeachers);
        },
      );
}

/// The app's data folder, not Documents. Moves a database that older versions left in Documents.
Future<String> _databasePath() async {
  final file = File('${(await dataDir(getApplicationSupportDirectory)).path}/untis_plus.sqlite');
  final old = File('${(await getApplicationDocumentsDirectory()).path}/untis_plus.sqlite');
  if (!file.existsSync() && old.existsSync()) {
    try {
      await old.copy(file.path);
      await old.delete();
    } on Object {
      // Starts empty; the next refresh refills the cache.
    }
  }
  return file.path;
}

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}
