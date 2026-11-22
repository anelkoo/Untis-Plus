import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

String fixture(String name) => File('test/fixtures/$name').readAsStringSync();

/// Dio adapter that answers each request from [handler] and records what was sent.
class FakeServer implements HttpClientAdapter {
  FakeServer(this.handler);

  /// Gets the JSON-RPC method (or the URL path for REST calls) and the request; returns a JSON body, or throws to simulate a
  /// network error.
  final String Function(String method, RequestOptions request) handler;
  final requests = <RequestOptions>[];

  Dio get dio => Dio()..httpClientAdapter = this;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<List<int>>? _, Future<void>? _) async {
    requests.add(options);
    final data = options.data;
    final method = data is Map ? data['method'] as String : options.uri.path;
    return ResponseBody.fromString(handler(method, options), 200, headers: {
      // The real WebUntis servers send this, which Dio does not auto-parse as JSON.
      Headers.contentTypeHeader: ['application/json-rpc;charset=UTF-8'],
    });
  }

  @override
  void close({bool force = false}) {}
}

String rpcResult(Object result) => jsonEncode({'jsonrpc': '2.0', 'id': '1', 'result': result});

/// A signed-in student's school: login, the fixture week and its exams.
String schoolHandler(String method, RequestOptions _) => switch (method) {
      'authenticate' => fixture('authenticate_ok.json'),
      'getTimetable' => fixture('getTimetable_week.json'),
      '/WebUntis/api/token/new' => 'header.payload.signature',
      '/WebUntis/api/exams' => fixture('api_exams.json'),
      '/WebUntis/api/public/timetable/weekly/pageconfig' =>
        '{"data":{"elements":[{"type":1,"id":1074,"name":"1AHIT","longName":"1a Muster"},'
            '{"type":1,"id":1075,"name":"2AHIT","longName":"2a"}]}}',
      '/WebUntis/api/rest/view/v1/timetable/entries' => fixture('rest_class_week.json'),
      _ => throw StateError('unexpected call $method'),
    };
