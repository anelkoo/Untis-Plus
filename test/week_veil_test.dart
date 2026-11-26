import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:untis_plus/core/l10n/app_localizations.dart';
import 'package:untis_plus/features/homework/lesson_homework.dart';
import 'package:untis_plus/features/timetable/domain/lesson.dart';
import 'package:untis_plus/features/timetable/presentation/week_view.dart';

void main() {
  testWidgets('the week grid veils past days fully and today up to now', (tester) async {
    final monday = DateTime(2026, 11, 23);
    Lesson at(int id, int day, int hour) => Lesson(
          id: id,
          start: DateTime(2026, 11, 23 + day, hour),
          end: DateTime(2026, 11, 23 + day, hour, 50),
          subjects: const [Named(id: 1, name: 'AM')],
        );
    await tester.pumpWidget(ProviderScope(
      overrides: [lessonHomeworkProvider.overrideWith((ref, lesson) => const [])],
      child: MaterialApp(
      localizationsDelegates: const [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: WeekGrid(
          monday: monday,
          lessons: [at(1, 0, 8), at(2, 1, 8), at(3, 1, 10), at(4, 2, 8)],
          now: DateTime(2026, 11, 24, 9, 20),
        ),
      ),
    )));
    final scheme = Theme.of(tester.element(find.byType(WeekGrid))).colorScheme;
    final veils = find.byWidgetPredicate((w) => w is ColoredBox && w.color == scheme.surface.withValues(alpha: 0.55));
    expect(veils, findsNWidgets(2)); // Monday whole, Tuesday up to 9:20
    final tuesday = tester.getSize(veils.last).height;
    final monday8 = tester.getSize(veils.first).height;
    expect(tuesday, lessThan(monday8));
    expect(tuesday, greaterThan(0));
  });
}
