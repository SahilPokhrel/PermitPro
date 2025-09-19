// lib/screens/add_student_screen.dart
import 'package:flutter/material.dart';
import 'admin_dashboard_screen.dart';

class AddStudentScreen extends StatelessWidget {
  final String? collegeName;
  final String? department;

  const AddStudentScreen({Key? key, this.collegeName, this.department}) : super(key: key);

  void _goHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, AdminDashboardScreen.route, (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Column(children: [
        Container(
          height: 120,
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, left: 16, right: 16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF00B3A8), Color(0xFF0EA5E9)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
          ),
          child: Row(children: [
            IconButton(onPressed: () => _goHome(context), icon: const Icon(Icons.arrow_back, color: Colors.white)),
            const SizedBox(width: 8),
            const Text('Add new student', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ]),
        ),
        Expanded(
          child: Center(child: Text('Add Student screen — implement form here', style: TextStyle(fontSize: 16))),
        ),
      ]),
    );
  }
}
