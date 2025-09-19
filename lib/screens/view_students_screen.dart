// lib/screens/view_students_screen.dart
import 'package:flutter/material.dart';
import 'admin_dashboard_screen.dart';

class ViewStudentsScreen extends StatelessWidget {
  final String? collegeName;
  final String? department;

  const ViewStudentsScreen({Key? key, this.collegeName, this.department}) : super(key: key);

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
            const Text('View Students', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ]),
        ),
        Expanded(child: Center(child: Text('View Students — list & search here', style: TextStyle(fontSize: 16)))),
      ]),
    );
  }
}
