import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildLightTheme() {
  final ThemeData base = ThemeData.light();
  return base.copyWith(
    colorScheme: _lightColorScheme,
    primaryColor: oldRose,
    scaffoldBackgroundColor: seashell,
    cardColor: paleDogwood,
    textSelectionTheme: const TextSelectionThemeData(selectionColor: mistyRose),
    buttonTheme: const ButtonThemeData(
      colorScheme: _lightColorScheme,
    ),
    textTheme: _buildTextTheme(base.textTheme),
    primaryTextTheme: _buildTextTheme(base.primaryTextTheme),
    iconTheme: base.iconTheme.copyWith(color: oldRose),
    primaryIconTheme: base.iconTheme.copyWith(color: oldRose),
  );
}

ThemeData buildDarkTheme() {
  final ThemeData base = ThemeData.light();
  return base.copyWith(
    colorScheme: _darkColorScheme,
    primaryColor: raisinBlack,
    scaffoldBackgroundColor: timberwolf,
    cardColor: peachYellow,
    textSelectionTheme: const TextSelectionThemeData(selectionColor: dimGray),
    buttonTheme: const ButtonThemeData(
      colorScheme: _darkColorScheme,
    ),
    textTheme: _buildTextTheme(base.textTheme),
    primaryTextTheme: _buildTextTheme(base.primaryTextTheme),
    iconTheme: base.iconTheme.copyWith(color: raisinBlack),
    primaryIconTheme: base.iconTheme.copyWith(color: raisinBlack),
  );
}

const ColorScheme _lightColorScheme = ColorScheme(
  primary: oldRose,
  onPrimary: surfaceWhite,
  primaryContainer: mistyRose,
  secondary: paleDogwood,
  onSecondary: surfaceWhite,
  secondaryContainer: paleDogwood,
  surface: platinum,
  onSurface: platinum,
  background: seashell,
  onBackground: seashell,
  error: errorRedLight,
  onError: errorRedLight,
  outline: Colors.blueGrey,
  brightness: Brightness.light,
);

const ColorScheme _darkColorScheme = ColorScheme(
  primary: raisinBlack,
  onPrimary: raisinBlack,
  primaryContainer: dimGray,
  secondary: peachYellow,
  onSecondary: peachYellow,
  secondaryContainer: peachYellow,
  surface: raisinBlack,
  onSurface: surfaceWhite,
  background: timberwolf,
  onBackground: timberwolf,
  error: errorRedDark,
  onError: errorRedDark,
  outline: Colors.blueGrey,
  brightness: Brightness.dark,
);

TextTheme _buildTextTheme(TextTheme baseTheme) {
  return GoogleFonts.poppinsTextTheme(baseTheme).copyWith(
    bodyLarge: GoogleFonts.poppins(
      textStyle: baseTheme.bodyLarge,
      fontSize: 18,
    ),
  );
}

const Color surfaceWhite = Color(0xFFFFFBFA);
const Color errorRedLight = Color.fromARGB(255, 223, 83, 83);
const Color errorRedDark = Color.fromARGB(255, 160, 59, 59);
const Color timberwolf = Color(0xFFDAD5D4);
const Color paleDogwood = Color(0xFFF3C5B7);
const Color peachYellow = Color.fromARGB(255, 223, 195, 147);
const Color platinum = Color.fromARGB(255, 99, 97, 97);
const Color dimGray = Color(0xFF776B71);
const Color black = Color(0xFF000000);
const Color mistyRose = Color(0xFFF5D7D5);
const Color raisinBlack = Color(0xFF2F303E);
const Color oldRose = Color(0xFFAD7775);
const Color seashell = Color(0xFFFCEEEA);
