import 'dart:async';
import 'dart:io';

import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/errors/failure_text.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/settings.dart';
import '../../background/background_refresh.dart';
import '../../more/more_drawer.dart';
import '../../notifications/change_notifier.dart';
import '../data/timetable_repository.dart';
import '../domain/lesson.dart';
import 'day_view.dart';
import 'jump.dart';
import 'lesson_widgets.dart';
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
  // null: my own timetable; else a teacher's, room's or class's, filtered from all classes.
  ({Named who, Pick kind})? _filter;

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
    timetableJump.addListener(_onJump);
    unawaited(requestNotificationPermission());
    // Back in the foreground: refresh (at most once a minute), which also notifies changes.
    _lifecycle = AppLifecycleListener(onResume: () => _refreshMine(const Duration(minutes: 1)));
    // Desktop has no OS background jobs, so refresh on a timer while the app is open.
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      _desktopTimer = Timer.periodic(desktopInterval, (_) => _refreshMine(desktopInterval));
    }
  }

  /// A test or homework entry was tapped: show its day and open the lesson.
  Future<void> _onJump() async {
    final jump = timetableJump.value;
    if (jump == null || _weekMode == null) return;
    timetableJump.value = null;
    setState(() {
      _filter = null;
      _setMode(_weekMode!, day: jump.start);
    });
    try {
      final week = await ref.read(weekProvider(me, mondayOf(jump.start)).future);
      final lesson = lessonFor(jump, week.lessons);
      if (mounted && lesson != null) showLessonDetails(context, lesson);
    } on Object {
      // The day is shown anyway.
    }
  }

  void _refreshMine(Duration minAge) => unawaited(refreshMineNow(ref, minAge: minAge).catchError((Object _) {}));

  @override
  void dispose() {
    timetableJump.removeListener(_onJump);
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
        leading: const MenuButton(),
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
          PopupMenuButton<Pick>(
            tooltip: l.otherTimetables,
            icon: const Icon(Icons.person_search_outlined),
            onSelected: (kind) async {
              final who = await showTeacherPicker(context, mondayOf(_shownDay), kind: kind);
              if (who != null) setState(() => _filter = (who: who, kind: kind));
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: Pick.klass, child: Text(l.classSearch)),
              PopupMenuItem(value: Pick.teacher, child: Text(l.teacherSearch)),
              PopupMenuItem(value: Pick.room, child: Text(l.roomSearch)),
            ],
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
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: switch (_filter) {
              (:final who, :final kind) => InputChip(
                  avatar: Icon(switch (kind) {
                    Pick.room => Icons.meeting_room_outlined,
                    Pick.klass => Icons.groups_outlined,
                    _ => Icons.person_outline,
                  }),
                  label: Text(l.timetableOf(
                    who.longName.isEmpty || who.longName == who.name ? who.name : '${who.longName} (${who.name})',
                  )),
                  deleteButtonTooltipMessage: l.myTimetable,
                  onDeleted: () => setState(() => _filter = null),
                ),
              null => Text(l.ownTimetable, style: Theme.of(context).textTheme.titleMedium),
            },
          ),
          Expanded(
            // Rebuilds the pages when a look toggle or colour changes.
            child: ListenableBuilder(listenable: Listenable.merge([look, colors]), builder: (context, _) => ScrollConfiguration(
              // The mouse drags the pages like a finger or a touchpad does.
              behavior: ScrollConfiguration.of(context).copyWith(dragDevices: PointerDeviceKind.values.toSet()),
              child: PageView.builder(
                key: ObjectKey(_pager),
                controller: _pager,
                onPageChanged: (p) => setState(() => _page = p),
                itemBuilder: (context, page) {
                  final day = weekMode ? _weekAt(page) : _dayAt(page);
                  return _WeekPage(monday: mondayOf(day), day: weekMode ? null : day, filter: _filter);
                },
              ),
            )),
          ),
        ],
      ),
    )));
  }
}

/// Loads one week and shows it as a grid, or as the list of [day]: mine, or a
/// teacher's, room's or class's from [filter] (filtered from all class timetables).
class _WeekPage extends ConsumerWidget {
  const _WeekPage({required this.monday, this.day, this.filter});

  final DateTime monday;
  final DateTime? day;
  final ({Named who, Pick kind})? filter;

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
    ({Named who, Pick kind})? teacher,
    Future<void> Function() refresh,
  ) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final theme = Theme.of(context);
    final lessons = switch (teacher) {
      null => value.lessons,
      (:final who, :final kind) => value.lessons
          .where((x) => (switch (kind) {
                Pick.room => x.rooms,
                Pick.klass => x.classes,
                _ => x.teachers,
              })
              .any((t) => t.name == who.name))
          .toList(),
    };
    // Other teachers' and rooms' lessons show their classes; the rest show the teachers.
    final showClasses = teacher != null && (teacher.kind == Pick.teacher || teacher.kind == Pick.room);
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
                    showClasses: showClasses,
                    holidays: value.holidays,
                  )
                : DayList(
                    day: day!,
                    lessons: lessons,
                    now: clock(),
                    showClasses: showClasses,
                    holidays: value.holidays,
                  ),
          ),
        ),
      ],
    );
  }
}
