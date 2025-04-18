import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextStyles {
  // Header / Title (e.g., screens, sections)
  static const TextStyle header = TextStyle(
    color: AppColors.textColor,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  // Regular text (e.g., paragraphs, form labels)
  static const TextStyle regular = TextStyle(
    color: AppColors.textColor,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  // Small text (e.g., hints, footnotes)
  static const TextStyle small = TextStyle(
    color: AppColors.textColor,
    fontSize: 13,
    fontWeight: FontWeight.w400,
  );

  // Button text (e.g., inside ElevatedButton or TextButton)
  static const TextStyle button = TextStyle(
    color: Colors.white, // good contrast on colored buttons
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
}