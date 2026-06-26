// lib/screens/splash_screen.dart

import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _fadeAnim;
  late Animation<double>   _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _fadeAnim  = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeIn),
    );
    _scaleAnim = Tween<double>(begin: 0.7, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => FadeTransition(
            opacity: _fadeAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width:  90,
                    height: 90,
                    decoration: BoxDecoration(
                      color:        Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.work_rounded,
                      color: Colors.white,
                      size:  50,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'WorkLink LK',
                    style: TextStyle(
                      color:      Colors.white,
                      fontSize:   30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Find your next opportunity',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 48),
                  const SizedBox(
                    width:  24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color:       Colors.white60,
                      strokeWidth: 2.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}