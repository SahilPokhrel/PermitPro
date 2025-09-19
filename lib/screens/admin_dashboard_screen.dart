// lib/screens/admin_dashboard_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'add_student_screen.dart';
import 'view_students_screen.dart';
import 'reports_screen.dart';
import 'active_requests_screen.dart';
import 'admin_history_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  static const route = '/admin-dashboard';
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _WelcomeBlockAdmin extends StatelessWidget {
  final String name;
  const _WelcomeBlockAdmin({required this.name});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('welcome-expanded-admin'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Welcome back,\n$name',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _collapsed = false;
  String _userName = "Loading...";
  String? _profileImageUrl;

  // admin context
  String? _collegeName;
  String? _rollNo;
  String? _department;
  List<String> _assignedSemesters = [];

  // Dashboard stats
  int _accepted = 0;
  int _pending = 0;
  int _rejected = 0;

  int _today = 0;
  int _thisWeek = 0;
  int _thisMonth = 0;

  StreamSubscription<QuerySnapshot>? _leavesSub;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _fetchUserInfo();
    _subscribeToLeaveRequests();
  }

  Future<void> _fetchUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _collegeName = prefs.getString('collegeName');
      _rollNo = prefs.getString('rollNo');

      if (_collegeName != null && _rollNo != null) {
        final snap = await FirebaseFirestore.instance
            .collection("Colleges")
            .doc(_collegeName)
            .collection("Users")
            .doc(_rollNo)
            .get();

        if (snap.exists) {
          final data = snap.data()!;
          setState(() {
            _userName = (data['name'] as String?) ?? 'Admin';
            _profileImageUrl = (data['profileImageUrl'] as String?) ?? '';
            _department = (data['department'] as String?) ?? _department;
            // assignedSemesters can be a list in user doc, or a single 'semester' string
            final dynamic sems = data['assignedSemesters'] ?? data['semesters'] ?? data['semester'];
            if (sems is List) {
              _assignedSemesters = sems.map((e) => e.toString()).toList();
            } else if (sems is String) {
              _assignedSemesters = [sems];
            }
            // fallback: if still empty try any 'semester' field
            if (_assignedSemesters.isEmpty && data['semester'] != null) {
              _assignedSemesters = [data['semester'].toString()];
            }
          });
        } else {
          setState(() => _userName = 'Admin');
        }
      } else {
        setState(() => _userName = 'Admin');
      }
    } catch (e, st) {
      debugPrint('Failed to fetch admin info: $e\n$st');
      setState(() => _userName = 'Admin');
    }
  }

  DateTime? _toDateTime(dynamic ts) {
    if (ts == null) return null;
    if (ts is Timestamp) return ts.toDate();
    if (ts is DateTime) return ts;
    if (ts is int) return DateTime.fromMillisecondsSinceEpoch(ts);
    return null;
  }

  void _subscribeToLeaveRequests() {
    // Cancel previous
    _leavesSub?.cancel();

    // Need admin context
    if (_collegeName == null || _department == null || _assignedSemesters.isEmpty) {
      // wait and try again after a short delay
      Future.delayed(const Duration(milliseconds: 400), _subscribeToLeaveRequests);
      return;
    }

    _leavesSub = FirebaseFirestore.instance
        .collectionGroup('leave_requests')
        .snapshots()
        .listen((qs) {
      int accepted = 0, pending = 0, rejected = 0;
      int today = 0, thisWeek = 0, thisMonth = 0;

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final startOfWeek = startOfDay.subtract(Duration(days: now.weekday - 1)); // Monday
      final startOfMonth = DateTime(now.year, now.month, 1);

      for (final doc in qs.docs) {
        final path = doc.reference.path;
        // Ensure path belongs to the admin's college & department
        final expectedPrefix = 'Colleges/${_collegeName}/Departments/${_department}/';
        if (!path.contains(expectedPrefix)) continue;

        // Check semester match
        final matchesSemester = _assignedSemesters.any((s) => path.contains('/Semesters/$s/'));
        if (!matchesSemester) continue;

        final data = doc.data();
        final status = (data['status'] ?? 'pending').toString().toLowerCase();
        final ts = _toDateTime(data['timestamp']);

        if (status == 'accepted') accepted++;
        else if (status == 'rejected') rejected++;
        else pending++;

        if (ts != null) {
          if (ts.isAfter(startOfDay)) today++;
          if (ts.isAfter(startOfWeek)) thisWeek++;
          if (ts.isAfter(startOfMonth)) thisMonth++;
        }
      }

      if (mounted) {
        setState(() {
          _accepted = accepted;
          _pending = pending;
          _rejected = rejected;
          _today = today;
          _thisWeek = thisWeek;
          _thisMonth = thisMonth;
        });
      }
    }, onError: (e) {
      debugPrint('Leave subscription error: $e');
    });
  }

  Future<void> _confirmAndLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to quit the application?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("No")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Yes")),
        ],
      ),
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('collegeName');
      await prefs.remove('rollNo');
      if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
    }
  }

  @override
  void dispose() {
    _leavesSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const gradientStart = Color(0xFF00B3A8);
    const gradientEnd = Color(0xFF0EA5E9);

    return Scaffold(
      bottomNavigationBar: _AdminBottomNav(),
      body: NestedScrollView(
        headerSliverBuilder: (context, inner) => [
          SliverAppBar(
            pinned: true,
            floating: false,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            expandedHeight: 200,
            collapsedHeight: 72,
            centerTitle: true,
            title: AnimatedOpacity(
              opacity: _collapsed ? 1 : 0,
              duration: const Duration(milliseconds: 180),
              child: const Text(
                'Home',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            actionsIconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
              PopupMenuButton<String>(
                icon: const Icon(Icons.settings_outlined),
                onSelected: (value) {
                  if (value == 'logout') _confirmAndLogout();
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 8),
                        Text("Logout"),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                final h = constraints.maxHeight;
                final isCollapsed = h <= (kToolbarHeight + 28);
                if (isCollapsed != _collapsed && mounted) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _collapsed = isCollapsed);
                  });
                }

                return ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [gradientStart, gradientEnd],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: AnimatedOpacity(
                        opacity: _collapsed ? 0 : 1,
                        duration: const Duration(milliseconds: 160),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.white,
                                backgroundImage:
                                    (_profileImageUrl != null && _profileImageUrl!.isNotEmpty)
                                        ? NetworkImage(_profileImageUrl!)
                                        : null,
                                child: (_profileImageUrl == null || _profileImageUrl!.isEmpty)
                                    ? const Icon(Icons.person, size: 28, color: Colors.black54)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: _WelcomeBlockAdmin(name: _userName)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Dashboard",
                  style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w700),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: const StadiumBorder(),
                    side: BorderSide(color: Colors.blue.shade300),
                  ),
                  onPressed: () {
                    // open Admin history page showing handled semesters
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminHistoryScreen(
                          collegeName: _collegeName ?? '',
                          department: _department ?? '',
                          assignedSemesters: _assignedSemesters,
                        ),
                      ),
                    );
                  },
                  child: const Text("View History"),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(child: _AdminStatCard(label: 'Accepted', value: '$_accepted', icon: Icons.check_circle_outline)),
                const SizedBox(width: 8),
                Expanded(child: _AdminStatCard(label: 'Pending', value: '$_pending', icon: Icons.pending_outlined)),
                const SizedBox(width: 8),
                Expanded(child: _AdminStatCard(label: 'Rejected', value: '$_rejected', icon: Icons.cancel_outlined)),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Other Options", style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w700)),
                TextButton(onPressed: () {}, child: const Text("View all")),
              ],
            ),
            const SizedBox(height: 12),

            _AdminOptionTile(
              icon: Icons.person_add_alt,
              title: 'Add new student',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddStudentScreen(
                      collegeName: _collegeName,
                      department: _department,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            _AdminOptionTile(
              icon: Icons.remove_red_eye_outlined,
              title: 'View Students',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ViewStudentsScreen(
                      collegeName: _collegeName,
                      department: _department,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            _AdminOptionTile(
              icon: Icons.bar_chart,
              title: 'Report & Analytics',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReportsScreen(
                      collegeName: _collegeName,
                      department: _department,
                      assignedSemesters: _assignedSemesters,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 18),

            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Quick Summary', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      _smallMetric('Today', '$_today'),
                      _smallMetric('This Week', '$_thisWeek'),
                      _smallMetric('This Month', '$_thisMonth'),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallMetric(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class _AdminStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _AdminStatCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, color: Colors.black54, size: 16),
            const SizedBox(width: 4),
            Flexible(child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
          ]),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        ]),
      ),
    );
  }
}

class _AdminOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _AdminOptionTile({required this.icon, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: const Color.fromRGBO(0, 0, 0, 0.04), blurRadius: 8)],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Row(children: [
          CircleAvatar(backgroundColor: Colors.teal.shade50, child: Icon(icon, color: Colors.teal)),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600))),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ]),
      ),
    );
  }
}

class _AdminBottomNav extends StatelessWidget {
  const _AdminBottomNav();

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: 0,
      onDestinationSelected: (i) {
        switch (i) {
          case 0:
            Navigator.pushNamedAndRemoveUntil(context, AdminDashboardScreen.route, (r) => false);
            break;
          case 1:
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ActiveRequestsScreen()));
            break;
          case 2:
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminHistoryScreen.blank()));
            break;
        }
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.request_page), selectedIcon: Icon(Icons.request_page), label: 'Active requests'),
        NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history), label: 'History'),
      ],
    );
  }
}
