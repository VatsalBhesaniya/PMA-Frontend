import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  const SearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
    this.hintText,
    this.autofocus = true,
    this.onCancel,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String? hintText;
  final bool autofocus;
  final Function()? onCancel;
  final Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      style: theme.textTheme.bodyMedium,
      autofocus: autofocus,
      decoration: _inputDecoration(
        theme: theme,
        focusNode: focusNode,
        controller: controller,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required ThemeData theme,
    required FocusNode focusNode,
    required TextEditingController controller,
  }) {
    return InputDecoration(
      filled: true,
      focusColor: theme.colorScheme.primary,
      prefixIcon: const Icon(Icons.search_rounded),
      suffixIcon: _suffixIcon(
        controller: controller,
        theme: theme,
      ),
      enabledBorder: _setBorder(
        borderColor: theme.colorScheme.inverseSurface,
      ),
      focusedBorder: _setBorder(
        borderColor: theme.colorScheme.primary,
      ),
      hintText: hintText ?? 'Search here',
      hintStyle: theme.textTheme.bodySmall,
      fillColor: Colors.transparent,
      isDense: true,
      contentPadding: const EdgeInsets.all(1),
    );
  }

  Widget? _suffixIcon({
    required TextEditingController controller,
    required ThemeData theme,
  }) {
    if (controller.text.isNotEmpty) {
      return IconButton(
        onPressed: () {
          controller.clear();
          final Function()? onCancelPress = onCancel;
          if (onCancelPress != null) {
            onCancelPress();
          }
        },
        icon: Icon(
          Icons.close_rounded,
          color: theme.colorScheme.primary,
        ),
      );
    }
    return null;
  }

  OutlineInputBorder _setBorder({
    required Color borderColor,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(
        color: borderColor,
      ),
    );
  }
}
