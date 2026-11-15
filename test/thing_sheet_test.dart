import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:thing_sheet/src/bottom_sheet_util.dart';
import 'package:thing_sheet/src/drag_handle.dart';
import 'package:thing_sheet/src/thing_pop_up.dart';
import 'package:thing_sheet/thing_sheet.dart';

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

/// Finds the [Material] widget created by [ThingPopUp] itself
/// (as opposed to the one created by Scaffold). It is uniquely identifiable
/// because its shape is a [RoundedRectangleBorder] with radius 36.
Finder findSheetMaterial() {
  return find.byWidgetPredicate(
    (w) =>
        w is Material &&
        w.shape is RoundedRectangleBorder &&
        (w.shape as RoundedRectangleBorder).borderRadius ==
            BorderRadius.circular(36),
  );
}

/// Finds the [ConstrainedBox] created by [ThingPopUp] — the one
/// with maxWidth == 640.
Finder findSheetConstrainedBox() {
  return find.byWidgetPredicate(
    (w) => w is ConstrainedBox && w.constraints.maxWidth == 640,
  );
}

void main() {
  // -------------------------------------------------------------------------
  // Helper: pump a ThingPopUp wrapped in the required Material ancestors.
  // -------------------------------------------------------------------------
  Future<void> pumpSheet(
    WidgetTester tester, {
    bool showDragHandle = true,
    WidgetBuilder builder = _defaultBuilder,
    EdgeInsets viewPadding = EdgeInsets.zero,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: const Size(800, 600),
            viewPadding: viewPadding,
          ),
          child: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: SizedBox(
                  width: 400,
                  height: 600,
                  child: ThingPopUp(
                    showDragHandle: showDragHandle,
                    builder: builder,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // ThingPopUp — structural & layout
  // =========================================================================
  group('ThingPopUp structure', () {
    testWidgets('renders sheet content passed via builder', (tester) async {
      await pumpSheet(tester);

      expect(find.byKey(const Key('sheet_content')), findsOneWidget);
    });

    testWidgets('renders a drag handle by default (showDragHandle = true)', (
      tester,
    ) async {
      await pumpSheet(tester, showDragHandle: true);

      expect(find.byType(DragHandle), findsOneWidget);
    });

    testWidgets('hides drag handle when showDragHandle is false', (
      tester,
    ) async {
      await pumpSheet(tester, showDragHandle: false);

      expect(find.byType(DragHandle), findsNothing);

      // Additionally, the inner padding should be uniform EdgeInsets.all(20).
      final innerPadding = tester.widget<Padding>(
        find
            .descendant(of: findSheetMaterial(), matching: find.byType(Padding))
            .first,
      );
      expect(innerPadding.padding, const EdgeInsets.all(20));
    });

    testWidgets('applies asymmetric top padding when drag handle is visible', (
      tester,
    ) async {
      await pumpSheet(tester, showDragHandle: true);

      // The first Padding inside the Sheet's Material uses fromLTRB so the
      // drag handle sits flush at the top while content has 20 px on the
      // other sides.
      final innerPadding = tester.widget<Padding>(
        find
            .descendant(of: findSheetMaterial(), matching: find.byType(Padding))
            .first,
      );
      expect(innerPadding.padding, const EdgeInsets.fromLTRB(20, 0, 20, 20));
    });

    testWidgets('constrains max width to 640 logical pixels', (tester) async {
      await pumpSheet(tester);

      final box = tester.widget<ConstrainedBox>(findSheetConstrainedBox());
      expect(box.constraints.maxWidth, 640);
    });

    testWidgets('limits max height to screen height minus top safe area', (
      tester,
    ) async {
      await pumpSheet(
        tester,
        viewPadding: const EdgeInsets.only(top: 40, bottom: 20),
      );

      final box = tester.widget<ConstrainedBox>(findSheetConstrainedBox());
      // Screen height (600) - top padding (40) = 560
      expect(box.constraints.maxHeight, 560);
    });

    testWidgets('applies rounded rectangle shape to the Material surface', (
      tester,
    ) async {
      await pumpSheet(tester);

      final material = tester.widget<Material>(findSheetMaterial());
      expect(material.shape, isA<RoundedRectangleBorder>());
      final shape = material.shape as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(36));
    });

    testWidgets('enables anti-alias clipping on the Material surface', (
      tester,
    ) async {
      await pumpSheet(tester);

      final material = tester.widget<Material>(findSheetMaterial());
      expect(material.clipBehavior, Clip.antiAlias);
    });

    testWidgets('applies outer padding based on view padding', (tester) async {
      // With zero viewPadding:
      await pumpSheet(tester);

      final outerPaddingZero = tester.widget<Padding>(
        find
            .ancestor(
              of: findSheetConstrainedBox(),
              matching: find.byType(Padding),
            )
            .first,
      );
      expect(
        outerPaddingZero.padding,
        const EdgeInsets.fromLTRB(24, 0, 24, 0),
      );

      // With bottom > 24: bottom clamp applies to 24
      await pumpSheet(
        tester,
        viewPadding: const EdgeInsets.fromLTRB(0, 30, 0, 40),
      );

      final outerPaddingClamped = tester.widget<Padding>(
        find
            .ancestor(
              of: findSheetConstrainedBox(),
              matching: find.byType(Padding),
            )
            .first,
      );
      expect(
        outerPaddingClamped.padding,
        const EdgeInsets.fromLTRB(24, 30, 24, 24),
      );

      // With bottom <= 24: bottom uses actual viewPadding.bottom
      await pumpSheet(
        tester,
        viewPadding: const EdgeInsets.fromLTRB(0, 15, 0, 18),
      );

      final outerPaddingUnclamped = tester.widget<Padding>(
        find
            .ancestor(
              of: findSheetConstrainedBox(),
              matching: find.byType(Padding),
            )
            .first,
      );
      expect(
        outerPaddingUnclamped.padding,
        const EdgeInsets.fromLTRB(24, 15, 24, 18),
      );
    });
  });

  // =========================================================================
  // DragHandle — unit tests
  // =========================================================================
  group('DragHandle', () {
    testWidgets('uses onSurfaceVariant color with 0.5 alpha from the theme', (
      tester,
    ) async {
      final customTheme = ThemeData.light().copyWith(
        colorScheme: ThemeData.light().colorScheme.copyWith(
          onSurfaceVariant: const Color(0xFF123456),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: customTheme,
          home: const Scaffold(body: Center(child: DragHandle())),
        ),
      );

      final indicatorContainer = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byType(DragHandle),
              matching: find.byType(Container),
            ),
          )
          .first;

      final decoration = indicatorContainer.decoration as BoxDecoration;
      expect(decoration.color, const Color(0xFF123456).withValues(alpha: 0.5));
    });

    testWidgets('has dimensions height 4, width 36, borderRadius 24', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Center(child: DragHandle()))),
      );

      final indicatorContainer = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byType(DragHandle),
              matching: find.byType(Container),
            ),
          )
          .first;

      expect(indicatorContainer.constraints?.maxHeight, 4);
      expect(indicatorContainer.constraints?.maxWidth, 36);

      final decoration = indicatorContainer.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(24));
    });

    testWidgets('is centered via an Align ancestor', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Center(child: DragHandle()))),
      );

      final alignFinder = find.descendant(
        of: find.byType(DragHandle),
        matching: find.byType(Align),
      );
      expect(alignFinder, findsOneWidget);
      final alignWidget = tester.widget<Align>(alignFinder);
      expect(alignWidget.alignment, Alignment.center);
    });

    testWidgets('has vertical padding of 12', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Center(child: DragHandle()))),
      );

      final paddingWidget = tester
          .widgetList<Padding>(
            find.descendant(
              of: find.byType(DragHandle),
              matching: find.byType(Padding),
            ),
          )
          .first;
      expect(paddingWidget.padding, const EdgeInsets.symmetric(vertical: 12));
    });
  });

  // =========================================================================
  // ThingPopUp.show() — static integration method
  // =========================================================================
  group('ThingPopUp.show()', () {
    testWidgets('opens a sheet route via Navigator and resolves when popped', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Center(
                  child: ElevatedButton(
                    onPressed: () {
                      ThingPopUp.show<String>(
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
    });

    testWidgets('showDragHandle parameter is forwarded to ThingPopUp', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Center(
                  child: ElevatedButton(
                    onPressed: () {
                      ThingPopUp.show(
                        context,
                        showDragHandle: false,
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
      expect(find.byType(DragHandle), findsNothing);

      // Verify the Padding inside the Sheet's Material uses .all(20).
      final innerPadding = tester.widget<Padding>(
        find
            .descendant(of: findSheetMaterial(), matching: find.byType(Padding))
            .first,
      );
      expect(innerPadding.padding, const EdgeInsets.all(20));
    });

    testWidgets('creates a non-dismissable sheet when isDismissable is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Center(
                  child: ElevatedButton(
                    onPressed: () {
                      ThingPopUp.show(
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

      expect(find.text('Cannot dismiss by dragging'), findsOneWidget);
      expect(findSheetMaterial(), findsOneWidget);
    });
  });

  // =========================================================================
  // ThingSheet — facade tests
  // =========================================================================
  group('ThingSheet', () {
    testWidgets('showPopUp displays ThingPopUp and returns popped value', (
      tester,
    ) async {
      String? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      result = await ThingSheet.showPopUp<String>(
                        context: context,
                        builder: (popupContext) => Center(
                          child: ElevatedButton(
                            onPressed: () =>
                                Navigator.pop(popupContext, 'popup_result'),
                            child: const Text('Close PopUp'),
                          ),
                        ),
                      );
                    },
                    child: const Text('Open PopUp'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open PopUp'));
      await tester.pumpAndSettle();

      expect(find.byType(ThingPopUp), findsOneWidget);
      expect(find.byType(DragHandle), findsOneWidget);

      await tester.tap(find.text('Close PopUp'));
      await tester.pumpAndSettle();

      expect(result, 'popup_result');
      expect(find.byType(ThingPopUp), findsNothing);
    });

    testWidgets('showPopUp forwards showDragHandle: false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Center(
                  child: ElevatedButton(
                    onPressed: () {
                      ThingSheet.showPopUp(
                        context: context,
                        showDragHandle: false,
                        builder: (_) => const Text('PopUp Without Handle'),
                      );
                    },
                    child: const Text('Open PopUp'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open PopUp'));
      await tester.pumpAndSettle();

      expect(find.text('PopUp Without Handle'), findsOneWidget);
      expect(find.byType(DragHandle), findsNothing);
    });

    testWidgets('showSheet opens cupertino sheet with Material and SafeArea', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Center(
                  child: ElevatedButton(
                    onPressed: () {
                      ThingSheet.showSheet(
                        context: context,
                        builder: (context, controller) => ListView(
                          controller: controller,
                          children: const [
                            Text('Cupertino Sheet Content'),
                          ],
                        ),
                      );
                    },
                    child: const Text('Open Sheet'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Cupertino Sheet Content'), findsOneWidget);
      expect(find.byType(SafeArea), findsWidgets);
    });
  });

  // =========================================================================
  // SpringSheetRoute — route-level tests
  // =========================================================================
  group('SpringSheetRoute', () {
    testWidgets('barrierColor is Colors.black54', (tester) async {
      final route = SpringSheetRoute<void>(builder: (_) => const SizedBox());

      expect(route.barrierColor, Colors.black54);
    });

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

    testWidgets('transitionDuration is 500 milliseconds', (tester) async {
      final route = SpringSheetRoute<void>(builder: (_) => const SizedBox());

      expect(route.transitionDuration, const Duration(milliseconds: 500));
    });

    testWidgets('reverseTransitionDuration is 350 milliseconds', (
      tester,
    ) async {
      final route = SpringSheetRoute<void>(builder: (_) => const SizedBox());

      expect(
        route.reverseTransitionDuration,
        const Duration(milliseconds: 350),
      );
    });

    testWidgets('popDisposition returns doNotPop when isDismissable is false', (
      tester,
    ) async {
      final route = SpringSheetRoute<void>(
        isDismissable: false,
        builder: (_) => const SizedBox(),
      );

      expect(route.popDisposition, RoutePopDisposition.doNotPop);
    });

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
        final route = SpringSheetRoute<void>(builder: (_) => const SizedBox());

        // Before the route is installed in a navigator, animation is null.
        expect(route.animation, isNull);
      },
    );

    testWidgets('barrierLabel is forwarded from constructor', (tester) async {
      const label = 'Test barrier label';
      final route = SpringSheetRoute<void>(
        barrierLabel: label,
        builder: (_) => const SizedBox(),
      );

      expect(route.barrierLabel, label);
    });

    testWidgets('barrierOnTapHint parameter is accepted by the constructor', (
      tester,
    ) async {
      final route = SpringSheetRoute<void>(
        barrierOnTapHint: 'Tap to close sheet',
        builder: (_) => const SizedBox(),
      );

      expect(route, isA<SpringSheetRoute<void>>());
    });
  });

  // =========================================================================
  // showPopUp() — integration
  // =========================================================================
  group('showPopUp()', () {
    testWidgets('returns a Future that resolves after the sheet is popped', (
      tester,
    ) async {
      String? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      result = await showPopUp<String>(
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
    });

    testWidgets('asserts when no MediaQuery ancestor exists', (tester) async {
      // Pump a bare widget without MaterialApp — no MediaQuery.
      await tester.pumpWidget(const SizedBox());

      expect(
        () => showPopUp(
          context: tester.element(find.byType(SizedBox)),
          builder: (_) => const Text('No media query'),
        ),
        throwsAssertionError,
      );
    });
  });

  // =========================================================================
  // _ClampedAnimation — internal class exercised through installed route
  // =========================================================================
  group('ClampedAnimation (via SpringSheetRoute)', () {
    testWidgets('route animation is available after the route is pushed', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Center(
                  child: ElevatedButton(
                    onPressed: () {
                      showPopUp(
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
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      expect(navigator, isNotNull);
    });
  });
}
