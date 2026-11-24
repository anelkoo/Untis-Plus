import 'dart:convert';
import 'dart:io';
import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Look toggles from the settings screen.
enum Look { sameColor, modernCards }

/// Things whose colour the user can change. A slot without an entry keeps its default.
enum Slot { accent, exam, substitution, roomChange, cancelled, irregular, holiday }

/// The toggles that are on, and the colours the user picked. Each is a small JSON file in the
/// app support folder.
final look = ValueNotifier<Set<Look>>({});
final colors = ValueNotifier<Map<Slot, Color>>({});

Future<File> _file(String name) async => File('${(await getApplicationSupportDirectory()).path}/$name.json');

Future<void> _save(String name, Object json) async {
  try {
    await (await _file(name)).writeAsString(jsonEncode(json));
  } on Object {
    // Still applies until the app closes.
  }
}

/// Best effort: a missing or broken file keeps everything at its default.
Future<void> loadSettings() async {
  try {
    final names = jsonDecode(await (await _file('look')).readAsString()) as List;
    look.value = {for (final o in Look.values) if (names.contains(o.name)) o};
  } on Object {
    // See above.
  }
  try {
    final saved = jsonDecode(await (await _file('colors')).readAsString()) as Map;
    colors.value = {for (final s in Slot.values) if (saved[s.name] case final int argb) s: Color(argb)};
  } on Object {
    // See above.
  }
}

Future<void> toggleLook(Look option) async {
  look.value = look.value.contains(option) ? ({...look.value}..remove(option)) : {...look.value, option};
  await _save('look', [for (final o in look.value) o.name]);
}

/// Sets the colour of [slot]; null goes back to the default.
Future<void> setSlotColor(Slot slot, Color? color) async {
  colors.value = {...colors.value}..remove(slot);
  if (color != null) colors.value = {...colors.value, slot: color};
  await _save('colors', {for (final e in colors.value.entries) e.key.name: e.value.toARGB32()});
}
