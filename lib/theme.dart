import 'package:flutter/material.dart';

const Color kBg = Color(0xFF0A0A0F);
const Color kBg2 = Color(0xFF0F0F1A);
const Color kBg3 = Color(0xFF141420);
const Color kPanel = Color(0xFF12121E);
const Color kBorder = Color(0xFF1E1E35);
const Color kAccentA = Color(0xFF00F0FF);
const Color kAccentB = Color(0xFFFF2D78);
const Color kAccentC = Color(0xFF7B2FFF);
const Color kAccentG = Color(0xFF00FF9D);
const Color kTextDim = Color(0xFF5A5A8A);
const Color kText = Color(0xFFE0E0FF);

final ThemeData nexusTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: kBg,
  colorScheme: const ColorScheme.dark(
    primary: kAccentC,
    secondary: kAccentA,
    surface: kPanel,
  ),
  sliderTheme: const SliderThemeData(
    trackHeight: 4,
    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
    overlayShape: RoundSliderOverlayShape(overlayRadius: 16),
  ),
);