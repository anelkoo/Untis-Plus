import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../timetable/data/timetable_repository.dart';
import '../timetable/domain/lesson.dart';
import 'ics.dart';

/// How many weeks the export covers, starting with the current one.
const exportWeeks = 4;

/// Writes my timetable for the coming weeks as an .ics file. Phones get the share sheet to pick
/// a calendar app; desktop saves into Downloads. Returns the saved path on desktop, else null.
/// Weeks that can't be loaded (offline) come from the cache; throws only if none are there.
Future<String?> exportCalendar(TimetableRepository repo, {DateTime? now}) async {
  final t = now ?? DateTime.now();
  final ics = buildIcs(await exportLessons(repo, t), now: t);
  const name = 'Stundenplan.ics';
  if (Platform.isAndroid || Platform.isIOS) {
    final file = File('${(await getTemporaryDirectory()).path}/$name');
    await file.writeAsString(ics);
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path, mimeType: 'text/calendar')]));
    return null;
  }
  final dir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
  final file = File('${dir.path}${Platform.pathSeparator}$name');
  await file.writeAsString(ics);
  return file.path;
}

/// My lessons for [exportWeeks] weeks from [t], fetched at most hourly, else from the cache.
Future<List<Lesson>> exportLessons(TimetableRepository repo, DateTime t) async {
  final lessons = <Lesson>[];
  for (var i = 0; i < exportWeeks; i++) {
    final monday = mondayOf(t.add(Duration(days: 7 * i)));
    try {
      lessons.addAll((await repo.refresh(me, monday, minAge: const Duration(hours: 1))).lessons);
    } on Object {
      if (await repo.cached(me, monday) case final week?) {
        lessons.addAll(week.lessons);
      } else if (i == 0) {
        rethrow;
      }
    }
  }
  return lessons;
}
