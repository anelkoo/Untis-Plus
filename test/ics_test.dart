import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:untis_plus/features/export/ics.dart';
import 'package:untis_plus/features/timetable/domain/lesson.dart';

void main() {
  final lessons = [
    Lesson(
      id: 101,
      start: DateTime.utc(2026, 11, 23, 7),
      end: DateTime.utc(2026, 11, 23, 7, 50),
      status: .exam,
      examType: 'SMÜP',
      subjects: const [Named(id: 1, name: 'AM', longName: 'Angewandte Mathematik')],
      teachers: const [Named(id: 2, name: 'MUE')],
      rooms: const [Named(id: 3, name: 'E12'), Named(id: 4, name: 'E14')],
      lessonText: 'Buch; Heft',
    ),
    Lesson(
      id: 102,
      start: DateTime.utc(2026, 11, 23, 8),
      end: DateTime.utc(2026, 11, 23, 8, 50),
      status: .cancelled,
      subjects: const [Named(id: 1, name: 'D')],
    ),
  ];
  final ics = buildIcs(lessons, now: DateTime.utc(2026, 11, 22, 12));
  final lines = ics.split('\r\n');

  test('one event per lesson with UTC times, stable ids and escaped text', () {
    expect(lines.first, 'BEGIN:VCALENDAR');
    expect(ics, endsWith('END:VCALENDAR\r\n'));
    expect(lines.where((l) => l == 'BEGIN:VEVENT'), hasLength(2));
    expect(lines, contains('UID:101-20261123T070000Z@untisplus'));
    expect(lines, contains('DTSTART:20261123T070000Z'));
    expect(lines, contains('DTEND:20261123T075000Z'));
    expect(lines, contains('SUMMARY:Angewandte Mathematik'));
    expect(lines, contains(r'LOCATION:E12\, E14'));
    expect(lines, contains(r'DESCRIPTION:MUE\nSMÜP\nBuch\; Heft'));
    expect(lines.where((l) => l == 'STATUS:CANCELLED'), hasLength(1));
  });

  test('long lines are folded at 75 bytes, counting umlauts as two', () {
    final long = buildIcs([
      lessons.first.copyWith(info: 'Ä' * 60),
    ], now: DateTime.utc(2026));
    for (final line in long.split('\r\n')) {
      expect(utf8.encode(line).length, lessThanOrEqualTo(75));
    }
    final unfolded = long.replaceAll('\r\n ', '');
    expect(unfolded, contains('Ä' * 60));
  });
}
