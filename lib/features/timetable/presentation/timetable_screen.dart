import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/errors/failure_text.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/settings.dart';
import '../../background/background_refresh.dart';
import '../../notifications/change_notifier.dart';
import '../data/timetable_repository.dart';
import '../domain/lesson.dart';
import 'day_view.dart';
import 'teacher_picker.dart';
import 'timetable_providers.dart';
import 'week_view.dart';

/// The clock the timetable uses; tests replace it.
@visibleForTesting
DateTime Function() clock = DateTime.now;

/// The timetable: a day list or a week grid, swipeable, for the signed-in user.
class TimetableScreen extends ConsumerStatefulWidget {
  const TimetableScreen({super.key});

  @override
  ConsumerState<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends ConsumerState<TimetableScreen> {
  // Pages are counted from an anchor in the middle so both directions can be swiped.
  static const _anchor = 10000;

  // On Saturday and Sunday, start with the coming week.
  final _baseMonday = mondayOf(clock().add(const Duration(days: 2)));
  bool? _weekMode; // null until the screen width picks a default
  late PageController _pager;
  int _page = _anchor;
  // null: my own timetable; else a teacher's or a room's, filtered from all classes.
  ({Named who, bool room})? _filter;

  DateTime _weekAt(int page) => DateTime(_baseMonday.year, _baseMonday.month, _baseMonday.day + 7 * (page - _anchor));

  /// School days only (Monday to Friday). shortcut: Saturday lessons show only in the week view.
  DateTime _dayAt(int page) {
    final d = page - _anchor;
    final weeks = (d / 5).floor();
    return DateTime(_baseMonday.year, _baseMonday.month, _baseMonday.day + 7 * weeks + d - 5 * weeks);
  }

  int _pageFor(DateTime day, bool weekMode) {
    final weeks = (mondayOf(day).difference(_baseMonday).inHours / (24 * 7)).round();
    return _anchor + (weekMode ? weeks : 5 * weeks + (day.weekday > 5 ? 4 : day.weekday - 1));
  }

  DateTime get _shownDay => _weekMode! ? _weekAt(_page) : _dayAt(_page);

  void _setMode(bool weekMode, {DateTime? day}) {
    final now = clock();
    var pick = day ?? (_weekMode == null ? now : _shownDay);
    // Going from a week to days: today if it is in that week, else its Monday.
    if (day == null && _weekMode == true && mondayOf(now) == _weekAt(_page)) pick = now;
    final page = _pageFor(pick, weekMode);
    if (_weekMode != null) _pager.dispose();
    _pager = PageController(initialPage: page);
    _weekMode = weekMode;
    _page = page;
  }

  late final AppLifecycleListener _lifecycle;
  Timer? _desktopTimer;
  // Moves the shading of past lessons along.
  late final Timer _minute = Timer.periodic(const Duration(minutes: 1), (_) => setState(() {}));

  @override
  void initState() {
    super.initState();
    _minute;
    unawaited(requestNotificationPermission());
    // Back in the foreground: refresh (at most once a minute), which also notifies changes.
    _lifecycle = AppLifecycleListener(onResume: () => _refreshMine(const Duration(minutes: 1)));
    // Desktop has no OS background jobs, so refresh on a timer while the app is open.
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      _desktopTimer = Timer.periodic(desktopInterval, (_) => _refreshMine(desktopInterval));
    }
  }

  void _refreshMine(Duration minAge) => unawaited(refreshMineNow(ref, minAge: minAge).catchError((Object _) {}));

