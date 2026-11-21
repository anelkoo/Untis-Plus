import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untis_plus/core/errors/app_failure.dart';
import 'package:untis_plus/core/network/webuntis_client.dart';
import 'package:untis_plus/features/auth/data/school_search_api.dart';
import 'package:untis_plus/features/auth/domain/credentials.dart';
import 'package:untis_plus/features/auth/domain/school.dart';

import 'fake_server.dart';

const _school = School(server: 'htl-donaustadt.webuntis.com', loginName: 'htl-donaustadt', displayName: 'HTBLA Wien 22');
const _creds = Credentials(school: _school, username: 'max', password: 'secret');

void main() {
  group('school search', () {
    test('parses the recorded response', () async {
      final server = FakeServer((_, _) => fixture('schoolquery.json'));
      final schools = await searchSchools(server.dio, 'htl donaustadt');
      expect(schools.single.server, 'htl-donaustadt.webuntis.com');
      expect(schools.single.loginName, 'htl-donaustadt');
      expect(schools.single.displayName, 'HTBLA Wien 22');
    });

    test('too broad a query is a TooManySchoolsFailure', () {
      final server = FakeServer((_, _) => fixture('schoolquery_too_many.json'));
      expect(searchSchools(server.dio, 'htl'), throwsA(isA<TooManySchoolsFailure>()));
    });
  });

  group('WebUntisClient', () {
    test('authenticate parses the session and targets the school URL', () async {
      final server = FakeServer((_, _) => fixture('authenticate_ok.json'));
      final s = await WebUntisClient(server.dio, _creds).session();
      expect(s.personType, 5);
      expect(s.personId, 4711);
      expect(s.klasseId, 815);
      final url = server.requests.single.uri;
      expect(url.host, 'htl-donaustadt.webuntis.com');
      expect(url.path, '/WebUntis/jsonrpc.do');
      expect(url.queryParameters['school'], 'htl-donaustadt');
    });

    test('maps recorded error responses to typed failures', () async {
      for (final (file, matcher) in [
        ('authenticate_bad_credentials.json', isA<WrongCredentialsFailure>()),
        ('authenticate_unknown_school.json', isA<SchoolNotFoundFailure>()),
      ]) {
        final server = FakeServer((_, _) => fixture(file));
        await expectLater(WebUntisClient(server.dio, _creds).session(), throwsA(matcher));
      }
    });

    test('a failed login is not cached, so the next call tries again', () async {
      var attempts = 0;
      final server = FakeServer((_, _) => ++attempts == 1
          ? fixture('authenticate_bad_credentials.json')
          : fixture('authenticate_ok.json'));
      final client = WebUntisClient(server.dio, _creds);
      await expectLater(client.session(), throwsA(isA<WrongCredentialsFailure>()));
      expect((await client.session()).personId, 4711);
    });

    test('sends the session cookie and logs in again once when it expired', () async {
      var subjectCalls = 0;
      final server = FakeServer((method, _) => switch (method) {
            'authenticate' => fixture('authenticate_ok.json'),
            _ => ++subjectCalls == 1 ? fixture('not_authenticated.json') : rpcResult([]),
          });
      final result = await WebUntisClient(server.dio, _creds).call('getSubjects');
      expect(result, isEmpty);
      expect(server.requests.map((r) => (r.data as Map)['method']),
          ['authenticate', 'getSubjects', 'authenticate', 'getSubjects']);
      expect(server.requests[1].headers['Cookie'], 'JSESSIONID=0123456789ABCDEF0123456789ABCDEF');
    });

    test('parallel calls share one login request', () async {
      final server = FakeServer((method, _) =>
          method == 'authenticate' ? fixture('authenticate_ok.json') : rpcResult([]));
      final client = WebUntisClient(server.dio, _creds);
      await Future.wait([client.call('getSubjects'), client.call('getRooms')]);
      expect(server.requests.where((r) => (r.data as Map)['method'] == 'authenticate'), hasLength(1));
    });

    test('connection errors become NetworkFailure', () {
      final server = FakeServer((_, r) => throw DioException.connectionError(
          requestOptions: r, reason: 'offline'));
      expect(WebUntisClient(server.dio, _creds).session(), throwsA(isA<NetworkFailure>()));
    });

    test('toString never contains the password or session id', () async {
      final server = FakeServer((_, _) => fixture('authenticate_ok.json'));
      final client = WebUntisClient(server.dio, _creds);
      final s = await client.session();
      for (final text in ['$_creds', '$s', '$client']) {
        expect(text, isNot(contains('secret')));
        expect(text, isNot(contains('0123456789ABCDEF')));
      }
    });
  });
}
