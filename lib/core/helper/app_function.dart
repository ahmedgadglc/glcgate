import 'package:flutter/material.dart';

/// Helper functions used throughout the app
class AppFunctions {
  AppFunctions._();

  /// Format number with commas and proper decimal places
  static String formatNumber(double value) {
    if (value == 0) return '0';

    // If it's a whole number, don't show decimals
    if (value == value.roundToDouble()) {
      return _addCommas(value.toInt().toString());
    }

    // Format with 2 decimal places
    String formatted = value.toStringAsFixed(2);

    // Remove trailing zeros
    if (formatted.contains('.')) {
      formatted = formatted.replaceAll(RegExp(r'0+$'), '');
      if (formatted.endsWith('.')) {
        formatted = formatted.substring(0, formatted.length - 1);
      }
    }

    // Add commas
    final parts = formatted.split('.');
    parts[0] = _addCommas(parts[0]);
    return parts.join('.');
  }

  static String _addCommas(String value) {
    if (value.length <= 3) return value;

    final regex = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return value.replaceAllMapped(regex, (match) => '${match[1]},');
  }

  /// Format number as integer string
  static String formatInt(int value) {
    return _addCommas(value.toString());
  }

  /// Show alert dialog with confirmation
  static Future<void> showAlertDialog({
    required dynamic context,
    required String title,
    required String description,
    required Function() onYes,
    required Function() onNo,
    IconData? icon,
    dynamic color,
  }) async {
    // This is a placeholder - implement if needed
  }
}

