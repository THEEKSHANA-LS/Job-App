// lib/screens/splash_screen.dart

import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_rounded, color: Colors.white, size: 64),
            SizedBox(height: 16),
            Text(
              'WorkLink LK',
              style: TextStyle(
                color:      Colors.white,
                fontSize:   28,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Find your next opportunity',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}