import 'package:material_ui/material_ui.dart';

/// Windows narrower than this get a swipe-up sheet, wider ones a centred popup.
const popupMinWidth = 700.0;

/// Shows [builder] as a bottom sheet in a narrow window and as a popup in a wide one.
Future<T?> showAdaptiveSheet<T>(BuildContext context, WidgetBuilder builder) {
  if (MediaQuery.sizeOf(context).width < popupMinWidth) {
    return showModalBottomSheet<T>(context: context, showDragHandle: true, isScrollControlled: true, useSafeArea: true, builder: builder);
  }
  return showDialog<T>(
    context: context,
    builder: (context) => Dialog(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 560), child: builder(context))),
  );
}
