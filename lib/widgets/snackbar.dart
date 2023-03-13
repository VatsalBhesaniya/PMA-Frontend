import 'package:flutter/material.dart';

void showSnackBar({
  required BuildContext context,
  required ThemeData theme,
  required String message,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      margin: const EdgeInsets.all(16),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      backgroundColor: theme.colorScheme.surface,
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.background,
        ),
      ),
      showCloseIcon: true,
      closeIconColor: theme.colorScheme.background,
    ),
  );
}
