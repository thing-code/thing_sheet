import 'package:material_ui/material_ui.dart';
import 'package:thing_sheet/src/bottom_sheet_util.dart';
import 'package:thing_sheet/src/drag_handle.dart';

/// A popup-style modal surface with optional drag handle and configurable
/// margins.
///
/// This widget is used by [ThingPopUp.show] to present a compact overlay that
/// visually behaves like a modern bottom-aligned dialog while remaining easy to
/// integrate with the standard Flutter navigation stack.
class ThingPopUp extends StatelessWidget {
  /// Creates a popup surface.
  const ThingPopUp({
    super.key,
    this.showDragHandle = false,
    required this.builder,
    this.margin,
  });

  /// Whether to render the drag handle above the popup content.
  final bool showDragHandle;

  /// Builds the content displayed inside the popup surface.
  final WidgetBuilder builder;

  /// Optional custom padding around the popup. When omitted, the widget uses a
  /// safe default margin based on the viewport insets.
  final EdgeInsets? margin;

  /// Displays a popup modal using the package's spring-driven route.
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
