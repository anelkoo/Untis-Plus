import 'package:material_ui/material_ui.dart';

import 'core/l10n/app_localizations.dart';
import 'features/exams/exams_screen.dart';
import 'features/homework/homework_screen.dart';
import 'features/more/more_screen.dart';
import 'features/timetable/presentation/timetable_screen.dart';

/// The signed-in app: four tabs behind a bottom bar. Tabs keep their state while hidden.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: IndexedStack(index: _tab, children: const [
        TimetableScreen(),
        HomeworkScreen(),
        ExamsScreen(),
        MoreScreen(),
      ]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.calendar_today_outlined), label: l.navTimetable),
          NavigationDestination(icon: const Icon(Icons.menu_book_outlined), label: l.navHomework),
          NavigationDestination(icon: const Icon(Icons.edit_note), label: l.navTests),
          NavigationDestination(icon: const Icon(Icons.more_horiz), label: l.navMore),
        ],
      ),
    );
  }
}