  @override
  void dispose() {
    _lifecycle.dispose();
    _desktopTimer?.cancel();
    _minute.cancel();
    if (_weekMode != null) _pager.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final now = clock();
    final day = await showDatePicker(
      context: context,
      initialDate: _shownDay,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (day != null) setState(() => _setMode(_weekMode!, day: day));
  }

  void _step(int delta) =>
      _pager.animateToPage(_page + delta, duration: const Duration(milliseconds: 250), curve: Curves.easeOutCubic);

  @override
  Widget build(BuildContext context) {
    if (_weekMode == null) _setMode(MediaQuery.sizeOf(context).width >= 600);
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final weekMode = _weekMode!;
    final shown = _shownDay;
    final label = weekMode
        ? '${DateFormat.Md(locale).format(shown)} – ${DateFormat.Md(locale).format(shown.add(const Duration(days: 6)))}'
        : DateFormat.MMMEd(locale).format(shown);

    // Keyboard: A/D and ←/→ go back and forward one page; W/S jump a whole week, also in the day view.
    final week = weekMode ? 1 : 5;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyA): () => _step(-1),
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () => _step(-1),
        const SingleActivator(LogicalKeyboardKey.keyD): () => _step(1),
        const SingleActivator(LogicalKeyboardKey.arrowRight): () => _step(1),
        const SingleActivator(LogicalKeyboardKey.keyW): () => _step(-week),
        const SingleActivator(LogicalKeyboardKey.keyS): () => _step(week),
      },
      child: Focus(autofocus: true, child: Scaffold(
      appBar: AppBar(
        title: SegmentedButton<bool>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(value: false, label: Text(l.viewDay), icon: const Icon(Icons.view_agenda_outlined)),
            ButtonSegment(value: true, label: Text(l.viewWeek), icon: const Icon(Icons.calendar_view_week)),
          ],
          selected: {weekMode},
          onSelectionChanged: (s) => setState(() => _setMode(s.first)),
        ),
        actions: [
          IconButton(
            tooltip: l.teacherSearch,
            icon: const Icon(Icons.person_search_outlined),
            onPressed: () async {
              final teacher = await showTeacherPicker(context, mondayOf(_shownDay));
              if (teacher != null) setState(() => _filter = (who: teacher, room: false));
            },
          ),
          IconButton(
            tooltip: l.roomSearch,
            icon: const Icon(Icons.meeting_room_outlined),
            onPressed: () async {
              final room = await showTeacherPicker(context, mondayOf(_shownDay), rooms: true);
              if (room != null) setState(() => _filter = (who: room, room: true));
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Row(
            children: [
              IconButton(
                tooltip: weekMode ? l.previousWeek : l.previousDay,
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _step(-1),
              ),
              Expanded(
                child: TextButton(onPressed: _pick, child: Text(label)),
              ),
              IconButton(
                tooltip: weekMode ? l.nextWeek : l.nextDay,
                icon: const Icon(Icons.chevron_right),
                onPressed: () => _step(1),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          if (_filter case (:final who, :final room))
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: InputChip(
                avatar: Icon(room ? Icons.meeting_room_outlined : Icons.person_outline),
                label: Text(
                  who.longName.isEmpty || who.longName == who.name ? who.name : '${who.longName} (${who.name})',
                ),
                deleteButtonTooltipMessage: l.myTimetable,
                onDeleted: () => setState(() => _filter = null),
              ),
            ),
          Expanded(
            // Rebuilds the pages when a look toggle or colour changes.
            child: ListenableBuilder(listenable: Listenable.merge([look, colors]), builder: (context, _) => PageView.builder(
              key: ObjectKey(_pager),
              controller: _pager,
              onPageChanged: (p) => setState(() => _page = p),
              itemBuilder: (context, page) {
                final day = weekMode ? _weekAt(page) : _dayAt(page);
                return _WeekPage(monday: mondayOf(day), day: weekMode ? null : day, filter: _filter);
              },
            )),
          ),
        ],
      ),
    )));
  }
}

/// Loads one week and shows it as a grid, or as the list of [day]: mine, or a teacher's or
/// room's from [filter] (filtered from all class timetables).
class _WeekPage extends ConsumerWidget {
  const _WeekPage({required this.monday, this.day, this.filter});

  final DateTime monday;
  final DateTime? day;
  final ({Named who, bool room})? filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final teacher = filter;
    final provider = teacher == null ? weekProvider(me, monday) : classesWeekProvider(monday);

    Future<void> refresh() async {
      try {
        await (teacher == null ? refreshWeek(ref, me, monday) : refreshClassesWeek(ref, monday));
      } on Object catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failureText(l, e))));
        }
      }
    }

    return switch (ref.watch(provider)) {
      AsyncValue(:final Week value) => _content(context, ref, value, teacher, refresh),
      AsyncError(:final error) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: .min,
            children: [
              Text(failureText(l, error), textAlign: .center),
              const SizedBox(height: 16),
              FilledButton(onPressed: () => ref.invalidate(provider), child: Text(l.retry)),
            ],
          ),
        ),
      ),
      _ => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: .min,
            children: [
              const CircularProgressIndicator.adaptive(),
              if (teacher != null) ...[const SizedBox(height: 16), Text(l.loadingClasses, textAlign: .center)],
            ],
          ),
        ),
      ),
    };
  }

  Widget _content(
    BuildContext context,
    WidgetRef ref,
    Week value,
    ({Named who, bool room})? teacher,
    Future<void> Function() refresh,
  ) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final theme = Theme.of(context);
    final lessons = teacher == null
        ? value.lessons
        : value.lessons
            .where((x) => (teacher.room ? x.rooms : x.teachers).any((t) => t.name == teacher.who.name))
            .toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Text(
            [
              l.lastUpdated(DateFormat.Md(locale).add_Hm().format(value.fetchedAt)),
              if (value.refreshError != null) failureText(l, value.refreshError!),
            ].join(' · '),
            style: theme.textTheme.labelSmall?.copyWith(
              color: value.refreshError == null ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.error,
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator.adaptive(
            onRefresh: refresh,
            child: day == null
                ? WeekGrid(
                    monday: monday,
                    lessons: lessons,
                    now: clock(),
                    showClasses: teacher != null,
                    holidays: value.holidays,
                  )
                : DayList(
                    day: day!,
                    lessons: lessons,
                    now: clock(),
                    showClasses: teacher != null,
                    holidays: value.holidays,
                  ),
          ),
        ),
      ],
    );
  }
}
