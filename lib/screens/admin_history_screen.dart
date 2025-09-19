// lib/screens/admin_history_screen.dart
import 'package:flutter/material.dart';
import 'admin_dashboard_screen.dart';

class AdminHistoryScreen extends StatelessWidget {
  final String collegeName;
  final String department;
  final List<String> assignedSemesters;

  const AdminHistoryScreen({
    Key? key,
    required this.collegeName,
    required this.department,
    required this.assignedSemesters,
  }) : super(key: key);

  // convenience constructor used by bottom nav when args aren't passed
  const AdminHistoryScreen.blank({Key? key})
      : collegeName = '',
        department = '',
        assignedSemesters = const [],
        super(key: key);

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
            const Text('History', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ]),
        ),
        Expanded(child: Center(child: Text('History for assigned semesters will be shown here', style: TextStyle(fontSize: 16)))),
      ]),
    );
  }
}
