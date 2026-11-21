import 'dart:convert';

import 'package:dio/dio.dart';

import '../errors/app_failure.dart';

/// Sends one JSON-RPC 2.0 call and returns `result`, or throws an [AppFailure].
Future<dynamic> postJsonRpc(
  Dio dio,
  Uri url,
  String method,
  Object params, {
  String? sessionId,
}) async {
  final Response<dynamic> res;
  try {
    res = await dio.postUri<dynamic>(
      url,
      data: {'id': '1', 'method': method, 'params': params, 'jsonrpc': '2.0'},
      options: Options(
        contentType: Headers.jsonContentType,
        // WebUntis answers with `application/json-rpc`, which Dio won't parse, so decode here.
        responseType: .plain,
        headers: {if (sessionId != null) 'Cookie': 'JSESSIONID=$sessionId'},
      ),
    );
  } on DioException catch (e) {
    throw AppFailure.fromDio(e);
  }
  final Object? body;
  try {
    body = jsonDecode('${res.data}');
  } on FormatException {
    throw const ServerFailure(null, 'unexpected response');
  }
  if (body is! Map) throw const ServerFailure(null, 'unexpected response');
  final error = body['error'];
  if (error is Map) {
    throw AppFailure.fromRpc((error['code'] as num?)?.toInt() ?? 0, '${error['message']}');
  }
  return body['result'];
}
