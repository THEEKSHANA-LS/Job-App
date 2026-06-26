// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'constants/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/job_provider.dart';
import 'providers/application_provider.dart';
import 'providers/saved_job_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/profile_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/jobseeker/jobseeker_home.dart';
import 'screens/employer/employer_home.dart';
import 'screens/admin/admin_home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor:            Colors.transparent,
      statusBarIconBrightness:   Brightness.dark,
      systemNavigationBarColor:  Colors.white,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider(create: (_) => JobProvider()),
        ChangeNotifierProvider(create: (_) => ApplicationProvider()),
        ChangeNotifierProvider(create: (_) => SavedJobProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: const WorkLinkApp(),
    ),
  );
}

class WorkLinkApp extends StatelessWidget {
  const WorkLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title:                      'WorkLink LK',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme.copyWith(
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const _RootRouter(),
    );
  }
}

/// Listens to [AuthProvider] and routes based on auth status + role.
class _RootRouter extends StatelessWidget {
  const _RootRouter();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    switch (auth.status) {
      case AuthStatus.initial:
        return const SplashScreen();

      case AuthStatus.authenticated:
        final role = auth.user?.role ?? 'jobseeker';
        if (role == 'admin')    return const AdminHome();
        if (role == 'employer') return const EmployerHome();
        return const JobSeekerHome();

      default:
        return const LoginScreen();
    }
  }
}