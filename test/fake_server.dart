import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

String fixture(String name) => File('test/fixtures/$name').readAsStringSync();

/// Dio adapter that answers each request from [handler] and records what was sent.
class FakeServer implements HttpClientAdapter {
  FakeServer(this.handler);

  /// Gets the JSON-RPC method and the request; returns a JSON body, or throws to simulate a
  /// network error.
  final String Function(String method, RequestOptions request) handler;
  final requests = <RequestOptions>[];

  Dio get dio => Dio()..httpClientAdapter = this;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<List<int>>? _, Future<void>? _) async {
    requests.add(options);
    final method = (options.data as Map)['method'] as String;
    return ResponseBody.fromString(handler(method, options), 200, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

String rpcResult(Object result) => jsonEncode({'jsonrpc': '2.0', 'id': '1', 'result': result});
