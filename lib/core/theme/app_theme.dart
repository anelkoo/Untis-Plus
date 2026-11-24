import 'package:material_ui/material_ui.dart';

// Slate blue: calm enough for a screen you look at many times a day, distinct from Untis' own colours.
const _seed = Color(0xFF2F5D8A);

const defaultAccent = _seed;

ThemeData appTheme(Brightness brightness, [Color seed = _seed]) => ThemeData(
      colorScheme: .fromSeed(seedColor: seed, brightness: brightness),
      inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
    );
