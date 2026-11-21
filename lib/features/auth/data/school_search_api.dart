import 'package:dio/dio.dart';

import '../../../core/network/json_rpc.dart';
import '../domain/school.dart';

final _searchUrl = Uri.parse('https://mobile.webuntis.com/ms/schoolquery2');

/// Public WebUntis school search. Throws [TooManySchoolsFailure] when the query is too broad.
Future<List<School>> searchSchools(Dio dio, String query) async {
  final result = await postJsonRpc(dio, _searchUrl, 'searchSchool', [
    {'search': query},
  ]);
  return [
    for (final s in (result as Map)['schools'] as List)
      School.fromJson((s as Map).cast<String, dynamic>()),
  ];
}
