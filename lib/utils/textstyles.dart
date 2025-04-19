import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextStyles {
  // Header / Title
  static const TextStyle header = TextStyle(
    color: AppColors.textColor,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  // Regular text
  static const TextStyle regular = TextStyle(
    color: AppColors.textColor,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  // Small text
  static const TextStyle small = TextStyle(
    color: AppColors.textColor,
    fontSize: 13,
    fontWeight: FontWeight.w400,
  );

  // Button text
  static const TextStyle button = TextStyle(
    color: Colors.white, // good contrast on colored buttons
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static const TextStyle welcome = TextStyle(
    color: AppColors.textColor,
    fontSize: 24,
    fontWeight: FontWeight.w400, // not bold
  );
   //for homepage smaller font
  static const TextStyle listItem = TextStyle(
    color: AppColors.textColor,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );
}