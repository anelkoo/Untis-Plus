import 'package:material_ui/material_ui.dart';

// Slate blue: calm enough for a screen you look at many times a day, distinct from Untis' own colours.
const _seed = Color(0xFF2F5D8A);

ThemeData appTheme(Brightness brightness) => ThemeData(
      colorScheme: .fromSeed(seedColor: _seed, brightness: brightness),
      inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
    );
