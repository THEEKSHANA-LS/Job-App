// lib/widgets/app_snackbar.dart

import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class AppSnackBar {
  static void success(BuildContext context, String message) {
    _show(context, message, AppColors.success, Icons.check_circle_rounded);
  }

  static void error(BuildContext context, String message) {
    _show(context, message, AppColors.error, Icons.error_outline_rounded);
  }

  static void info(BuildContext context, String message) {
    _show(context, message, AppColors.primary, Icons.info_outline_rounded);
  }

  static void _show(BuildContext context, String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: color,
          behavior:        SnackBarBehavior.floating,
          duration:        const Duration(seconds: 3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        ),
      );
  }
}