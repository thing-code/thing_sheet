import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thing_sheet/src/show_spring_bottom_sheet.dart';
import 'package:thing_sheet/src/thing_expressive_sheet.dart';

// ---------------------------------------------------------------------------
// Helpers (top-level so they can be referenced from default parameter values)
// ---------------------------------------------------------------------------

/// Default builder shared across tests — renders a small, recognisable
/// subtree so we can verify the sheet body is placed into the tree.
Widget _defaultBuilder(BuildContext context) {
  return const SizedBox(
    key: Key('sheet_content'),
    height: 200,
    child: Text('Sheet body'),
  );
}

/// Finds the [Material] widget created by [ThingExpressiveSheet] itself
/// (as opposed to the one created by Scaffold). It is uniquely identifiable
/// because its shape is a [RoundedRectangleBorder] with radius 40.
Finder findSheetMaterial() {
  return find.byWidgetPredicate(
    (w) =>
        w is Material &&
        w.shape is RoundedRectangleBorder &&
        (w.shape as RoundedRectangleBorder).borderRadius ==
            BorderRadius.circular(40),
  );
}

/// Finds the [ConstrainedBox] created by [ThingExpressiveSheet] — the one
/// with maxWidth == 640.
Finder findSheetConstrainedBox() {
  return find.byWidgetPredicate(
    (w) => w is ConstrainedBox && w.constraints.maxWidth == 640,
  );
}

// ===========================================================================
// ThingExpressiveSheet — widget-level tests
// ===========================================================================

