// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dio)
final dioProvider = DioProvider._();

final class DioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  DioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dioProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return dio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$dioHash() => r'214e4a44947c349171a1c2d81d4b2d5e24b52fe2';

@ProviderFor(credentialsStore)
final credentialsStoreProvider = CredentialsStoreProvider._();

final class CredentialsStoreProvider
    extends
        $FunctionalProvider<
          CredentialsStore,
          CredentialsStore,
          CredentialsStore
        >
    with $Provider<CredentialsStore> {
  CredentialsStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'credentialsStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$credentialsStoreHash();

  @$internal
  @override
  $ProviderElement<CredentialsStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CredentialsStore create(Ref ref) {
    return credentialsStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CredentialsStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CredentialsStore>(value),
    );
  }
}

String _$credentialsStoreHash() => r'96cf9d582a62a58261983a7282483cb1781956c8';

/// School search with a 300 ms debounce; queries under 3 characters return nothing.

@ProviderFor(schoolSearch)
final schoolSearchProvider = SchoolSearchFamily._();

/// School search with a 300 ms debounce; queries under 3 characters return nothing.

final class SchoolSearchProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<School>>,
          List<School>,
          FutureOr<List<School>>
        >
    with $FutureModifier<List<School>>, $FutureProvider<List<School>> {
  /// School search with a 300 ms debounce; queries under 3 characters return nothing.
  SchoolSearchProvider._({
    required SchoolSearchFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'schoolSearchProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$schoolSearchHash();

  @override
  String toString() {
    return r'schoolSearchProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<School>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<School>> create(Ref ref) {
    final argument = this.argument as String;
    return schoolSearch(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SchoolSearchProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$schoolSearchHash() => r'5adfed7b0a7860b31c28bfe2ad0892b2a80ccfde';

/// School search with a 300 ms debounce; queries under 3 characters return nothing.

final class SchoolSearchFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<School>>, String> {
  SchoolSearchFamily._()
    : super(
        retry: null,
        name: r'schoolSearchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// School search with a 300 ms debounce; queries under 3 characters return nothing.

  SchoolSearchProvider call(String query) =>
      SchoolSearchProvider._(argument: query, from: this);

  @override
  String toString() => r'schoolSearchProvider';
}

/// The signed-in account, or null. A stored login counts as signed in without a network
/// call, so the app opens offline; the client logs in on its first request.

@ProviderFor(Auth)
final authProvider = AuthProvider._();

/// The signed-in account, or null. A stored login counts as signed in without a network
/// call, so the app opens offline; the client logs in on its first request.
final class AuthProvider extends $AsyncNotifierProvider<Auth, WebUntisClient?> {
  /// The signed-in account, or null. A stored login counts as signed in without a network
  /// call, so the app opens offline; the client logs in on its first request.
  AuthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authHash();

  @$internal
  @override
  Auth create() => Auth();
}

String _$authHash() => r'f2a63164b56ea63b85638bcac578888010edc601';

/// The signed-in account, or null. A stored login counts as signed in without a network
/// call, so the app opens offline; the client logs in on its first request.

abstract class _$Auth extends $AsyncNotifier<WebUntisClient?> {
  FutureOr<WebUntisClient?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<WebUntisClient?>, WebUntisClient?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<WebUntisClient?>, WebUntisClient?>,
              AsyncValue<WebUntisClient?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
