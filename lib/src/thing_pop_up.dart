import 'package:material_ui/material_ui.dart';
import 'package:thing_sheet/src/bottom_sheet_util.dart';
import 'package:thing_sheet/src/drag_handle.dart';

class ThingPopUp extends StatelessWidget {
  const ThingPopUp({
    super.key,
    this.showDragHandle = false,
    required this.builder,
    this.margin,
  });

  final bool showDragHandle;
  final WidgetBuilder builder;
  final EdgeInsets? margin;

  static Future<T?> show<T>(
    BuildContext context, {
    bool showDragHandle = false,
    bool isDismissable = true,
    bool useRootNavigator = true,
    required WidgetBuilder builder,
    EdgeInsets? margin,
  }) {
    return showPopUp(
      context: context,
      isDismissable: isDismissable,
      rootNavigator: useRootNavigator,
      builder: (context) {
        return ThingPopUp(
          showDragHandle: showDragHandle,
          builder: builder,
          margin: margin,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.of(context).size;
    final double top = MediaQuery.viewPaddingOf(context).top;
    final double bottom = MediaQuery.viewPaddingOf(context).bottom;
    final Color backgroundColor = Theme.of(context).colorScheme.surface;

    return Padding(
      padding: margin ?? .fromLTRB(24, top, 24, bottom > 24 ? 24 : bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 640,
          maxHeight: screen.height - top,
        ),
        child: Material(
          color: backgroundColor,
          shape: RoundedRectangleBorder(borderRadius: .circular(36)),
          clipBehavior: .antiAlias,
          child: Padding(
            padding: showDragHandle ? .fromLTRB(20, 0, 20, 20) : .all(20),
            child: Column(
              mainAxisSize: .min,
              crossAxisAlignment: .stretch,
              children: [if (showDragHandle) DragHandle(), builder(context)],
            ),
          ),
        ),
      ),
    );
  }
}