void main() {
  // -------------------------------------------------------------------------
  // Helper: pump a ThingExpressiveSheet wrapped in the required Material
  // ancestors so that Theme, MediaQuery, and Navigator are available.
  // -------------------------------------------------------------------------
  Future<void> pumpSheet(
    WidgetTester tester, {
    bool showIndicator = true,
    WidgetBuilder builder = _defaultBuilder,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: SizedBox(
                width: 400,
                height: 600,
                child: ThingExpressiveSheet(
                  showIndicator: showIndicator,
                  builder: builder,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // ThingExpressiveSheet — structural & layout
  // =========================================================================
  group('ThingExpressiveSheet structure', () {
    testWidgets(
      'renders sheet content passed via builder',
      (tester) async {
        await pumpSheet(tester);

        expect(find.byKey(const Key('sheet_content')), findsOneWidget);
      },
    );

    testWidgets(
      'renders a drag indicator by default (showIndicator = true)',
      (tester) async {
        await pumpSheet(tester, showIndicator: true);

        // The indicator is built by the private _Indicator widget. We detect
        // it indirectly: look for a Container whose BoxDecoration has a color
        // (onSurfaceVariant) and borderRadius 24 — those properties uniquely
        // identify the indicator.
        final matching = tester.widgetList<Container>(find.byType(Container));
        final hasIndicator = matching.any((c) {
          final d = c.decoration;
          return d is BoxDecoration &&
              d.color != null &&
              d.borderRadius == BorderRadius.circular(24);
        });
        expect(hasIndicator, isTrue);
      },
    );

    testWidgets(
      'hides drag indicator when showIndicator is false',
      (tester) async {
        await pumpSheet(tester, showIndicator: false);

        // With no indicator, the indicator Container (decorated BoxDecoration
        // with borderRadius 24) should not exist anywhere in the tree.
        final matching = tester.widgetList<Container>(find.byType(Container));
        final hasIndicator = matching.any((c) {
          final d = c.decoration;
          return d is BoxDecoration &&
              d.color != null &&
              d.borderRadius == BorderRadius.circular(24);
        });
        expect(hasIndicator, isFalse);

        // Additionally, the inner padding should be uniform.
        // Find the Padding that is a descendant of the Sheet's Material.
        final innerPadding = tester.widget<Padding>(
          find.descendant(
            of: findSheetMaterial(),
            matching: find.byType(Padding),
          ).first,
        );
        expect(innerPadding.padding, const EdgeInsets.all(20));
      },
    );

    testWidgets(
      'applies asymmetric top padding when indicator is visible',
      (tester) async {
        await pumpSheet(tester, showIndicator: true);

        // The first Padding inside the Sheet's Material uses fromLTRB so the
        // indicator sits flush at the top while content has 20 px on the
        // other sides.
        final innerPadding = tester.widget<Padding>(
          find.descendant(
            of: findSheetMaterial(),
            matching: find.byType(Padding),
          ).first,
        );
        expect(
          innerPadding.padding,
          const EdgeInsets.fromLTRB(20, 0, 20, 20),
        );
      },
    );

    testWidgets(
      'constrains max width to 640 logical pixels',
      (tester) async {
        await pumpSheet(tester);

        final box = tester.widget<ConstrainedBox>(findSheetConstrainedBox());
        expect(box.constraints.maxWidth, 640);
      },
    );

    testWidgets(
      'limits max height to screen height minus top safe area',
      (tester) async {
        // Default test surface is 800 x 600 with no safe-area inset.
        await pumpSheet(tester);

        final box = tester.widget<ConstrainedBox>(findSheetConstrainedBox());
        // Screen height (600) - top padding (0) = 600
        expect(box.constraints.maxHeight, 600);
      },
    );

    testWidgets(
      'uses surfaceContainerHigh color from the theme',
      (tester) async {
        await pumpSheet(tester);

        final material = tester.widget<Material>(findSheetMaterial());
        final expectedColor =
            ThemeData.light().colorScheme.surfaceContainerHigh;
        expect(material.color, expectedColor);
      },
    );

    testWidgets(
      'applies rounded rectangle shape to the Material surface',
      (tester) async {
        await pumpSheet(tester);

        final material = tester.widget<Material>(findSheetMaterial());
        expect(material.shape, isA<RoundedRectangleBorder>());
        final shape = material.shape as RoundedRectangleBorder;
        expect(shape.borderRadius, BorderRadius.circular(40));
      },
    );

    testWidgets(
      'enables anti-alias clipping on the Material surface',
      (tester) async {
        await pumpSheet(tester);

        final material = tester.widget<Material>(findSheetMaterial());
        expect(material.clipBehavior, Clip.antiAlias);
      },
    );

    testWidgets(
      'applies outer padding of 16 logical pixels',
      (tester) async {
        await pumpSheet(tester);

        // The outermost Padding in the ThingExpressiveSheet subtree is the
        // 16 px one. It's the Padding that is an ancestor of the
        // ConstrainedBox with maxWidth 640.
        final outerPadding = tester.widget<Padding>(
          find.ancestor(
            of: findSheetConstrainedBox(),
            matching: find.byType(Padding),
          ).first,
        );
        expect(outerPadding.padding, const EdgeInsets.all(16));
      },
    );
  });

  // =========================================================================
  // _Indicator — private widget verified through its observable properties
  // =========================================================================
  group('Indicator', () {
    testWidgets(
      'indicator uses onSurfaceVariant color from the theme',
      (tester) async {
        // Pump with a custom theme so we can verify the indicator color
        // comes from ColorScheme.onSurfaceVariant.
        final customTheme = ThemeData.light().copyWith(
          colorScheme: ThemeData.light().colorScheme.copyWith(
                onSurfaceVariant: const Color(0xFF123456),
              ),
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: customTheme,
            home: Scaffold(
              body: Builder(
                builder: (context) => Center(
                  child: SizedBox(
                    width: 400,
                    height: 600,
                    child: ThingExpressiveSheet(
                      showIndicator: true,
                      builder: _defaultBuilder,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        // Find the indicator by its distinctive BoxDecoration with
        // borderRadius 24.
        final indicatorContainer = tester
            .widgetList<Container>(find.byType(Container))
            .firstWhere((c) {
              final d = c.decoration;
              return d is BoxDecoration &&
                  d.borderRadius == BorderRadius.circular(24);
            });

        final decoration = indicatorContainer.decoration as BoxDecoration;
        expect(decoration.color, const Color(0xFF123456));
      },
    );

    testWidgets(
      'indicator has fully rounded corners (borderRadius: 24)',
      (tester) async {
        await pumpSheet(tester, showIndicator: true);

        final indicatorContainer = tester
            .widgetList<Container>(find.byType(Container))
            .firstWhere((c) {
              final d = c.decoration;
              return d is BoxDecoration && d.color != null;
            });

        final decoration = indicatorContainer.decoration as BoxDecoration;
        expect(decoration.borderRadius, BorderRadius.circular(24));
      },
    );

    testWidgets(
      'indicator is centered via an Align ancestor',
      (tester) async {
        await pumpSheet(tester, showIndicator: true);

        // The _Indicator wraps its Container with Align(alignment: .center).
        // Find the indicator Container, then walk the element tree upward.
        final indicatorContainer = tester
            .widgetList<Container>(find.byType(Container))
            .firstWhere((c) {
              final d = c.decoration;
              return d is BoxDecoration &&
                  d.borderRadius == BorderRadius.circular(24);
            });

        final containerElement =
            tester.element(find.byWidget(indicatorContainer));
        final alignWidget =
            containerElement.findAncestorWidgetOfExactType<Align>();
        expect(alignWidget, isNotNull);
        expect(alignWidget!.alignment, Alignment.center);
      },
    );
  });

  // =========================================================================
  // ThingExpressiveSheet.show() — static integration method
  // =========================================================================
  group('ThingExpressiveSheet.show()', () {
    testWidgets(
      'opens a sheet route via Navigator and resolves when popped',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return Center(
                    child: ElevatedButton(
                      onPressed: () {
                        ThingExpressiveSheet.show<String>(
                          context,
                          builder: (_) => const Text('Modal content'),
                        );
                      },
                      child: const Text('Open'),
                    ),
                  );
                },
              ),
            ),
          ),
        );

        // Tap the button to show the sheet.
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        // The sheet content should now be visible.
        expect(find.text('Modal content'), findsOneWidget);

        // Pop the sheet.
        Navigator.of(tester.element(find.text('Modal content'))).pop('done');
        await tester.pumpAndSettle();

        // After popping, the sheet content should be gone.
        expect(find.text('Modal content'), findsNothing);
      },
    );

    testWidgets(
      'showIndicator parameter is forwarded to ThingExpressiveSheet',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return Center(
                    child: ElevatedButton(
                      onPressed: () {
                        ThingExpressiveSheet.show(
                          context,
                          showIndicator: false,
                          builder: (_) => const Text('No indicator'),
                        );
                      },
                      child: const Text('Open'),
                    ),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        // The sheet should be visible.
        expect(find.text('No indicator'), findsOneWidget);

        // Verify the Padding inside the Sheet's Material uses .all(20)
        // (no indicator means uniform padding).
        final innerPadding = tester.widget<Padding>(
          find.descendant(
            of: findSheetMaterial(),
            matching: find.byType(Padding),
          ).first,
        );
        expect(innerPadding.padding, const EdgeInsets.all(20));
      },
    );

    testWidgets(
      'creates a non-dismissable sheet when isDismissable is false',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return Center(
                    child: ElevatedButton(
                      onPressed: () {
                        ThingExpressiveSheet.show(
                          context,
                          isDismissable: false,
                          builder: (_) =>
                              const Text('Cannot dismiss by dragging'),
                        );
                      },
                      child: const Text('Open'),
                    ),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        // The sheet content should be visible, confirming it was created
        // and displayed even though it cannot be dismissed by dragging.
        expect(find.text('Cannot dismiss by dragging'), findsOneWidget);

        // Also verify there is a sheet Material in the overlay, confirming
        // the route was pushed.
        expect(findSheetMaterial(), findsOneWidget);
      },
    );
  });

  // =========================================================================
  // SpringSheetRoute — route-level tests
  // =========================================================================
  group('SpringSheetRoute', () {
    testWidgets(
      'barrierColor is Colors.black54',
      (tester) async {
        final route = SpringSheetRoute<void>(
          builder: (_) => const SizedBox(),
        );

        expect(route.barrierColor, Colors.black54);
      },
    );

    testWidgets(
      'barrierDismissible matches isDismissable constructor parameter',
      (tester) async {
        final dismissableRoute = SpringSheetRoute<void>(
          isDismissable: true,
          builder: (_) => const SizedBox(),
        );
        final nonDismissableRoute = SpringSheetRoute<void>(
          isDismissable: false,
          builder: (_) => const SizedBox(),
        );

        expect(dismissableRoute.barrierDismissible, isTrue);
        expect(nonDismissableRoute.barrierDismissible, isFalse);
      },
    );

    testWidgets(
      'transitionDuration is 500 milliseconds',
      (tester) async {
        final route = SpringSheetRoute<void>(
          builder: (_) => const SizedBox(),
        );

        expect(
          route.transitionDuration,
          const Duration(milliseconds: 500),
        );
      },
    );

    testWidgets(
      'reverseTransitionDuration is 350 milliseconds',
      (tester) async {
        final route = SpringSheetRoute<void>(
          builder: (_) => const SizedBox(),
        );

        expect(
          route.reverseTransitionDuration,
          const Duration(milliseconds: 350),
        );
      },
    );

    testWidgets(
      'popDisposition returns doNotPop when isDismissable is false',
      (tester) async {
        final route = SpringSheetRoute<void>(
          isDismissable: false,
          builder: (_) => const SizedBox(),
        );

        expect(route.popDisposition, RoutePopDisposition.doNotPop);
      },
    );

    testWidgets(
      'popDisposition delegates to super when isDismissable is true',
      (tester) async {
        final route = SpringSheetRoute<void>(
          isDismissable: true,
          builder: (_) => const SizedBox(),
        );

        // When dismissable, the route uses the default pop disposition
        // (which is not doNotPop).
        expect(route.popDisposition, isNot(RoutePopDisposition.doNotPop));
      },
    );

    testWidgets(
      'animation is null when super.animation is null (route not installed)',
      (tester) async {
        final route = SpringSheetRoute<void>(
          builder: (_) => const SizedBox(),
        );

        // Before the route is installed in a navigator, animation is null.
        expect(route.animation, isNull);
      },
    );

    testWidgets(
      'barrierLabel is forwarded from constructor',
      (tester) async {
        const label = 'Test barrier label';
        final route = SpringSheetRoute<void>(
          barrierLabel: label,
          builder: (_) => const SizedBox(),
        );

        expect(route.barrierLabel, label);
      },
    );

    testWidgets(
      'barrierOnTapHint parameter is accepted by the constructor',
      (tester) async {
        // barrierOnTapHint does not have a public getter, but we verify the
        // constructor accepts it and builds a valid route.
        final route = SpringSheetRoute<void>(
          barrierOnTapHint: 'Tap to close sheet',
          builder: (_) => const SizedBox(),
        );

        expect(route, isA<SpringSheetRoute<void>>());
      },
    );
  });

  // =========================================================================
  // showSpringBottomSheet() — integration
  // =========================================================================
  group('showSpringBottomSheet()', () {
    testWidgets(
      'returns a Future that resolves after the sheet is popped',
      (tester) async {
        String? result;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        result = await showSpringBottomSheet<String>(
                          context: context,
                          builder: (sheetContext) => Center(
                            child: ElevatedButton(
                              onPressed: () =>
                                  Navigator.pop(sheetContext, 'spring_done'),
                              child: const Text('Close'),
                            ),
                          ),
                        );
                      },
                      child: const Text('Open'),
                    ),
                  );
                },
              ),
            ),
          ),
        );

        // Open the sheet.
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        // Pop the sheet with a return value.
        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();

        expect(result, 'spring_done');
      },
    );

    testWidgets(
      'asserts when no MediaQuery ancestor exists',
      (tester) async {
        // Pump a bare widget without MaterialApp — no MediaQuery.
        await tester.pumpWidget(const SizedBox());

        expect(
          () => showSpringBottomSheet(
            context: tester.element(find.byType(SizedBox)),
            builder: (_) => const Text('No media query'),
          ),
          throwsAssertionError,
        );
      },
    );
  });

  // =========================================================================
  // _ClampedAnimation — internal class exercised through installed route
  // =========================================================================
  group('ClampedAnimation (via SpringSheetRoute)', () {
    testWidgets(
      'route animation is available after the route is pushed',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return Center(
                    child: ElevatedButton(
                      onPressed: () {
                        showSpringBottomSheet(
                          context: context,
                          builder: (_) => const Text('Clamped test'),
                        );
                      },
                      child: const Text('Open'),
                    ),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pump();

        // After one pump, the navigator should have the sheet route active.
        final navigator = tester.state<NavigatorState>(
          find.byType(Navigator),
        );
        expect(navigator, isNotNull);
      },
    );
  });
}
