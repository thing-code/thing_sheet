import 'package:cupertino_ui/cupertino_ui.dart' as cupertino;
import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart' show Material, Theme;
import 'package:thing_sheet/src/thing_pop_up.dart';

/// Convenience entry points for showing popup and bottom-sheet surfaces.
///
/// The helper methods in this class wrap the package's internal route
/// implementations so applications can present modal surfaces with a consistent
/// API.
class ThingSheet {
  /// Shows a popup-style modal surface using the package's spring-based route.
  ///
  /// The returned [Future] resolves with the value passed to [Navigator.pop]
  /// when the popup is dismissed.
  static Future<T?> showPopUp<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool showDragHandle = true,
    bool isDismissable = true,
    bool useRootNavigator = true,
  }) => ThingPopUp.show(
    context,
    isDismissable: isDismissable,
    showDragHandle: showDragHandle,
    useRootNavigator: useRootNavigator,
    builder: builder,
  );

  /// Shows a full-width bottom sheet with scrollable content.
  ///
  /// The provided [builder] receives the current [BuildContext] and a
  /// [ScrollController] so the sheet can host lists, scroll views, and other
  /// content that reacts to user scrolling.
  static Future<T?> showSheet<T>({
    required BuildContext context,
    required ScrollableWidgetBuilder builder,
    bool showDragHandle = false,
    bool useNestedNavigation = false,
    bool enableDrag = true,
    double? topGap,
  }) => cupertino.showCupertinoSheet(
    context: context,
    useNestedNavigation: useNestedNavigation,
    showDragHandle: showDragHandle,
    scrollableBuilder: (context, scrollController) {
      final Color backgroundColor = Theme.of(context).colorScheme.surface;
      return Material(
        color: backgroundColor,
        child: builder(context, scrollController),
      );
    },
    topGap: topGap,
    enableDrag: enableDrag,
  );
}
