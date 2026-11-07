## 1.0.0-dev.0
**BREAKING CHANGES**
* Update Dart SDK version to `3.13.7` with Flutter `3.47.8`
* Decouple flutter ui to `material_ui` and `cupertino_ui` packages.
* Rename `ThingExpressiveSheet` to `ThingSheet`.
* Separate `ThingSheet` method for pop up and bottom sheet.

## 0.2.0
* Expose new `margin` parameter to setting horizontal margin from the BottomSheet

## 0.1.2
* Add `useRootNavigator` parameter to `.show` method

## 0.1.1
* Adjust ThingExpressiveSheet padding

## 0.1.0
BREAKING CHANGES
* Update Dart SDK version to `3.13.4` with Flutter `3.47`

## 0.0.1

Initial release.

- `showSpringBottomSheet` — shows a modal sheet anchored to the bottom of the screen with a spring-driven animation (enter: expressive spatial spring, exit: fast standard spring) using the `motor` package.
- `SpringSheetRoute` — a custom `PopupRoute` implementation that supports:
  - interactive dragging that drives the route animation directly,
  - fling velocity from a released drag carried into the open/close simulation,
  - overdrag resistance when the sheet is dragged past its fully-open position,
  - automatic close threshold based on drag velocity or final resting position,
  - an `isDismissable` option to disable closing via drag, scrim tap, and the back button,
  - keyboard-safe padding and accessibility/semantics labels.
- `ThingExpressiveSheet` — a ready-to-use wrapper widget with a Material Expressive style: a rounded card, an optional drag indicator (grabber), and maximum size constraints.