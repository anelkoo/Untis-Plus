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

String _$weekHash() => r'52f3a755da27eba27a5f5c0781c8325fd93d382b';

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
