import 'package:flutter/material.dart';
import 'login_screen.dart';

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

    // ✅ Initialize controllers immediately
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _logoSlide =
        Tween<Offset>(
          begin: const Offset(0, -2), // way above screen
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
        );

    _nameController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slogan = "Smart Leave Management";

    // ✅ Start animations only after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _logoController.forward();

      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) _nameController.forward();
      });

      Future.delayed(const Duration(milliseconds: 1800), () {
        if (mounted) _startTyping();
      });

      Future.delayed(const Duration(seconds: 4), () {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const LoginScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 700),
          ),
        );
      });
    });
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
            // Logo from top
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

            // App name fades in
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

            // Typing slogan
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
