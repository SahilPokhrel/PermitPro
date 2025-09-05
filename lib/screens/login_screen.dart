import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'change_password_screen.dart';
import 'student_dashboard_screen.dart'; // ✅ add this

class LoginScreen extends StatefulWidget {
  static const route = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _collegeCtrl = TextEditingController();
  final _rollCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  final _collegeNode = FocusNode();
  final _rollNode = FocusNode();
  final _passNode = FocusNode();

  bool _obscure = true;
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;
  bool _loading = false;
  String? _error;

  // 🔽 Colleges list
  List<String> _colleges = [];
  bool _loadingColleges = true;

  @override
  void initState() {
    super.initState();
    _loadColleges();
  }

  Future<void> _loadColleges() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("Colleges")
          .get();

      setState(() {
        _colleges = snapshot.docs.map((doc) => doc.id).toList();
        _loadingColleges = false;
      });
    } catch (e) {
      setState(() => _loadingColleges = false);
      print("Error loading colleges: $e");
    }
  }

  @override
  void dispose() {
    _collegeCtrl.dispose();
    _rollCtrl.dispose();
    _passCtrl.dispose();
    _collegeNode.dispose();
    _rollNode.dispose();
    _passNode.dispose();
    super.dispose();
  }

  String? _validateCollege(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Please select your college';
    return null;
  }

  String? _validateRoll(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Enter your roll number';
    final ok = RegExp(r'^[A-Za-z0-9\-_/]{3,20}$').hasMatch(value);
    if (!ok) return 'Invalid roll number format';
    return null;
  }

  String? _validatePassword(String? v) {
    final value = v ?? '';
    if (value.isEmpty) return 'Enter your password';
    if (value.length < 6) return 'Use at least 6 characters';
    return null;
  }

  Future<void> _submit() async {
    final valid = _formKey.currentState!.validate();
    if (!valid) {
      setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final docRef = FirebaseFirestore.instance
          .collection("Colleges")
          .doc(_collegeCtrl.text.trim())
          .collection("Users")
          .doc(_rollCtrl.text.trim()); // ✅ rollNo = doc.id

      final docSnap = await docRef.get();

      if (!docSnap.exists) {
        setState(() {
          _error = "User not found. Please check your roll number.";
        });
        return;
      }

      final userData = docSnap.data()!;
      final dbPassword = userData["password"];
      final isChanged = userData["isPasswordChanged"] ?? false;
      final role = userData["role"] ?? "student";

      if (_passCtrl.text.trim() != dbPassword) {
        setState(() {
          _error = "Invalid password. Please try again.";
        });
        return;
      }

      // ✅ Login success
      if (!isChanged) {
        // First-time login → force change password
        Navigator.pushReplacementNamed(
          context,
          ChangePasswordScreen.route,
          arguments: {
            'collegeName': _collegeCtrl.text.trim(),
            'rollNo': _rollCtrl.text.trim(),
          },
        );
      } else {
        // ✅ Redirect by role
        if (role.toLowerCase() == "student") {
          Navigator.pushReplacementNamed(
            context,
            StudentDashboardScreen.route,
            arguments: {
              'collegeName': _collegeCtrl.text.trim(),
              'rollNo': _rollCtrl.text.trim(),
            },
          );
        } else if (role.toLowerCase() == "admin") {
          Navigator.pushReplacementNamed(
            context,
            '/admin-dashboard', // 🔜 implement later
            arguments: {
              'collegeName': _collegeCtrl.text.trim(),
              'rollNo': _rollCtrl.text.trim(),
            },
          );
        }
      }
    } catch (e) {
      setState(() {
        _error = "Login failed: $e";
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 48,
            ),
            child: IntrinsicHeight(
              child: Form(
                key: _formKey,
                autovalidateMode: _autovalidate,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    const Hero(
                      tag: 'pp-logo',
                      child: Icon(
                        Icons.event_available,
                        color: Colors.blue,
                        size: 64,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Login to continue',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Let's get going",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 32),

                    // 🔽 College Dropdown
                    _loadingColleges
                        ? const CircularProgressIndicator()
                        : DropdownButtonFormField<String>(
                            value: _collegeCtrl.text.isNotEmpty
                                ? _collegeCtrl.text
                                : null,
                            decoration: const InputDecoration(
                              labelText: 'College name',
                              prefixIcon: Icon(Icons.account_balance_outlined),
                            ),
                            items: _colleges.map((college) {
                              return DropdownMenuItem(
                                value: college,
                                child: Text(college),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _collegeCtrl.text = value ?? '';
                              });
                              _rollNode.requestFocus();
                            },
                            validator: _validateCollege,
                          ),
                    const SizedBox(height: 16),

                    // Roll number
                    TextFormField(
                      controller: _rollCtrl,
                      focusNode: _rollNode,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'College Roll Number',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: _validateRoll,
                      onFieldSubmitted: (_) => _passNode.requestFocus(),
                    ),
                    const SizedBox(height: 16),

                    // Password
                    TextFormField(
                      controller: _passCtrl,
                      focusNode: _passNode,
                      textInputAction: TextInputAction.done,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure ? Icons.visibility : Icons.visibility_off,
                          ),
                        ),
                      ),
                      validator: _validatePassword,
                      onFieldSubmitted: (_) => _submit(),
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/forgot-password');
                        },
                        child: const Text('Forgot Password?'),
                      ),
                    ),
                    const SizedBox(height: 8),

                    if (_error != null)
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                    if (_loading) const CircularProgressIndicator(),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        child: const Text('Sign in'),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
