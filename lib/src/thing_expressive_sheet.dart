import 'package:flutter/material.dart';
import 'package:thing_sheet/src/show_spring_bottom_sheet.dart';

class ThingExpressiveSheet extends StatelessWidget {
  const ThingExpressiveSheet({
    super.key,
    this.showIndicator = true,
    required this.builder,
  });

  final bool showIndicator;
  final WidgetBuilder builder;

  static Future<T?> show<T>(
    BuildContext context, {
    bool showIndicator = true,
    bool isDismissable = true,
    bool useRootNavigator = true,
    required WidgetBuilder builder,
  }) {
    return showSpringBottomSheet(
      context: context,
      isDismissable: isDismissable,
      rootNavigator: useRootNavigator,
      builder: (context) {
        return ThingExpressiveSheet(
          showIndicator: showIndicator,
          builder: builder,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Size screen = MediaQuery.of(context).size;
    final double top = MediaQuery.paddingOf(context).top;
    final double bottom = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: .fromLTRB(16, 16, 16, bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 640,
          maxHeight: screen.height - top,
        ),
        child: Material(
          color: scheme.surfaceContainerHigh,
          shape: RoundedRectangleBorder(borderRadius: .circular(40)),
          clipBehavior: .antiAlias,
          child: Padding(
            padding: showIndicator ? .fromLTRB(20, 0, 20, 20) : .all(20),
            child: Column(
              mainAxisSize: .min,
              crossAxisAlignment: .stretch,
              children: [if (showIndicator) _Indicator(), builder(context)],
            ),
          ),
        ),
      ),
    );
  }
}

class _Indicator extends StatelessWidget {
  const _Indicator();

  @override
  Widget build(BuildContext context) {
    final Color indicatorColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return Align(
      alignment: .center,
      child: Padding(
        padding: .symmetric(vertical: 12),
        child: Container(
          height: 4,
          width: 32,
          decoration: BoxDecoration(
            borderRadius: .circular(24),
            color: indicatorColor,
          ),
        ),
      ),
    );
  }
}
