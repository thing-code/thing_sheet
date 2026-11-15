import 'package:material_ui/material_ui.dart';

class DragHandle extends StatelessWidget {
  const DragHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final Color indicatorColor = Theme.of(context).colorScheme.onSurfaceVariant
        .withValues(alpha: .5);

    return Align(
      alignment: .center,
      child: Padding(
        padding: .symmetric(vertical: 12),
        child: Container(
          height: 4,
          width: 36,
          decoration: BoxDecoration(
            borderRadius: .circular(24),
            color: indicatorColor,
          ),
        ),
      ),
    );
  }
}
