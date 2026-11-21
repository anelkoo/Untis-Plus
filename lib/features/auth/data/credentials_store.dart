import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/credentials.dart';

/// Keeps the login in the OS keychain (iOS Keychain, Android Keystore, Windows Credential
/// Manager, Linux libsecret).
class CredentialsStore {
  CredentialsStore([this._storage = const FlutterSecureStorage()]);

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

  Future<void> write(Credentials c) =>
      _storage.write(key: _key, value: jsonEncode(c.toJson()));

  Future<void> delete() async {
    try {
      await _storage.delete(key: _key);
    } on Object {
      // Nothing stored, or no keychain: nothing to delete.
    }
  }
}
