import 'package:material_ui/material_ui.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/settings.dart';
import '../../core/theme/app_theme.dart';
import '../timetable/presentation/lesson_widgets.dart';

/// Appearance toggles and a colour for the app, each kind of lesson and the holidays.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    // What each slot looks like without a choice, so the dot shows the real colour.
    final defaults = {
      Slot.accent: defaultAccent,
      Slot.exam: examYellow,
      Slot.substitution: scheme.tertiary,
      Slot.roomChange: scheme.secondary,
      Slot.cancelled: scheme.surfaceContainerHighest,
      Slot.irregular: scheme.tertiary,
      Slot.holiday: scheme.tertiaryContainer,
    };
    final names = {
      Slot.accent: l.colorAccent,
      Slot.exam: l.colorExam,
      Slot.substitution: l.colorSubstitution,
      Slot.roomChange: l.colorRoomChange,
      Slot.cancelled: l.colorCancelled,
      Slot.irregular: l.colorIrregular,
      Slot.holiday: l.colorHoliday,
    };

    Widget header(String text) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
          child: Text(text, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: scheme.primary)),
        );

    Widget colorTile(Slot slot) => ValueListenableBuilder(
          valueListenable: colors,
          builder: (context, picked, _) => ListTile(
            leading: CircleAvatar(
              radius: 14,
              backgroundColor: picked[slot] ?? defaults[slot],
              child: picked[slot] == null ? null : Icon(Icons.check, size: 16, color: readableOn(picked[slot]!)),
            ),
            title: Text(names[slot]!),
            subtitle: picked[slot] == null ? Text(l.colorDefault) : null,
            onTap: () => _pickColor(context, slot, names[slot]!, picked[slot] ?? defaults[slot]!),
          ),
        );

    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          ListTile(
            leading: Image.asset('assets/icon.png', width: 48, height: 48, excludeFromSemantics: true),
            title: Text(l.appTitle),
          ),
          header(l.settingsLook),
          ValueListenableBuilder(
            valueListenable: look,
            builder: (context, on, _) => Column(children: [
              for (final (option, label) in [
                (Look.sameColor, l.lookSameColor),
                (Look.modernCards, l.lookModern),
              ])
                SwitchListTile(value: on.contains(option), onChanged: (_) => toggleLook(option), title: Text(label)),
            ]),
          ),
          header(l.settingsColors),
          colorTile(Slot.accent),
          header(l.settingsLessonColors),
          for (final s in [Slot.exam, Slot.substitution, Slot.roomChange, Slot.cancelled, Slot.irregular]) colorTile(s),
          header(l.colorHoliday),
          colorTile(Slot.holiday),
        ],
      ),
    );
  }
}

/// Swatches for a quick pick, three sliders for any other colour, and a live sample.
Future<void> _pickColor(BuildContext context, Slot slot, String title, Color start) {
  final l = AppLocalizations.of(context);
  var hsv = HSVColor.fromColor(start);
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        final color = hsv.toColor();
        Widget slider(String label, double value, double max, ValueChanged<double> onChanged) => Row(children: [
              SizedBox(width: 96, child: Text(label)),
              Expanded(child: Slider(value: value, max: max, semanticFormatterCallback: (_) => label, onChanged: onChanged)),
            ]);
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(mainAxisSize: .min, crossAxisAlignment: .start, children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Container(
                height: 56,
                alignment: .center,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
                child: Text(l.colorSample, style: TextStyle(color: readableOn(color), fontWeight: .w600)),
              ),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final c in Colors.primaries)
                  Semantics(
                    button: true,
                    label: '#${c.toARGB32().toRadixString(16).substring(2)}',
                    child: InkResponse(
                      radius: 24,
                      onTap: () => setState(() => hsv = HSVColor.fromColor(c)),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                      ),
                    ),
                  ),
              ]),
              slider(l.colorHue, hsv.hue, 360, (v) => setState(() => hsv = hsv.withHue(v))),
              slider(l.colorSaturation, hsv.saturation, 1, (v) => setState(() => hsv = hsv.withSaturation(v))),
              slider(l.colorBrightness, hsv.value, 1, (v) => setState(() => hsv = hsv.withValue(v))),
              const SizedBox(height: 8),
              Row(children: [
                TextButton(
                  onPressed: () {
                    setSlotColor(slot, null);
                    Navigator.pop(context);
                  },
                  child: Text(l.colorDefault),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () {
                    setSlotColor(slot, color);
                    Navigator.pop(context);
                  },
                  child: Text(l.colorDone),
                ),
              ]),
            ]),
          ),
        );
      },
    ),
  );
}
