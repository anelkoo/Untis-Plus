// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timetable_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One week: the cached copy first (works offline), then a fresh one from the server. If the
/// fetch fails over a cache, the cache stays with [Week.refreshError] set.

@ProviderFor(week)
final weekProvider = WeekFamily._();

/// One week: the cached copy first (works offline), then a fresh one from the server. If the
/// fetch fails over a cache, the cache stays with [Week.refreshError] set.

final class WeekProvider
    extends $FunctionalProvider<AsyncValue<Week>, Week, Stream<Week>>
    with $FutureModifier<Week>, $StreamProvider<Week> {
  /// One week: the cached copy first (works offline), then a fresh one from the server. If the
  /// fetch fails over a cache, the cache stays with [Week.refreshError] set.
  WeekProvider._({
    required WeekFamily super.from,
    required (TimetableTarget, DateTime) super.argument,
  }) : super(
         retry: null,
         name: r'weekProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$weekHash();

  @override
  String toString() {
    return r'weekProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<Week> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Week> create(Ref ref) {
    final argument = this.argument as (TimetableTarget, DateTime);
    return week(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is WeekProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$weekHash() => r'4297256a631f13c9f0e91793ef58239ac5d1ebb7';

/// One week: the cached copy first (works offline), then a fresh one from the server. If the
/// fetch fails over a cache, the cache stays with [Week.refreshError] set.

final class WeekFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Week>, (TimetableTarget, DateTime)> {
  WeekFamily._()
    : super(
        retry: null,
        name: r'weekProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One week: the cached copy first (works offline), then a fresh one from the server. If the
  /// fetch fails over a cache, the cache stays with [Week.refreshError] set.

  WeekProvider call(TimetableTarget target, DateTime monday) =>
      WeekProvider._(argument: (target, monday), from: this);

  @override
  String toString() => r'weekProvider';
}

/// All classes' lessons in a week, the source of teacher timetables. Same caching as [week].

@ProviderFor(classesWeek)
final classesWeekProvider = ClassesWeekFamily._();

/// All classes' lessons in a week, the source of teacher timetables. Same caching as [week].

final class ClassesWeekProvider
    extends $FunctionalProvider<AsyncValue<Week>, Week, Stream<Week>>
    with $FutureModifier<Week>, $StreamProvider<Week> {
  /// All classes' lessons in a week, the source of teacher timetables. Same caching as [week].
  ClassesWeekProvider._({
    required ClassesWeekFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'classesWeekProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$classesWeekHash();

  @override
  String toString() {
    return r'classesWeekProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Week> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Week> create(Ref ref) {
    final argument = this.argument as DateTime;
    return classesWeek(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ClassesWeekProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$classesWeekHash() => r'68512a20c2bc6dce8982703d04faaf19ef0f3795';

/// All classes' lessons in a week, the source of teacher timetables. Same caching as [week].

final class ClassesWeekFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Week>, DateTime> {
  ClassesWeekFamily._()
    : super(
        retry: null,
        name: r'classesWeekProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// All classes' lessons in a week, the source of teacher timetables. Same caching as [week].

  ClassesWeekProvider call(DateTime monday) =>
      ClassesWeekProvider._(argument: monday, from: this);

  @override
  String toString() => r'classesWeekProvider';
}

@ProviderFor(favouriteTeachers)
final favouriteTeachersProvider = FavouriteTeachersProvider._();

final class FavouriteTeachersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Named>>,
          List<Named>,
          Stream<List<Named>>
        >
    with $FutureModifier<List<Named>>, $StreamProvider<List<Named>> {
  FavouriteTeachersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favouriteTeachersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favouriteTeachersHash();

  @$internal
  @override
  $StreamProviderElement<List<Named>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Named>> create(Ref ref) {
    return favouriteTeachers(ref);
  }
}

String _$favouriteTeachersHash() => r'f630c8e297db3a404f4bac9bdc0b48b5e45e318c';
