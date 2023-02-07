import 'package:flutter/material.dart';

ThemeData buildLightTheme() {
  final ThemeData base = ThemeData.light();
  return base.copyWith(
    colorScheme: _lightColorScheme,
    primaryColor: pink100,
    scaffoldBackgroundColor: backgroundWhite,
    cardColor: backgroundWhite,
    textSelectionTheme: const TextSelectionThemeData(selectionColor: pink100),
    buttonTheme: const ButtonThemeData(
      colorScheme: _lightColorScheme,
    ),
    primaryIconTheme: _buildIconTheme(base.iconTheme),
    textTheme: _buildTextTheme(base.textTheme),
    primaryTextTheme: _buildTextTheme(base.primaryTextTheme),
    iconTheme: _buildIconTheme(base.iconTheme),
  );
}

ThemeData buildDarkTheme() {
  final ThemeData base = ThemeData.light();
  return base.copyWith(
    colorScheme: _dartColorScheme,
    primaryColor: pink100,
    scaffoldBackgroundColor: backgroundWhite,
    cardColor: backgroundWhite,
    textSelectionTheme: const TextSelectionThemeData(selectionColor: pink100),
    buttonTheme: const ButtonThemeData(
      colorScheme: _dartColorScheme,
    ),
    primaryIconTheme: _buildIconTheme(base.iconTheme),
    textTheme: _buildTextTheme(base.textTheme),
    primaryTextTheme: _buildTextTheme(base.primaryTextTheme),
    iconTheme: _buildIconTheme(base.iconTheme),
  );
}

const ColorScheme _lightColorScheme = ColorScheme(
  primary: pink100,
  primaryContainer: brown900,
  secondary: pink50,
  secondaryContainer: brown900,
  surface: surfaceWhite,
  background: backgroundWhite,
  error: errorRed,
  onPrimary: brown900,
  onSecondary: brown900,
  onSurface: brown900,
  onBackground: brown900,
  onError: surfaceWhite,
  brightness: Brightness.light,
);

const ColorScheme _dartColorScheme = ColorScheme(
  primary: Colors.yellow,
  primaryContainer: Colors.red,
  secondary: Colors.redAccent,
  secondaryContainer: Colors.lime,
  surface: Colors.white24,
  background: Colors.white30,
  error: Colors.deepOrange,
  onPrimary: Colors.pinkAccent,
  onSecondary: Colors.lime,
  onSurface: Colors.blueGrey,
  onBackground: Colors.grey,
  onError: Colors.red,
  brightness: Brightness.dark,
);

TextTheme _buildTextTheme(TextTheme base) {
  return base
      .copyWith(
        bodySmall: base.bodySmall?.copyWith(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          letterSpacing: defaultLetterSpacing,
        ),
        labelLarge: base.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          letterSpacing: defaultLetterSpacing,
        ),
      )
      .apply(
        fontFamily: 'Rubik',
        displayColor: brown900,
        bodyColor: brown900,
      );
}

IconThemeData _buildIconTheme(IconThemeData original) {
  return original.copyWith(color: brown900);
}

const Color pink50 = Color(0xFFFEEAE6);
const Color pink100 = Color(0xFFFEDBD0);
const Color pink300 = Color(0xFFFBB8AC);
const Color pink400 = Color(0xFFEAA4A4);

const Color brown900 = Color(0xFF442B2D);
const Color brown600 = Color(0xFF7D4F52);

const Color errorRed = Color(0xFFC5032B);

const Color surfaceWhite = Color(0xFFFFFBFA);
const Color backgroundWhite = Colors.white;

const double defaultLetterSpacing = 0.03;
