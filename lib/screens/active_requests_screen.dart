// lib/screens/active_requests_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'admin_dashboard_screen.dart';

class ActiveRequestsScreen extends StatefulWidget {
  const ActiveRequestsScreen({Key? key}) : super(key: key);

  @override
  State<ActiveRequestsScreen> createState() => _ActiveRequestsScreenState();
}

class _ActiveRequestsScreenState extends State<ActiveRequestsScreen> {
  String? _collegeName;
  String? _department;
  List<String> _assignedSemesters = [];

  @override
  void initState() {
    super.initState();
    _fetchAdminContext();
  }

  Future<void> _fetchAdminContext() async {
    final prefs = await SharedPreferences.getInstance();
    _collegeName = prefs.getString('collegeName');
    final rollNo = prefs.getString('rollNo');

    if (_collegeName != null && rollNo != null) {
      final snap = await FirebaseFirestore.instance
          .collection("Colleges")
          .doc(_collegeName)
          .collection("Users")
          .doc(rollNo)
          .get();

      if (snap.exists) {
        final data = snap.data()!;
        setState(() {
          _department = data['department'];
          final dynamic sems = data['assignedSemesters'] ?? data['semester'];
          if (sems is List) {
            _assignedSemesters = sems.map((e) => e.toString()).toList();
          } else if (sems is String) {
            _assignedSemesters = [sems];
          }
        });
      }
    }
  }

  void _goHome() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AdminDashboardScreen.route,
      (r) => false,
    );
  }

  Future<void> _updateStatus(DocumentReference ref, String newStatus) async {
    await ref.update({'status': newStatus});
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Leave $newStatus")));
  }

  @override
  Widget build(BuildContext context) {
    if (_collegeName == null ||
        _department == null ||
        _assignedSemesters.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          // 🔹 Header
          Container(
            height: 120,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              left: 16,
              right: 16,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00B3A8), Color(0xFF0EA5E9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: _goHome,
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const SizedBox(width: 8),
                const Text(
                  "Active Requests",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // 🔹 Content
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collectionGroup("leave_requests")
                  .where("status", isEqualTo: "pending")
                  .snapshots(),
              builder: (context, snapshot) {
                // ✅ Show loader only while waiting
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // ✅ Handle Firestore errors
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                // ✅ If no documents at all
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No active requests"));
                }

                // ✅ Filter docs by admin’s department + assigned semesters
                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final dept = data['department'];
                  final sem = data['semester'];

                  return dept == _department &&
                      _assignedSemesters.contains(sem);
                }).toList();

                if (docs.isEmpty) {
                  return const Center(child: Text("No active requests"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final studentId =
                        doc.reference.parent.parent?.id ?? "Unknown";
                    final type = data["type"] ?? "";
                    final reason = data["reason"] ?? "";
                    final from = (data["fromDate"] as Timestamp).toDate();
                    final to = (data["toDate"] as Timestamp).toDate();

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Student: $studentId",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text("Type: $type"),
                            Text("Reason: $reason"),
                            Text("From: ${from.toLocal()}"),
                            Text("To: ${to.toLocal()}"),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  onPressed: () =>
                                      _updateStatus(doc.reference, "accepted"),
                                  child: const Text("Accept"),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  onPressed: () =>
                                      _updateStatus(doc.reference, "rejected"),
                                  child: const Text("Reject"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
