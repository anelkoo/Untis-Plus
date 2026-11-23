// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'absences.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(absences)
final absencesProvider = AbsencesProvider._();

final class AbsencesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Absence>>,
          List<Absence>,
          FutureOr<List<Absence>>
        >
    with $FutureModifier<List<Absence>>, $FutureProvider<List<Absence>> {
  AbsencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'absencesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$absencesHash();

  @$internal
  @override
  $FutureProviderElement<List<Absence>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Absence>> create(Ref ref) {
    return absences(ref);
  }
}

String _$absencesHash() => r'261548657a717a0ffa1abcb088df04cea1dbb51c';
