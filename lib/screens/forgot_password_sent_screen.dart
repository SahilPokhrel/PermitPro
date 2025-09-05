import 'dart:async';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class ForgotPasswordSentScreen extends StatefulWidget {
  static const route = '/forgot-password-sent';
  const ForgotPasswordSentScreen({super.key});

  @override
  State<ForgotPasswordSentScreen> createState() =>
      _ForgotPasswordSentScreenState();
}

class _ForgotPasswordSentScreenState extends State<ForgotPasswordSentScreen> {
  static const int _startSeconds = 30;
  int _secondsLeft = _startSeconds;
  Timer? _timer;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _secondsLeft = _startSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  Future<void> _resendEmail() async {
    if (_secondsLeft > 0 || _sending) return;
    setState(() => _sending = true);

    // TODO: call your backend to resend reset email
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _sending = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Reset email re-sent')));
    _startCountdown(); // restart timer after resend
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canResend = _secondsLeft == 0 && !_sending;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              const Text(
                'Reset email has been sent !!!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'Follow the email instructions to reset your password',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const Icon(
                Icons.mark_email_read_outlined,
                size: 96,
                color: Colors.black87,
              ),
              const SizedBox(height: 24),

              // ---- Resend section ----
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Didn't get the mail? "),
                  if (!canResend)
                    Text(
                      'Resend after $_secondsLeft s',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  if (canResend)
                    TextButton(
                      onPressed: _resendEmail,
                      child: _sending
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Resend now'),
                    ),
                ],
              ),
              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushReplacementNamed(
                    context,
                    LoginScreen.route,
                  ),
                  child: const Text('Back to Sign in'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
