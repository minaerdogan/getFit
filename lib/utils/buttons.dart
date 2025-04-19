import 'package:flutter/material.dart';

//bu buttonlari uygulama acilmadan onceki register veya welcome sayfalarinda
//falan kullanabiliriz goruntu birligi olsun diye

class ButtonDimensions {
  // Standard button height
  static const double height = 48.0;

  // Button corner radius
  static const double borderRadius = 12.0;

  // Button internal padding
  static const EdgeInsets padding = EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0);

  // Full width margin for spacing between screen edges
  static const EdgeInsets pageMargin = EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0);

  // Distance from bottom for fixed-positioned buttons
  static const double bottomSpacing = 32.0;

  // Minimum width if not using full width
  static const double minWidth = 200.0;

  // Optional: default style radius (used in containers if you wrap buttons)
  static const BorderRadiusGeometry borderRadiusGeometry = BorderRadius.all(Radius.circular(borderRadius));
}



