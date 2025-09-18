import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentHistoryScreen extends StatelessWidget {
  static const route = '/student-history';

  final String collegeName;
  final String department;
  final String semester;
  final String rollNo;

  const StudentHistoryScreen({
    super.key,
    required this.collegeName,
    required this.department,
    required this.semester,
    required this.rollNo,
  });

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case "approved":
        return Colors.green;
      case "rejected":
        return Colors.red;
      default:
        return Colors.amber; // pending
    }
  }

  String _month(int m) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return months[m - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Leave History"),
        backgroundColor: const Color(0xFF17B1A7),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Colleges")
            .doc(collegeName)
            .collection("Departments")
            .doc(department)
            .collection("Semesters")
            .doc(semester)
            .collection("Requests")
            .doc(rollNo)
            .collection("leave_requests")
            .orderBy("timestamp", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No leave history found."));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final type = data["type"] ?? "";
              final reason = data["reason"] ?? "";
              final status = data["status"] ?? "pending";

              final from = (data["fromDate"] as Timestamp).toDate();
              final to = (data["toDate"] as Timestamp).toDate();
              final days = to.difference(from).inDays + 1;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal,
                    child: Icon(
                      type == "Medical Leave"
                          ? Icons.local_hospital
                          : Icons.event,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    type,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${from.day} ${_month(from.month)} ${from.year} - "
                        "${to.day} ${_month(to.month)} ${to.year} "
                        "($days day${days > 1 ? "s" : ""})",
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reason,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "ID: ${doc.id}",
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.circle, color: _statusColor(status), size: 14),
                      const SizedBox(height: 4),
                      Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _statusColor(status),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
