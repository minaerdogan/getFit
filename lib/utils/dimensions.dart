import 'package:flutter/material.dart';

class Dimensions {
  // Base spacing units
  static const double small = 4.0;
  static const double regular = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
  static const double extraLarge = 32.0;

  // Padding
  static const EdgeInsets smallPadding = EdgeInsets.all(small);
  static const EdgeInsets regularPadding = EdgeInsets.all(regular);
  static const EdgeInsets mediumPadding = EdgeInsets.all(medium);
  static const EdgeInsets largePadding = EdgeInsets.all(large);
  static const EdgeInsets extraLargePadding = EdgeInsets.all(extraLarge);

  // Margin
  static const EdgeInsets smallMargin = EdgeInsets.all(small);
  static const EdgeInsets regularMargin = EdgeInsets.all(regular);
  static const EdgeInsets mediumMargin = EdgeInsets.all(medium);
  static const EdgeInsets largeMargin = EdgeInsets.all(large);
  static const EdgeInsets extraLargeMargin = EdgeInsets.all(extraLarge);

  // Horizontal and Vertical spacing (Rows ve Columnlarda kullanilabilir)
  static const SizedBox verticalSpaceSmall = SizedBox(height: small);
  static const SizedBox verticalSpaceRegular = SizedBox(height: regular);
  static const SizedBox verticalSpaceMedium = SizedBox(height: medium);
  static const SizedBox verticalSpaceLarge = SizedBox(height: large);

  static const SizedBox horizontalSpaceSmall = SizedBox(width: small);
  static const SizedBox horizontalSpaceRegular = SizedBox(width: regular);
  static const SizedBox horizontalSpaceMedium = SizedBox(width: medium);
  static const SizedBox horizontalSpaceLarge = SizedBox(width: large);
}