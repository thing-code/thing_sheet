# thing_sheet

A Flutter modal bottom sheet driven by spring physics (not a static curve/tween), with a ready-made Material Expressive visual style included. Built on top of the [`motor`](https://pub.dev/packages/motor) package for its spring simulation.

## Features

- **Spring-based animation** – the sheet enters with an *expressive spatial spring* and exits with a *fast standard spring*, instead of a static `Curves` value.
- **Drag merges with the animation** – when the sheet is dragged and released, the drag velocity is carried directly into the open/close spring simulation, so it feels like a natural fling similar to modern iOS/Android sheets.
- **Overdrag resistance** – dragging the sheet past its fully-open position feels resisted, then settles back smoothly.
- **Automatic dismiss threshold** – the sheet closes automatically if the drag velocity or final resting position crosses a certain threshold.
- **`isDismissable`** – control whether the sheet can be closed via drag, scrim tap, or the back button (Android).
- **Keyboard-safe** – automatically pushed up when the keyboard appears.
- **Accessibility** – route labels and semantics hints for screen readers are handled automatically (following the same conventions as Flutter's built-in `showModalBottomSheet`).
- **`ThingExpressiveSheet`** – a ready-to-use wrapper widget with a rounded card, an optional drag indicator (grabber), and Material 3 Expressive-style max width/height constraints.

## Getting started

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  thing_sheet: ^0.0.1
```

Then run:

```sh
flutter pub get
```

## Usage

### A plain sheet with spring animation

```dart
import 'package:thing_sheet/thing_sheet.dart';

final result = await showSpringBottomSheet<String>(
  context: context,
  builder: (context) => YourSheetContent(),
);
```

### A sheet with the Material Expressive style (card, drag indicator)

```dart
final result = await ThingExpressiveSheet.show<String>(
  context,
  showIndicator: true,
  isDismissable: true,
  builder: (context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Sheet title'),
        // other content
      ],
    );
  },
);
```

### A sheet that can't be dismissed casually

Use `isDismissable: false` to prevent the sheet from closing via drag, scrim tap, or the back button — useful for flows that require the user to press a specific confirmation button.

```dart
await showSpringBottomSheet(
  context: context,
  isDismissable: false,
  builder: (context) => ConfirmationContent(),
);
```

A more complete example is available in the `/example` folder.

## Additional information

- This package depends on [`motor`](https://pub.dev/packages/motor) for its spring curves/simulations (`MaterialSpringMotion`).
- Contributions, bug reports, and feature requests can be submitted through this package's repository/issue tracker.
- License: see the `LICENSE` file.