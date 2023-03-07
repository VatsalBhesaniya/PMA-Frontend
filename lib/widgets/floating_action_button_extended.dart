import 'package:flutter/material.dart';

class FloatingActionButtonExtended extends StatelessWidget {
  const FloatingActionButtonExtended({
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
    return Container(
      margin: const EdgeInsets.all(16),
      child: FloatingActionButton.extended(
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
          style: labelStyle ?? theme.textTheme.titleMedium,
        ),
      ),
    );
  }
}
