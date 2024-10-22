import 'package:flutter/material.dart';
import 'package:permitpro/student/student_pf_page.dart';
import 'login_page.dart';
import 'package:permitpro/hod/hod_pf_page.dart'; // Import HOD profile page

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _adminCodeController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureAdminCode = true;
  String _selectedRole = 'Student';

  // Controllers for new fields
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // Variables for Admin Code attempts
  int _adminCodeAttempts = 0;
  bool _isLockedOut = false;

  // Static Admin Code
  final String _adminCode = "123456";

  // Validator for mobile
  String? validateMobile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your mobile number';
    }
    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }

  // Validator for email
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  // Validator for full name
  String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name';
    }
    return null;
  }

  // Validator for admin code (only numbers)
  String? validateAdminCode(String? value) {
    if (_selectedRole == 'Admin') {
      if (value == null || value.isEmpty) {
        return 'Admin Code is required';
      }
      if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
        return 'Admin Code must be numbers only';
      }
    }
    return null;
  }

  // Function to handle signup process
  void _signUp() {
    if (_formKey.currentState!.validate()) {
      if (_selectedRole == 'Admin') {
        if (_isLockedOut) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('You are locked out for 10 seconds'),
          ));
          return;
        }

        if (_adminCodeController.text == _adminCode) {
          // Correct Admin Code, navigate to HOD profile page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HodProfilePage(),
            ),
          );
        } else {
          _adminCodeAttempts++;
          if (_adminCodeAttempts >= 5) {
            // Lock out for 10 seconds
            setState(() {
              _isLockedOut = true;
            });

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Too many attempts. Locked out for 10 seconds.'),
            ));

            // Reset the lockout after 10 seconds
            Future.delayed(Duration(seconds: 10), () {
              setState(() {
                _isLockedOut = false;
                _adminCodeAttempts = 0;
              });
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Incorrect Admin Code. Try again.'),
            ));
          }
        }
      } else {
        // Navigate to the Student Profile Page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StudentProfilePage(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Signup', style: TextStyle(color: Colors.white)),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Create an Account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 30),

              // Full Name Field
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: validateFullName,
              ),
              SizedBox(height: 15),

              // Email Field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: validateEmail,
              ),
              SizedBox(height: 15),

              // Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock, color: Colors.blue),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      color: Colors.blue,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),

              // Mobile Number Field
              TextFormField(
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
                  prefixIcon: Icon(Icons.phone, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: validateMobile,
              ),
              SizedBox(height: 15),

              // Role Dropdown
              DropdownButtonFormField<String>(
                value: _selectedRole,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRole = newValue!;
                  });
                },
                items: ['Student', 'Admin']
                    .map((role) => DropdownMenuItem<String>(
                  value: role,
                  child: Text(role),
                ))
                    .toList(),
                decoration: InputDecoration(
                  labelText: 'Role',
                  prefixIcon: Icon(Icons.person, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 15),

              // Admin Code Field (only visible if role is Admin)
              if (_selectedRole == 'Admin')
                TextFormField(
                  controller: _adminCodeController,
                  obscureText: _obscureAdminCode,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Admin Code',
                    prefixIcon: Icon(Icons.code, color: Colors.blue),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureAdminCode ? Icons.visibility : Icons.visibility_off,
                        color: Colors.blue,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureAdminCode = !_obscureAdminCode;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: validateAdminCode,
                ),
              SizedBox(height: 30),

              // Sign Up Button
              ElevatedButton(
                onPressed: _signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('Sign Up', style: TextStyle(fontSize: 18)),
              ),
              // "Already have an account?" Link
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account?'),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPage(),
                        ),
                      );
                    },
                    child: Text('Login'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
