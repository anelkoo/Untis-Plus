import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:untis_plus/core/l10n/app_localizations.dart';
import 'package:untis_plus/features/homework/lesson_homework.dart';
import 'package:untis_plus/features/timetable/domain/lesson.dart';
import 'package:untis_plus/features/timetable/presentation/day_view.dart';

void main() {
  testWidgets('the day list marks gaps of 15 minutes or more as a break', (tester) async {
    Lesson at(int id, int h1, int m1, int h2, int m2) => Lesson(
          id: id,
          start: DateTime(2026, 11, 24, h1, m1),
          end: DateTime(2026, 11, 24, h2, m2),
          subjects: [Named(id: id, name: 'S$id')],
        );
    await tester.pumpWidget(ProviderScope(
      overrides: [lessonHomeworkProvider.overrideWith((ref, lesson) => const [])],
      child: MaterialApp(
        localizationsDelegates: const [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: DayList(
            day: DateTime(2026, 11, 24),
            lessons: [
              at(1, 8, 0, 8, 50),
              at(2, 8, 55, 9, 45), // 5 minutes: no break
              at(3, 8, 55, 11, 0), // parallel to 2: no break before 4 from 2's end
              at(4, 11, 15, 12, 0), // 15 minutes after the latest end: break
            ],
            now: DateTime(2026, 11, 24, 7),
          ),
        ),
      ),
    ));
    expect(find.text('Free 11:00 to 11:15'), findsOneWidget);
    expect(find.textContaining('Free'), findsOneWidget);
  });
}
