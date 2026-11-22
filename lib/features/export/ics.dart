import 'dart:convert';

import '../timetable/domain/lesson.dart';

/// An iCalendar file (RFC 5545) with one event per lesson. Times are UTC, so every calendar
/// app shows them in its own time zone without a VTIMEZONE block. Cancelled lessons stay in,
/// marked cancelled, so a re-import updates them instead of leaving stale events.
String buildIcs(List<Lesson> lessons, {required DateTime now, String name = 'Untis+'}) {
  String names(List<Named> list, {bool long = false}) =>
      list.map((n) => long && n.longName.isNotEmpty ? n.longName : n.name).join(', ');
  final lines = [
    'BEGIN:VCALENDAR',
    'VERSION:2.0',
    'PRODID:-//Untis+//Timetable//DE',
    'CALSCALE:GREGORIAN',
    'X-WR-CALNAME:${_escape(name)}',
    for (final l in lessons) ...[
      'BEGIN:VEVENT',
      // Stable per period, so importing again replaces instead of duplicating.
      'UID:${l.id}-${_utc(l.start)}@untisplus',
      'DTSTAMP:${_utc(now)}',
      'DTSTART:${_utc(l.start)}',
      'DTEND:${_utc(l.end)}',
      'SUMMARY:${_escape(l.subjects.isEmpty ? l.lessonText : names(l.subjects, long: true))}',
      if (l.rooms.isNotEmpty) 'LOCATION:${_escape(names(l.rooms))}',
      'DESCRIPTION:${_escape([
        names(l.teachers),
        l.examType,
        l.lessonText,
        l.substitutionText,
        l.info,
      ].where((s) => s.isNotEmpty).toSet().join('\n'))}',
      if (l.status == .cancelled) 'STATUS:CANCELLED',
      'END:VEVENT',
    ],
    'END:VCALENDAR',
  ];
  return '${lines.map(_fold).join('\r\n')}\r\n';
}

String _utc(DateTime t) {
  final u = t.toUtc();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${u.year}${two(u.month)}${two(u.day)}T${two(u.hour)}${two(u.minute)}${two(u.second)}Z';
}

String _escape(String s) =>
    s.replaceAll(r'\', r'\').replaceAll(';', r'\;').replaceAll(',', r'\,').replaceAll('\n', r'\n');

/// Lines longer than 75 bytes continue on the next line after a space (RFC 5545 3.1).
String _fold(String line) {
  final out = StringBuffer();
  var bytes = 0;
  for (final rune in line.runes) {
    final char = String.fromCharCode(rune);
    final size = utf8.encode(char).length;
    if (bytes + size > 75) {
      out.write('\r\n ');
      bytes = 1;
    }
    out.write(char);
    bytes += size;
  }
  return out.toString();
}
