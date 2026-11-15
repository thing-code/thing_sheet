# thing_sheet

A Flutter package for polished pop-up dialogs and bottom sheets with expressive spring-driven motion and flexible layout behavior.

## Overview

`thing_sheet` provides a lightweight API for showing modal surfaces that feel natural and responsive on mobile. It includes both:

- `ThingSheet.showPopUp(...)` for popup-style dialogs
- `ThingSheet.showSheet(...)` for bottom-sheet content with scroll support

The package is designed for modern Flutter apps and keeps interactions smooth by using spring-based motion instead of a static curve.

## Features

- Spring-driven motion for entry and dismissal
- Drag-to-dismiss behavior that carries velocity into the animation
- Overdrag resistance for a more natural sheet feel
- Automatic closing thresholds based on drag motion and position
- Optional drag handle and dismissal controls
- Scrollable sheet content support
- Safe-area and keyboard-aware behavior
- Easy integration with standard Flutter navigation APIs

## Installation

Add the package to your project:

```yaml
dependencies:
  thing_sheet: ^1.0.0
```

Then install dependencies:

```bash
flutter pub get
```

## Usage

### Import the package

```dart
import 'package:thing_sheet/thing_sheet.dart';
```

### Show a popup

```dart
final result = await ThingSheet.showPopUp<String>(
  context: context,
  builder: (context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Example popup'),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => Navigator.of(context).pop('done'),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  },
);
```

### Show a bottom sheet

```dart
await ThingSheet.showSheet(
  context: context,
  showDragHandle: true,
  builder: (context, scrollController) {
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => ListTile(
              title: Text('Item $index'),
            ),
            childCount: 20,
          ),
        ),
      ],
    );
  },
);
```

### Prevent casual dismissal

Use `isDismissable: false` when the sheet must stay open until the user confirms an action.

```dart
await ThingSheet.showPopUp(
  context: context,
  isDismissable: false,
  builder: (context) => const Text('Please confirm to continue'),
);
```

## API

### `ThingSheet.showPopUp`

Shows a popup-style modal surface.

Parameters:

- `required BuildContext context`
- `required WidgetBuilder builder`
- `bool showDragHandle = true`
- `bool isDismissable = true`
- `bool useRootNavigator = true`

### `ThingSheet.showSheet`

Shows a bottom sheet with a scrollable body.

Parameters:

- `required BuildContext context`
- `required ScrollableWidgetBuilder builder`
- `bool showDragHandle = false`
- `bool useNestedNavigation = false`
- `bool enableDrag = true`
- `double? topGap`

## Example app

A complete usage example is available in the `/example` directory.

## License

This project is licensed under the MIT license. See the `LICENSE` file for details.