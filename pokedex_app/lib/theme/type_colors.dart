import 'package:flutter/material.dart';

const Map<String, Color> _typeColors = {
  'normal': Color(0xFF9099A1),
  'fighting': Color(0xFFCE416B),
  'flying': Color(0xFF89AAE3),
  'poison': Color(0xFFB567CE),
  'ground': Color(0xFFD97746),
  'rock': Color(0xFFC5B78C),
  'bug': Color(0xFF91C12F),
  'ghost': Color(0xFF5269AD),
  'steel': Color(0xFF5A8EA2),
  'fire': Color(0xFFFF9D55),
  'water': Color(0xFF5090D6),
  'grass': Color(0xFF63BB5B),
  'electric': Color(0xFFF4D23C),
  'psychic': Color(0xFFFA7179),
  'ice': Color(0xFF73CEC0),
  'dragon': Color(0xFF0B6DC3),
  'dark': Color(0xFF5A5465),
  'fairy': Color(0xFFEC8FE6),
  'stellar': Color(0xFF7CC7B2),
  'unknown': Color(0xFF68A090),
};

Color typeColor(String? name) =>
    _typeColors[(name ?? '').trim().toLowerCase()] ?? const Color(0xFF9099A1);

/// Readable text/icon color on top of [typeColor].
Color onTypeColor(Color c) =>
    ThemeData.estimateBrightnessForColor(c) == Brightness.dark
        ? Colors.white
        : const Color(0xFF1B1B1B);

String capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

/// Splits the comma-joined `types` string returned by the database queries.
List<String> splitTypes(Object? types) => (types?.toString() ?? '')
    .split(',')
    .map((t) => t.trim())
    .where((t) => t.isNotEmpty)
    .toList();
