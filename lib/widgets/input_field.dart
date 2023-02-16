import 'package:flutter/material.dart';
import 'package:pma/constants/enum.dart';
import 'package:pma/extentions/extensions.dart';

class InputField extends StatelessWidget {
  const InputField({
    super.key,
    this.inputFieldHeight = InputFieldHeight.small,
    this.onChanged,
    required this.controller,
    this.isObscure = false,
    this.isEnabled = true,
    this.borderRadius = const BorderRadius.all(Radius.circular(4)),
    required this.hintText,
    this.descriptionText,
    this.textInputType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.focusNode,
    this.scrollPadding = const EdgeInsets.all(20),
    this.onFieldSubmitted,
    this.suffixIcon,
    this.borderType = InputFieldBorderType.outlineInputBorder,
    this.maxLength,
    this.suffixIconSize = 16,
  });

  final InputFieldHeight inputFieldHeight;
  final ValueChanged<String>? onChanged;
  final TextEditingController controller;
  final bool isObscure;
  final bool isEnabled;
  final BorderRadius borderRadius;
  final String hintText;
  final String? descriptionText;
  final TextInputType textInputType;
  final TextCapitalization textCapitalization;
  final FormFieldValidator<String>? validator;
  final FocusNode? focusNode;
  final EdgeInsets scrollPadding;
  final Function(String)? onFieldSubmitted;
  final Widget? suffixIcon;
  final InputFieldBorderType borderType;
  final int? maxLength;
  final double suffixIconSize;

  @override
  Widget build(BuildContext context) {
    final ThemeData currentTheme = Theme.of(context);
    return TextFormField(
      onChanged: onChanged,
      controller: controller,
      obscureText: isObscure,
      obscuringCharacter: '*',
      enabled: isEnabled,
      focusNode: focusNode,
      scrollPadding: scrollPadding,
      decoration: _inputDecoration(context, currentTheme),
      style: currentTheme.textTheme.bodyMedium?.copyWith(
        color: currentTheme.colorScheme.primary,
      ),
      keyboardType: textInputType,
      textCapitalization: textCapitalization,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      maxLength: maxLength,
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context,
    ThemeData currentTheme,
  ) {
    return InputDecoration(
      fillColor: currentTheme.colorScheme.background,
      filled: true,
      enabledBorder: _getBorder(
        color: currentTheme.colorScheme.primary,
        currentTheme: currentTheme,
      ),
      suffixIcon: _buildSuffixIcon(),
      suffixIconConstraints: BoxConstraints(
        minHeight: suffixIconSize + 16,
        minWidth: suffixIconSize + 16,
      ),
      focusedErrorBorder: _getBorder(currentTheme: currentTheme),
      focusedBorder: _getBorder(currentTheme: currentTheme),
      errorBorder: _getBorder(currentTheme: currentTheme),
      disabledBorder: _getBorder(
        color: currentTheme.colorScheme.primary,
        currentTheme: currentTheme,
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: inputFieldHeight.verticalPadding,
      ),
      hintText: hintText,
      hintStyle: _labelStyle(context, currentTheme),
      helperText: descriptionText,
      helperStyle: _helperStyle(currentTheme),
      errorStyle: _errorStyle(currentTheme),
      errorMaxLines: 2,
      counterStyle: currentTheme.textTheme.bodyMedium,
    );
  }

  Widget? _buildSuffixIcon() {
    final Widget? icon = suffixIcon;
    if (icon == null) {
      return null;
    }
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: icon,
    );
  }

  InputBorder _getBorder({
    Color? color,
    required ThemeData currentTheme,
  }) {
    if (borderType == InputFieldBorderType.outlineInputBorder) {
      return OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(
          color: _borderColor(currentTheme, color),
        ),
      );
    } else {
      return UnderlineInputBorder(
        borderSide: BorderSide(
          color: _borderColor(currentTheme, color),
        ),
      );
    }
  }

  Color _borderColor(ThemeData currentTheme, Color? color) {
    if (currentTheme.brightness == Brightness.dark) {
      return currentTheme.colorScheme.background;
    }
    return color ?? currentTheme.colorScheme.primary;
  }

  TextStyle _labelStyle(BuildContext context, ThemeData currentTheme) {
    return currentTheme.textTheme.bodyMedium!.copyWith(
      color: currentTheme.colorScheme.primary,
    );
  }

  TextStyle _helperStyle(ThemeData currentTheme) {
    return currentTheme.textTheme.bodySmall!.copyWith(
      color: currentTheme.colorScheme.primary,
    );
  }

  TextStyle _errorStyle(ThemeData currentTheme) {
    return currentTheme.textTheme.bodySmall!.copyWith(
      color: currentTheme.colorScheme.error,
    );
  }
}
