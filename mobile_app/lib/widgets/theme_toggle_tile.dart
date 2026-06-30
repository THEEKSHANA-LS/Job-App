// lib/widgets/theme_toggle_tile.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/theme_provider.dart';

/// Drop-in ListTile-style row with a dark mode switch. Place it inside any
/// profile/settings screen's Column.
class ThemeToggleTile extends StatelessWidget {
  const ThemeToggleTile({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        themeProvider.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
        color: AppColors.primary,
      ),
      title: const Text(
        'Dark Mode',
        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
      trailing: Switch(
        value:        themeProvider.isDarkMode,
        activeColor:  AppColors.primary,
        onChanged:    (_) => themeProvider.toggle(),
      ),
      onTap: themeProvider.toggle,
    );
  }
}