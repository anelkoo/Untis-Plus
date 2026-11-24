# Untis+

A fast WebUntis client for iOS, Android, Windows and Linux. It opens on your timetable and keeps it fresh, tells you when something changes, and shows homework and tests next to it.

Personal project, not affiliated with Untis GmbH.

## Features

**Timetable**
- Day list and week grid, swipe or use the keyboard (A/D or the arrow keys for a page, W/S for a week). Wide windows start in the week grid.
- Substitutions, room changes, irregular lessons and tests are filled in completely, so changes stand out. Cancelled lessons are greyed out.
- Timetables of other teachers and rooms, built from all class timetables. Teachers can be starred as favourites.
- School holidays and absences (with how many lessons you missed, and which are excused).
- Works offline from the cache. Pull to refresh, with a rate limit that keeps the load on the school's server low.

**Homework and tests**
- Homework grouped by when it is due: overdue, today, tomorrow, this week, later, done.
- A list of the coming tests.
- Tap an entry to jump to its lesson in the timetable.
- Rows have lines between them, and every second row is slightly darker.

**Notifications and widgets**
- Change notifications when a lesson is substituted, moved or cancelled. Android refreshes in the background; the desktop apps refresh while open.
- Home screen widgets for Android and iOS: the timetable, the next test, homework due by tomorrow and homework due this week.

**More**
- Export your timetable for the next four weeks as an `.ics` calendar file.
- Settings: an accent colour, a colour for each kind of lesson, a "Simple design" switch (one colour for all lessons) and a modern lesson design with stripes instead of fills.
- German and English.
- Menus and pickers open as a swipe-up sheet in a narrow window and as a popup in a wide one.

## Platforms

| | Install with |
|---|---|
| Android | `UntisPlus.apk` |
| iOS | `UntisPlus.ipa`, unsigned, for SideStore |
| Windows | `UntisPlus-Setup.exe` or the portable zip |
| Linux | `.deb`, `.AppImage`, Arch package or `.tar.gz` |

Your password is stored in the system keychain. The cache and settings live in the app data folder (`~/.local/share/untis-plus` on Linux).

## Links

- Downloads: [Releases](https://github.com/anelkoo/Untis-Plus/releases)
- What changed: [CHANGELOG.md](CHANGELOG.md)
- Build and install guide: [docs/SETUP.md](docs/SETUP.md)
