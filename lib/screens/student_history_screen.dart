import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // ✅ for signed URLs
import 'package:url_launcher/url_launcher.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart'; // ✅ for inline PDF preview

class StudentHistoryScreen extends StatefulWidget {
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

  @override
  State<StudentHistoryScreen> createState() => _StudentHistoryScreenState();
}

class _StudentHistoryScreenState extends State<StudentHistoryScreen> {
  int _currentIndex = 2; // 0 = Home, 1 = Apply Leave, 2 = History
  final supabase = Supabase.instance.client;

  DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case "approved":
        return Colors.green;
      case "rejected":
        return Colors.red;
      default:
        return Colors.amber;
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

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/student-dashboard');
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, '/apply-leave');
    }
  }

  void _goBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, '/student-dashboard');
    }
  }

  Future<String?> _getSignedUrl(String path) async {
    try {
      return await supabase.storage
          .from('leave-docs')
          .createSignedUrl(path, 60 * 60); // valid 1h
    } catch (e) {
      debugPrint("Signed URL error: $e");
      return null;
    }
  }

  Future<void> _previewFile(String path) async {
    final signedUrl = await _getSignedUrl(path);
    if (signedUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error generating signed link")),
      );
      return;
    }

    final lower = path.toLowerCase();
    if (lower.endsWith(".pdf")) {
      // ✅ Inline PDF preview
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text("PDF Preview")),
            body: SfPdfViewer.network(signedUrl),
          ),
        ),
      );
    } else if (lower.endsWith(".png") ||
        lower.endsWith(".jpg") ||
        lower.endsWith(".jpeg")) {
      // ✅ Inline image preview
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text("Image Preview")),
            body: Center(child: Image.network(signedUrl)),
          ),
        ),
      );
    } else {
      // fallback: launch externally
      final uri = Uri.parse(signedUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final path =
        "Colleges/${widget.collegeName}/Departments/${widget.department}/Semesters/${widget.semester}/Requests/${widget.rollNo}/leave_requests";

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFF6F7F9),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onNavTap,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Apply Leave',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),

      body: Column(
        children: [
          // Header
          Container(
            height: 120,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              left: 16,
              right: 16,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF17B1A7), Color(0xFF11A0C8)],
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
                  onPressed: _goBack,
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const SizedBox(width: 8),
                const Text(
                  "Leave History",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("Colleges")
                  .doc(widget.collegeName)
                  .collection("Departments")
                  .doc(widget.department)
                  .collection("Semesters")
                  .doc(widget.semester)
                  .collection("Requests")
                  .doc(widget.rollNo)
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
                    final files = (data["files"] ?? []) as List;

                    final from = _parseDate(data["fromDate"]);
                    final to = _parseDate(data["toDate"]);
                    final days = to.difference(from).inDays + 1;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                radius: 22,
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
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
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
                                  const SizedBox(height: 6),
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
                                  Icon(
                                    Icons.circle,
                                    color: _statusColor(status),
                                    size: 14,
                                  ),
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

                            // File viewer
                            if (files.isNotEmpty) ...[
                              const Divider(),
                              ...files.map((path) {
                                final fileName = path.split('/').last;
                                return ListTile(
                                  leading: const Icon(
                                    Icons.insert_drive_file,
                                    color: Colors.teal,
                                  ),
                                  title: Text(
                                    fileName,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.visibility,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () => _previewFile(path),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.download,
                                          color: Colors.green,
                                        ),
                                        onPressed: () async {
                                          final signedUrl = await _getSignedUrl(
                                            path,
                                          );
                                          if (signedUrl != null) {
                                            final uri = Uri.parse(signedUrl);
                                            await launchUrl(
                                              uri,
                                              mode: LaunchMode
                                                  .externalApplication,
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
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
