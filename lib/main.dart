import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/change_password_screen.dart';
import 'screens/student_profile_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/forgot_password_sent_screen.dart';
import 'screens/student_dashboard_screen.dart';
import 'screens/apply_leave_screen.dart';

// --- MAIN ENTRY ---
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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

      // ✅ Start at Splash
      home: const SplashScreen(),

      // ✅ Static routes (only screens with no required arguments)
      routes: {
        LoginScreen.route: (_) => const LoginScreen(),
        ForgotPasswordScreen.route: (_) => const ForgotPasswordScreen(),
        ForgotPasswordSentScreen.route: (_) => const ForgotPasswordSentScreen(),
        StudentDashboardScreen.route: (_) => const StudentDashboardScreen(),
        ApplyLeaveScreen.route: (_) => const ApplyLeaveScreen(),
      },

      // ✅ Handle dynamic routes with arguments
      onGenerateRoute: (settings) {
        if (settings.name == ChangePasswordScreen.route) {
          final args = settings.arguments as Map<String, dynamic>?;
          if (args == null) {
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(
                    child: Text("Missing arguments for ChangePasswordScreen")),
              ),
            );
          }
          return MaterialPageRoute(
            builder: (_) => ChangePasswordScreen(
              collegeName: args['collegeName'],
              rollNo: args['rollNo'],
            ),
          );
        }

        if (settings.name == StudentProfileScreen.route) {
          final args = settings.arguments as Map<String, dynamic>?;
          if (args == null) {
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(
                    child: Text("Missing arguments for StudentProfileScreen")),
              ),
            );
          }
          return MaterialPageRoute(
            builder: (_) => StudentProfileScreen(
              collegeName: args['collegeName'],
              rollNo: args['rollNo'],
            ),
          );
        }

        return null;
      },

      onUnknownRoute: (_) =>
          MaterialPageRoute(builder: (_) => const _UnknownRoutePage()),
    );
  }
}

// --- Temporary placeholder pages ---
class _HistoryPlaceholder extends StatelessWidget {
  const _HistoryPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: const Center(child: Text('History screen coming soon')),
    );
  }
}

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
