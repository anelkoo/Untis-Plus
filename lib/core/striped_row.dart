import 'package:material_ui/material_ui.dart';

/// A list row with a line under it, and every second row a little darker so rows are easy to tell apart.
Widget stripedRow(BuildContext context, int index, Widget tile) {
  final scheme = Theme.of(context).colorScheme;
  return Column(mainAxisSize: .min, children: [
    Material(color: index.isOdd ? scheme.onSurface.withValues(alpha: 0.06) : Colors.transparent, child: tile),
    Divider(height: 1, color: scheme.outlineVariant),
  ]);
}
