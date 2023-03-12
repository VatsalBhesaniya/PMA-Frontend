import 'package:flutter/material.dart';

void pmaAlertDialog({
  required BuildContext context,
  required ThemeData theme,
  required String error,
}) {
  showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Center(
          child: Text(
            'Alert',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ),
        content: Text(
          error,
          style: theme.textTheme.bodyMedium,
        ),
        actions: <Widget>[
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: Text(
                'OK',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
