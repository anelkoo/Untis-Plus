import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/db/app_database.dart';
import '../../../core/network/webuntis_client.dart';
import '../data/credentials_store.dart';
import '../data/school_search_api.dart';
import '../domain/credentials.dart';
import '../domain/school.dart';

part 'auth_providers.g.dart';

@Riverpod(keepAlive: true)
Dio dio(Ref ref) => Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
    ));

@Riverpod(keepAlive: true)
CredentialsStore credentialsStore(Ref ref) => CredentialsStore();

/// School search with a 300 ms debounce; queries under 3 characters return nothing.
@riverpod
Future<List<School>> schoolSearch(Ref ref, String query) async {
  final q = query.trim();
  if (q.length < 3) return const [];
  var disposed = false;
  ref.onDispose(() => disposed = true);
  await Future<void>.delayed(const Duration(milliseconds: 300));
  if (disposed) return const [];
  return searchSchools(ref.read(dioProvider), q);
}

/// The signed-in account, or null. A stored login counts as signed in without a network
/// call, so the app opens offline; the client logs in on its first request.
@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  @override
  Future<WebUntisClient?> build() async {
    final stored = await ref.read(credentialsStoreProvider).read();
    return stored == null ? null : WebUntisClient(ref.read(dioProvider), stored);
  }

  /// Checks the login against the server. Throws an AppFailure if it is rejected.
  Future<void> login(Credentials credentials, {required bool remember}) async {
    final client = WebUntisClient(ref.read(dioProvider), credentials);
    await client.session();
    final store = ref.read(credentialsStoreProvider);
    if (remember) {
      // No keychain (Linux without a keyring): stay signed in for this run only.
      await store.write(credentials).catchError((Object _) {});
    } else {
      await store.delete();
    }
    state = AsyncData(client);
  }

  Future<void> logout() async {
    final client = state.value;
    state = const AsyncData(null);
    await ref.read(credentialsStoreProvider).delete();
    // The next account must not see this one's timetable.
    final db = ref.read(appDatabaseProvider);
    await db.delete(db.cachedWeeks).go();
    await client?.logout();
  }
}
