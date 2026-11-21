import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/errors/failure_text.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/timetable_repository.dart';
import 'day_view.dart';
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

  @override
  void dispose() {
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

    return Scaffold(
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
            tooltip: l.signOut,
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Row(children: [
            IconButton(
              tooltip: weekMode ? l.previousWeek : l.previousDay,
              icon: const Icon(Icons.chevron_left),
              onPressed: () => _step(-1),
            ),
            Expanded(child: TextButton(onPressed: _pick, child: Text(label))),
            IconButton(
              tooltip: weekMode ? l.nextWeek : l.nextDay,
              icon: const Icon(Icons.chevron_right),
              onPressed: () => _step(1),
            ),
          ]),
        ),
      ),
      body: PageView.builder(
        key: ObjectKey(_pager),
        controller: _pager,
        onPageChanged: (p) => setState(() => _page = p),
        itemBuilder: (context, page) {
          final day = weekMode ? _weekAt(page) : _dayAt(page);
          return _WeekPage(monday: mondayOf(day), day: weekMode ? null : day);
        },
      ),
    );
  }
}

/// Loads one week and shows it as a grid, or as the list of [day].
class _WeekPage extends ConsumerWidget {
  const _WeekPage({required this.monday, this.day});

  final DateTime monday;
  final DateTime? day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final provider = weekProvider(me, monday);
    final theme = Theme.of(context);

    Future<void> refresh() async {
      try {
        await refreshWeek(ref, me, monday);
      } on Object catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failureText(l, e))));
        }
      }
    }

    return switch (ref.watch(provider)) {
      AsyncValue(:final Week value) => Column(children: [
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
                  ? WeekGrid(monday: monday, lessons: value.lessons, now: clock())
                  : DayList(day: day!, lessons: value.lessons, now: clock()),
            ),
          ),
        ]),
      AsyncError(:final error) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: .min, children: [
              Text(failureText(l, error), textAlign: .center),
              const SizedBox(height: 16),
              FilledButton(onPressed: () => ref.invalidate(provider), child: Text(l.retry)),
            ]),
          ),
        ),
      _ => const Center(child: CircularProgressIndicator.adaptive()),
    };
  }
}
