import 'package:flutter/material.dart';

class FloatingButtonExtended extends StatelessWidget {
  const FloatingButtonExtended({
    super.key,
    this.onPressed,
    this.backgroundColor,
    required this.labelText,
    this.labelStyle,
  });

  final Function()? onPressed;
  final Color? backgroundColor;
  final String labelText;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return FloatingActionButton.extended(
      onPressed: onPressed,
      elevation: 8,
      backgroundColor: backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(8),
        ),
      ),
      label: Text(
        labelText,
        style: labelStyle ??
            theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.background,
            ),
      ),
    );
  }
}
