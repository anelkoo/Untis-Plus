// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CachedWeeksTable extends CachedWeeks
    with TableInfo<$CachedWeeksTable, CachedWeek> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedWeeksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _targetMeta = const VerificationMeta('target');
  @override
  late final GeneratedColumn<String> target = GeneratedColumn<String>(
    'target',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mondayMeta = const VerificationMeta('monday');
  @override
  late final GeneratedColumn<int> monday = GeneratedColumn<int>(
    'monday',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [target, monday, json, fetchedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_weeks';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedWeek> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('target')) {
      context.handle(
        _targetMeta,
        target.isAcceptableOrUnknown(data['target']!, _targetMeta),
      );
    } else if (isInserting) {
      context.missing(_targetMeta);
    }
    if (data.containsKey('monday')) {
      context.handle(
        _mondayMeta,
        monday.isAcceptableOrUnknown(data['monday']!, _mondayMeta),
      );
    } else if (isInserting) {
      context.missing(_mondayMeta);
    }
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {target, monday};
  @override
  CachedWeek map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedWeek(
      target: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target'],
      )!,
      monday: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monday'],
      )!,
      json: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $CachedWeeksTable createAlias(String alias) {
    return $CachedWeeksTable(attachedDatabase, alias);
  }
}

class CachedWeek extends DataClass implements Insertable<CachedWeek> {
  final String target;
  final int monday;
  final String json;
  final DateTime fetchedAt;
  const CachedWeek({
    required this.target,
    required this.monday,
    required this.json,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['target'] = Variable<String>(target);
    map['monday'] = Variable<int>(monday);
    map['json'] = Variable<String>(json);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  CachedWeeksCompanion toCompanion(bool nullToAbsent) {
    return CachedWeeksCompanion(
      target: Value(target),
      monday: Value(monday),
      json: Value(json),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory CachedWeek.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedWeek(
      target: serializer.fromJson<String>(json['target']),
      monday: serializer.fromJson<int>(json['monday']),
      json: serializer.fromJson<String>(json['json']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'target': serializer.toJson<String>(target),
      'monday': serializer.toJson<int>(monday),
      'json': serializer.toJson<String>(json),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  CachedWeek copyWith({
    String? target,
    int? monday,
    String? json,
    DateTime? fetchedAt,
  }) => CachedWeek(
    target: target ?? this.target,
    monday: monday ?? this.monday,
    json: json ?? this.json,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  CachedWeek copyWithCompanion(CachedWeeksCompanion data) {
    return CachedWeek(
      target: data.target.present ? data.target.value : this.target,
      monday: data.monday.present ? data.monday.value : this.monday,
      json: data.json.present ? data.json.value : this.json,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedWeek(')
          ..write('target: $target, ')
          ..write('monday: $monday, ')
          ..write('json: $json, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(target, monday, json, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedWeek &&
          other.target == this.target &&
          other.monday == this.monday &&
          other.json == this.json &&
          other.fetchedAt == this.fetchedAt);
}

class CachedWeeksCompanion extends UpdateCompanion<CachedWeek> {
  final Value<String> target;
  final Value<int> monday;
  final Value<String> json;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const CachedWeeksCompanion({
    this.target = const Value.absent(),
    this.monday = const Value.absent(),
    this.json = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedWeeksCompanion.insert({
    required String target,
    required int monday,
    required String json,
    required DateTime fetchedAt,
    this.rowid = const Value.absent(),
  }) : target = Value(target),
       monday = Value(monday),
       json = Value(json),
       fetchedAt = Value(fetchedAt);
  static Insertable<CachedWeek> custom({
    Expression<String>? target,
    Expression<int>? monday,
    Expression<String>? json,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (target != null) 'target': target,
      if (monday != null) 'monday': monday,
      if (json != null) 'json': json,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedWeeksCompanion copyWith({
    Value<String>? target,
    Value<int>? monday,
    Value<String>? json,
    Value<DateTime>? fetchedAt,
    Value<int>? rowid,
  }) {
    return CachedWeeksCompanion(
      target: target ?? this.target,
      monday: monday ?? this.monday,
      json: json ?? this.json,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (target.present) {
      map['target'] = Variable<String>(target.value);
    }
    if (monday.present) {
      map['monday'] = Variable<int>(monday.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedWeeksCompanion(')
          ..write('target: $target, ')
          ..write('monday: $monday, ')
          ..write('json: $json, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FavouriteTeachersTable extends FavouriteTeachers
    with TableInfo<$FavouriteTeachersTable, FavouriteTeacher> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavouriteTeachersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longNameMeta = const VerificationMeta(
    'longName',
  );
  @override
  late final GeneratedColumn<String> longName = GeneratedColumn<String>(
    'long_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [name, longName];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favourite_teachers';
  @override
  VerificationContext validateIntegrity(
    Insertable<FavouriteTeacher> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('long_name')) {
      context.handle(
        _longNameMeta,
        longName.isAcceptableOrUnknown(data['long_name']!, _longNameMeta),
      );
    } else if (isInserting) {
      context.missing(_longNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {name};
  @override
  FavouriteTeacher map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavouriteTeacher(
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      longName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}long_name'],
      )!,
    );
  }

  @override
  $FavouriteTeachersTable createAlias(String alias) {
    return $FavouriteTeachersTable(attachedDatabase, alias);
  }
}

class FavouriteTeacher extends DataClass
    implements Insertable<FavouriteTeacher> {
  final String name;
  final String longName;
  const FavouriteTeacher({required this.name, required this.longName});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    map['long_name'] = Variable<String>(longName);
    return map;
  }

  FavouriteTeachersCompanion toCompanion(bool nullToAbsent) {
    return FavouriteTeachersCompanion(
      name: Value(name),
      longName: Value(longName),
    );
  }

  factory FavouriteTeacher.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavouriteTeacher(
      name: serializer.fromJson<String>(json['name']),
      longName: serializer.fromJson<String>(json['longName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'name': serializer.toJson<String>(name),
      'longName': serializer.toJson<String>(longName),
    };
  }

  FavouriteTeacher copyWith({String? name, String? longName}) =>
      FavouriteTeacher(
        name: name ?? this.name,
        longName: longName ?? this.longName,
      );
  FavouriteTeacher copyWithCompanion(FavouriteTeachersCompanion data) {
    return FavouriteTeacher(
      name: data.name.present ? data.name.value : this.name,
      longName: data.longName.present ? data.longName.value : this.longName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavouriteTeacher(')
          ..write('name: $name, ')
          ..write('longName: $longName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(name, longName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavouriteTeacher &&
          other.name == this.name &&
          other.longName == this.longName);
}

class FavouriteTeachersCompanion extends UpdateCompanion<FavouriteTeacher> {
  final Value<String> name;
  final Value<String> longName;
  final Value<int> rowid;
  const FavouriteTeachersCompanion({
    this.name = const Value.absent(),
    this.longName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FavouriteTeachersCompanion.insert({
    required String name,
    required String longName,
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       longName = Value(longName);
  static Insertable<FavouriteTeacher> custom({
    Expression<String>? name,
    Expression<String>? longName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (longName != null) 'long_name': longName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FavouriteTeachersCompanion copyWith({
    Value<String>? name,
    Value<String>? longName,
    Value<int>? rowid,
  }) {
    return FavouriteTeachersCompanion(
      name: name ?? this.name,
      longName: longName ?? this.longName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (longName.present) {
      map['long_name'] = Variable<String>(longName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavouriteTeachersCompanion(')
          ..write('name: $name, ')
          ..write('longName: $longName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CachedWeeksTable cachedWeeks = $CachedWeeksTable(this);
  late final $FavouriteTeachersTable favouriteTeachers =
      $FavouriteTeachersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cachedWeeks,
    favouriteTeachers,
  ];
}

typedef $$CachedWeeksTableCreateCompanionBuilder =
    CachedWeeksCompanion Function({
      required String target,
      required int monday,
      required String json,
      required DateTime fetchedAt,
      Value<int> rowid,
    });
typedef $$CachedWeeksTableUpdateCompanionBuilder =
    CachedWeeksCompanion Function({
      Value<String> target,
      Value<int> monday,
      Value<String> json,
      Value<DateTime> fetchedAt,
      Value<int> rowid,
    });

class $$CachedWeeksTableFilterComposer
    extends Composer<_$AppDatabase, $CachedWeeksTable> {
  $$CachedWeeksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monday => $composableBuilder(
    column: $table.monday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedWeeksTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedWeeksTable> {
  $$CachedWeeksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monday => $composableBuilder(
    column: $table.monday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedWeeksTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedWeeksTable> {
  $$CachedWeeksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get target =>
      $composableBuilder(column: $table.target, builder: (column) => column);

  GeneratedColumn<int> get monday =>
      $composableBuilder(column: $table.monday, builder: (column) => column);

  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$CachedWeeksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedWeeksTable,
          CachedWeek,
          $$CachedWeeksTableFilterComposer,
          $$CachedWeeksTableOrderingComposer,
          $$CachedWeeksTableAnnotationComposer,
          $$CachedWeeksTableCreateCompanionBuilder,
          $$CachedWeeksTableUpdateCompanionBuilder,
          (
            CachedWeek,
            BaseReferences<_$AppDatabase, $CachedWeeksTable, CachedWeek>,
          ),
          CachedWeek,
          PrefetchHooks Function()
        > {
  $$CachedWeeksTableTableManager(_$AppDatabase db, $CachedWeeksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedWeeksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedWeeksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedWeeksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> target = const Value.absent(),
                Value<int> monday = const Value.absent(),
                Value<String> json = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedWeeksCompanion(
                target: target,
                monday: monday,
                json: json,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String target,
                required int monday,
                required String json,
                required DateTime fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedWeeksCompanion.insert(
                target: target,
                monday: monday,
                json: json,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CachedWeeksTable, CachedWeek>(table),
                  BaseReferences<_$AppDatabase, $CachedWeeksTable, CachedWeek>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedWeeksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedWeeksTable,
      CachedWeek,
      $$CachedWeeksTableFilterComposer,
      $$CachedWeeksTableOrderingComposer,
      $$CachedWeeksTableAnnotationComposer,
      $$CachedWeeksTableCreateCompanionBuilder,
      $$CachedWeeksTableUpdateCompanionBuilder,
      (
        CachedWeek,
        BaseReferences<_$AppDatabase, $CachedWeeksTable, CachedWeek>,
      ),
      CachedWeek,
      PrefetchHooks Function()
    >;
typedef $$FavouriteTeachersTableCreateCompanionBuilder =
    FavouriteTeachersCompanion Function({
      required String name,
      required String longName,
      Value<int> rowid,
    });
typedef $$FavouriteTeachersTableUpdateCompanionBuilder =
    FavouriteTeachersCompanion Function({
      Value<String> name,
      Value<String> longName,
      Value<int> rowid,
    });

class $$FavouriteTeachersTableFilterComposer
    extends Composer<_$AppDatabase, $FavouriteTeachersTable> {
  $$FavouriteTeachersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get longName => $composableBuilder(
    column: $table.longName,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FavouriteTeachersTableOrderingComposer
    extends Composer<_$AppDatabase, $FavouriteTeachersTable> {
  $$FavouriteTeachersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get longName => $composableBuilder(
    column: $table.longName,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FavouriteTeachersTableAnnotationComposer
    extends Composer<_$AppDatabase, $FavouriteTeachersTable> {
  $$FavouriteTeachersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get longName =>
      $composableBuilder(column: $table.longName, builder: (column) => column);
}

class $$FavouriteTeachersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FavouriteTeachersTable,
          FavouriteTeacher,
          $$FavouriteTeachersTableFilterComposer,
          $$FavouriteTeachersTableOrderingComposer,
          $$FavouriteTeachersTableAnnotationComposer,
          $$FavouriteTeachersTableCreateCompanionBuilder,
          $$FavouriteTeachersTableUpdateCompanionBuilder,
          (
            FavouriteTeacher,
            BaseReferences<
              _$AppDatabase,
              $FavouriteTeachersTable,
              FavouriteTeacher
            >,
          ),
          FavouriteTeacher,
          PrefetchHooks Function()
        > {
  $$FavouriteTeachersTableTableManager(
    _$AppDatabase db,
    $FavouriteTeachersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavouriteTeachersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavouriteTeachersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavouriteTeachersTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> name = const Value.absent(),
                Value<String> longName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FavouriteTeachersCompanion(
                name: name,
                longName: longName,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String name,
                required String longName,
                Value<int> rowid = const Value.absent(),
              }) => FavouriteTeachersCompanion.insert(
                name: name,
                longName: longName,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FavouriteTeachersTable, FavouriteTeacher>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $FavouriteTeachersTable,
                    FavouriteTeacher
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FavouriteTeachersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FavouriteTeachersTable,
      FavouriteTeacher,
      $$FavouriteTeachersTableFilterComposer,
      $$FavouriteTeachersTableOrderingComposer,
      $$FavouriteTeachersTableAnnotationComposer,
      $$FavouriteTeachersTableCreateCompanionBuilder,
      $$FavouriteTeachersTableUpdateCompanionBuilder,
      (
        FavouriteTeacher,
        BaseReferences<
          _$AppDatabase,
          $FavouriteTeachersTable,
          FavouriteTeacher
        >,
      ),
      FavouriteTeacher,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CachedWeeksTableTableManager get cachedWeeks =>
      $$CachedWeeksTableTableManager(_db, _db.cachedWeeks);
  $$FavouriteTeachersTableTableManager get favouriteTeachers =>
      $$FavouriteTeachersTableTableManager(_db, _db.favouriteTeachers);
}

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'59cce38d45eeaba199eddd097d8e149d66f9f3e1';
