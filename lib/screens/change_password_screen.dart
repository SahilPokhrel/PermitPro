import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ for Firestore
import 'student_profile_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  static const route = '/change-password';

  final String collegeName; // ✅ pass from login screen
  final String rollNo;

  const ChangePasswordScreen({
    super.key,
    required this.collegeName,
    required this.rollNo,
  });

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // 🔥 Update the user in Firestore
      final query = await FirebaseFirestore.instance
          .collection("Colleges")
          .doc(widget.collegeName)
          .collection("Users")
          .where("rollNo", isEqualTo: widget.rollNo)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final docId = query.docs.first.id;

        await FirebaseFirestore.instance
            .collection("Colleges")
            .doc(widget.collegeName)
            .collection("Users")
            .doc(docId)
            .update({
              "password": _newCtrl.text.trim(),
              "isPasswordChanged": true,
            });

        // ✅ Redirect to Student Profile
        Navigator.pushNamedAndRemoveUntil(
          context,
          StudentProfileScreen.route,
          (_) => false,
        );
      } else {
        setState(() {
          _error = "User not found.";
        });
      }
    } catch (e) {
      setState(() {
        _error = "Failed to update password: $e";
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Your Password')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Please set your new password to proceed',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _newCtrl,
                obscureText: _obscureNew,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNew ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter a password';
                  if (v.length < 6) return 'Use at least 6 characters';
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _confirmCtrl,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Re-enter the password';
                  if (v != _newCtrl.text) return 'Passwords do not match';
                  return null;
                },
              ),

              const SizedBox(height: 24),

              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              if (_loading) const Center(child: CircularProgressIndicator()),

              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: const Text('Reset'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
