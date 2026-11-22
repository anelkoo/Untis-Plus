import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/credentials.dart';

/// Keeps the login in the OS keychain (iOS Keychain, Android Keystore, Windows Credential
/// Manager, Linux libsecret).
class CredentialsStore {
  // iOS: readable after the first unlock, so the background refresh works on a locked phone.
  CredentialsStore([
    this._storage = const FlutterSecureStorage(
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    ),
  ]);

  final FlutterSecureStorage _storage;
  static const _key = 'credentials';

  /// Null when nothing is stored or the keychain is unavailable (e.g. Linux without a keyring).
  Future<Credentials?> read() async {
    try {
      final raw = await _storage.read(key: _key);
      return raw == null ? null : Credentials.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Object {
      return null;
    }
  }

  /// Deletes first: an update would keep an older entry's keychain access level.
  Future<void> write(Credentials c) async {
    await delete();
    await _storage.write(key: _key, value: jsonEncode(c.toJson()));
  }

  Future<void> delete() async {
    try {
      await _storage.delete(key: _key);
    } on Object {
      // Nothing stored, or no keychain: nothing to delete.
    }
  }
}
