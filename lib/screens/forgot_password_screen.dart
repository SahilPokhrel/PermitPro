import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'forgot_password_sent_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static const route = '/forgot-password';
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _collegeCtrl = TextEditingController();
  final _rollCtrl = TextEditingController();

  AutovalidateMode _av = AutovalidateMode.disabled;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _collegeCtrl.dispose();
    _rollCtrl.dispose();
    super.dispose();
  }

  String? _vEmail(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return 'Enter your email';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s);
    if (!ok) return 'Enter a valid email';
    return null;
  }

  String? _vCollege(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return 'Enter your college';
    if (s.length < 3) return 'Too short';
    return null;
  }

  String? _vRoll(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return 'Enter roll number';
    final ok = RegExp(r'^[A-Za-z0-9\-_/]{3,20}$').hasMatch(s);
    if (!ok) return 'Invalid format';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _av = AutovalidateMode.onUserInteraction);
      return;
    }
    setState(() => _loading = true);

    // TODO: call your backend here to send reset email
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.pushReplacementNamed(context, ForgotPasswordSentScreen.route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0, title: const Text('Forgot Password')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Form(
            key: _formKey,
            autovalidateMode: _av,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Forgot  Password?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 6),
                const Center(
                  child: Text(
                    'No worries, we’ll send you reset instructions',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),

                // Email
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Uname@mail.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: _vEmail,
                ),
                const SizedBox(height: 16),

                // College
                TextFormField(
                  controller: _collegeCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'College name',
                    prefixIcon: Icon(Icons.account_balance_outlined),
                  ),
                  validator: _vCollege,
                ),
                const SizedBox(height: 16),

                // Roll number
                TextFormField(
                  controller: _rollCtrl,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    hintText: 'College Roll Number',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: _vRoll,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 20),

                // Reset button
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Reset Password'),
                  ),
                ),
                const SizedBox(height: 12),

                // Back to Sign In (outlined)
                SizedBox(
                  height: 44,
                  child: OutlinedButton(
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
      ),
    );
  }
}
