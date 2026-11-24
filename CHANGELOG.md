# Changelog

## 0.3.3 (2026-11-24)

### Added
- Tapping a test or a homework entry opens its lesson in the timetable.

### Changed
- Tests and homework rows have lines between them, and every second row is slightly darker.
- The timetable is the middle tab of the bottom bar.
- Lesson details, the colour picker and the teacher and room search open as a popup in a wide window and as a swipe-up sheet in a narrow one.
- README lists the current features.

## 0.3.2 (2026-11-24)

### Added
- Burger menu at the top left of every tab replaces the "More" tab (#5).
- The settings switch for one colour per lesson is now called "Simple design" (#1).

### Changed
- Substitutions, room changes and irregular lessons are filled completely, like tests (#3).
- The database lives in the app data folder instead of Documents. An existing database is moved on first start (#2).
- Linux keeps everything in `~/.local/share/untis-plus`.

### Fixed
- Windows taskbar icon (#4) and Linux window and taskbar icons.

## 0.3.1 (2026-11-24)

### Fixed
- Android build failed because of a broken string in the homework widget code, so 0.3.0 was never published. 0.3.1 contains everything from 0.3.0.

## 0.3.0 (2026-11-24, not published)

### Added
- Bottom bar with Timetable, Homework and Tests.
- Homework screen, grouped into overdue, today, tomorrow, this week, later and done.
- Two home screen widgets on Android and iOS: homework by tomorrow, homework this week.
- Tests screen listing the coming exams.
- Settings screen with custom colours and a switch for the modern lesson design.
- New app icon.

### Changed
- Absences, calendar export, settings and sign out moved out of the timetable menu.
- Android releases are signed with a fixed key. Updating from 0.2.1 or older needs one uninstall, which clears login and cache.
