import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_screen.dart';
import 'change_password_screen.dart';
import 'student_profile_screen.dart';
import 'admin_profile_screen.dart';
import 'student_dashboard_screen.dart';
import 'admin_dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  static const route = '/';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<Offset> _logoSlide;
  late AnimationController _nameController;
  late String _slogan;
  String _typedSlogan = "";

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _logoSlide = Tween<Offset>(
      begin: const Offset(0, -2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    _nameController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slogan = "Smart Leave Management";

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _logoController.forward();

      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) _nameController.forward();
      });

      Future.delayed(const Duration(milliseconds: 1800), () {
        if (mounted) _startTyping();
      });

      // ⏳ After 4 seconds → decide navigation
      Future.delayed(const Duration(seconds: 4), _decideNavigation);
    });
  }

  Future<void> _decideNavigation() async {
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final savedCollege = prefs.getString('collegeName');
    final savedRoll = prefs.getString('rollNo');

    if (savedCollege == null || savedRoll == null) {
      _goTo(const LoginScreen());
      return;
    }

    try {
      final docRef = FirebaseFirestore.instance
          .collection('Colleges')
          .doc(savedCollege)
          .collection('Users')
          .doc(savedRoll);

      final snap = await docRef.get();
      if (!snap.exists) {
        await prefs.clear();
        _goTo(const LoginScreen());
        return;
      }

      final data = snap.data()!;
      final role = (data['role'] ?? 'student').toString().toLowerCase();
      final isProfileEdited = data['isProfileEdited'] == true;
      final isChanged = data['isPasswordChanged'] == true;

      if (!isChanged) {
        _goTo(ChangePasswordScreen(
          collegeName: savedCollege,
          rollNo: savedRoll,
          role: role,
        ));
        return;
      }

      if (!isProfileEdited) {
        if (role == 'admin') {
          _goTo(AdminProfileScreen(
            collegeName: savedCollege,
            rollNo: savedRoll,
          ));
        } else {
          _goTo(StudentProfileScreen(
            collegeName: savedCollege,
            rollNo: savedRoll,
          ));
        }
        return;
      }

      // ✅ Everything fine → go to dashboard
      if (role == 'admin') {
        _goTo(const AdminDashboardScreen());
      } else {
        _goTo(const StudentDashboardScreen());
      }
    } catch (e) {
      await prefs.clear();
      _goTo(const LoginScreen());
    }
  }

  void _goTo(Widget page) {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 700),
      ),
    );
  }

  void _startTyping() async {
    for (int i = 0; i <= _slogan.length; i++) {
      await Future.delayed(const Duration(milliseconds: 80));
      if (!mounted) return;
      setState(() {
        _typedSlogan = _slogan.substring(0, i);
      });
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SlideTransition(
              position: _logoSlide,
              child: const Hero(
                tag: 'pp-logo',
                child: Icon(
                  Icons.event_available,
                  color: Colors.blue,
                  size: 100,
                ),
              ),
            ),
            const SizedBox(height: 16),
            FadeTransition(
              opacity: _nameController,
              child: const Text(
                "Permit Pro",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _typedSlogan,
              style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
