import 'package:dio/dio.dart';

import '../../features/auth/domain/credentials.dart';
import '../errors/app_failure.dart';
import 'json_rpc.dart';

/// Result of `authenticate`. The session id stays in memory only.
class WebUntisSession {
  const WebUntisSession({
    required this.sessionId,
    required this.personType,
    required this.personId,
    this.klasseId,
  });

  final String sessionId;
  final int personType;
  final int personId;
  final int? klasseId;

  factory WebUntisSession.fromJson(Map<String, dynamic> json) => WebUntisSession(
        sessionId: json['sessionId'] as String,
        personType: (json['personType'] as num).toInt(),
        personId: (json['personId'] as num).toInt(),
        klasseId: (json['klasseId'] as num?)?.toInt(),
      );
}

/// JSON-RPC client for one school account. Logs in lazily and once more when the session expires.
class WebUntisClient {
  WebUntisClient(this._dio, this.credentials);

  final Dio _dio;
  final Credentials credentials;
  Future<WebUntisSession>? _session;

  Uri get _url => Uri.https(credentials.school.server, '/WebUntis/jsonrpc.do', {
        'school': credentials.school.loginName,
      });

  /// The current session, logging in if needed. Parallel callers share one login request.
  Future<WebUntisSession> session() => _session ??= _authenticate().then(
        (s) => s,
        onError: (Object e, StackTrace st) {
          _session = null;
          Error.throwWithStackTrace(e, st);
        },
      );

  Future<WebUntisSession> _authenticate() async {
    final result = await postJsonRpc(_dio, _url, 'authenticate', {
      'user': credentials.username,
      'password': credentials.password,
      'client': 'UntisPlus',
    });
    return WebUntisSession.fromJson((result as Map).cast<String, dynamic>());
  }

  /// Calls [method]; on an expired session it logs in again and retries once.
  Future<dynamic> call(String method, [Object params = const {}]) async {
    final s = await session();
    try {
      return await postJsonRpc(_dio, _url, method, params, sessionId: s.sessionId);
    } on AuthExpiredFailure {
      _session = null;
      final fresh = await session();
      return postJsonRpc(_dio, _url, method, params, sessionId: fresh.sessionId);
    }
  }

  /// Ends the server session. Errors are ignored because the user is leaving anyway.
  Future<void> logout() async {
    final pending = _session;
    _session = null;
    if (pending == null) return;
    try {
      final s = await pending;
      await postJsonRpc(_dio, _url, 'logout', const {}, sessionId: s.sessionId);
    } on Object {
      // Ignored: the session times out on the server by itself.
    }
  }
}
