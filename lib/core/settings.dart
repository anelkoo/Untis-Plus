import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Look toggles from the ⋮ menu.
enum Look { sameColor, dayLookInWeek, weekLookInDay }

/// The toggles that are on. Stored as a small JSON file in the app support folder.
final look = ValueNotifier<Set<Look>>({});

Future<File> _file() async => File('${(await getApplicationSupportDirectory()).path}/look.json');

/// Best effort: a missing or broken file keeps everything off.
Future<void> loadLook() async {
  try {
    final names = jsonDecode(await (await _file()).readAsString()) as List;
    look.value = {for (final o in Look.values) if (names.contains(o.name)) o};
  } on Object {
    // See above.
  }
}

Future<void> toggleLook(Look option) async {
  look.value = look.value.contains(option) ? ({...look.value}..remove(option)) : {...look.value, option};
  try {
    await (await _file()).writeAsString(jsonEncode([for (final o in look.value) o.name]));
  } on Object {
    // Still applies until the app closes.
  }
}
