import 'package:cupertino_ui/cupertino_ui.dart' as cupertino;
import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart' show Material;
import 'package:thing_sheet/src/thing_pop_up.dart';

class ThingSheet {
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
      return Material(
        child: SafeArea(child: builder(context, scrollController)),
      );
    },
    topGap: topGap,
    enableDrag: enableDrag,
  );
}
