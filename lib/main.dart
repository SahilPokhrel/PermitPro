// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/change_password_screen.dart';
import 'screens/student_profile_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/forgot_password_sent_screen.dart';
import 'screens/student_dashboard_screen.dart';
import 'screens/apply_leave_screen.dart';

// New admin screens you added
import 'screens/admin_profile_screen.dart';
import 'screens/admin_dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Supabase.initialize(
    url: 'https://rpngyddzjzfmsvtvnclh.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJwbmd5ZGR6anpmbXN2dHZuY2xoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY1Mjg1ODQsImV4cCI6MjA3MjEwNDU4NH0.tMr_c0YE48yNyjRea6H13xtwcLi0ROWpt7XwHI-3iTM',
  );
  runApp(const PermitProApp());
}

class PermitProApp extends StatelessWidget {
  const PermitProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Permit Pro',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),

      // Start at Splash
      home: const SplashScreen(),

      // Static routes (screens WITHOUT required constructor args)
      routes: {
        LoginScreen.route: (_) => const LoginScreen(),
        ForgotPasswordScreen.route: (_) => const ForgotPasswordScreen(),
        ForgotPasswordSentScreen.route: (_) => const ForgotPasswordSentScreen(),
        StudentDashboardScreen.route: (_) => const StudentDashboardScreen(),
        ApplyLeaveScreen.route: (_) => const ApplyLeaveScreen(),
        // Admin dashboard can be routed dynamically (below) but
        // we also add a simple static fallback if you want to navigate w/o args.
        AdminDashboardScreen.route: (_) => const AdminDashboardScreen(),
      },

      // Handle dynamic routes which require arguments
      onGenerateRoute: (settings) {
        // CHANGE PASSWORD (requires collegeName, rollNo, role)
        if (settings.name == ChangePasswordScreen.route) {
          final args = settings.arguments as Map<String, dynamic>?;
          if (args == null ||
              !args.containsKey('collegeName') ||
              !args.containsKey('rollNo') ||
              !args.containsKey('role')) {
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(
                  child: Text(
                    "Missing arguments for ChangePasswordScreen (collegeName, rollNo, role)",
                  ),
                ),
              ),
            );
          }
          return MaterialPageRoute(
            builder: (_) => ChangePasswordScreen(
              collegeName: args['collegeName'] as String,
              rollNo: args['rollNo'] as String,
              role: args['role'] as String,
            ),
            settings: settings,
          );
        }

        // STUDENT PROFILE (requires collegeName + rollNo)
        if (settings.name == StudentProfileScreen.route) {
          final args = settings.arguments as Map<String, dynamic>?;
          if (args == null ||
              !args.containsKey('collegeName') ||
              !args.containsKey('rollNo')) {
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(
                  child: Text(
                    "Missing arguments for StudentProfileScreen (collegeName, rollNo)",
                  ),
                ),
              ),
            );
          }
          return MaterialPageRoute(
            builder: (_) => StudentProfileScreen(
              collegeName: args['collegeName'] as String,
              rollNo: args['rollNo'] as String,
            ),
            settings: settings,
          );
        }

        // ADMIN PROFILE (requires collegeName + rollNo)
        if (settings.name == AdminProfileScreen.route) {
          final args = settings.arguments as Map<String, dynamic>?;
          if (args == null ||
              !args.containsKey('collegeName') ||
              !args.containsKey('rollNo')) {
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(
                  child: Text(
                    "Missing arguments for AdminProfileScreen (collegeName, rollNo)",
                  ),
                ),
              ),
            );
          }
          return MaterialPageRoute(
            builder: (_) => AdminProfileScreen(
              collegeName: args['collegeName'] as String,
              rollNo: args['rollNo'] as String,
            ),
            settings: settings,
          );
        }

        // ADMIN DASHBOARD (optional args)
        if (settings.name == AdminDashboardScreen.route) {
          final _ = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (_) => AdminDashboardScreen(),
            settings: settings,
          );
        }

        // leave other routes to fallback / onUnknownRoute
        return null;
      },

      onUnknownRoute: (_) =>
          MaterialPageRoute(builder: (_) => const _UnknownRoutePage()),
    );
  }
}

// --- Temporary placeholder pages ---
class _UnknownRoutePage extends StatelessWidget {
  const _UnknownRoutePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unknown route')),
      body: const Center(child: Text('This route is not registered.')),
    );
  }
}
