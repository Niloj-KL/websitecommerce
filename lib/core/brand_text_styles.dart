import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle brandRoundedStyle({
  double size = 22,
  FontWeight weight = FontWeight.w700,
  Color color = const Color(0xFF1F1A12),
  double letterSpacing = 0.4,
  double? height,
}) {
  // Rounded premium look similar to requested font references.
  return GoogleFonts.comfortaa(
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
  );
}

TextStyle formalHeadingStyle({
  double size = 24,
  FontWeight weight = FontWeight.w700,
  Color color = const Color(0xFF1F1A12),
  double letterSpacing = 0.2,
}) {
  return GoogleFonts.playfairDisplay(
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: letterSpacing,
  );
}

TextStyle calligraphyAccentStyle({
  double size = 28,
  Color color = const Color(0xFF6A522A),
}) {
  return GoogleFonts.greatVibes(
    fontSize: size,
    color: color,
    fontWeight: FontWeight.w500,
  );
}

TextStyle inlineAccentStyle({
  double size = 14,
  Color color = const Color(0xFF57472D),
  FontWeight weight = FontWeight.w500,
}) {
  return GoogleFonts.poiretOne(
    fontSize: size,
    color: color,
    fontWeight: weight,
    letterSpacing: 0.5,
  );
}
