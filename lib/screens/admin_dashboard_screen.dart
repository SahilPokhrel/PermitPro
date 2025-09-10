// lib/screens/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final collegeName = prefs.getString('collegeName');
      final rollNo = prefs.getString('rollNo');

      if (collegeName != null && rollNo != null) {
        final snap = await FirebaseFirestore.instance
            .collection("Colleges")
            .doc(collegeName)
            .collection("Users")
            .doc(rollNo)
            .get();

        if (snap.exists) {
          setState(() {
            _userName = (snap.data()?['name'] as String?) ?? 'Admin';
          });
        } else {
          setState(() => _userName = 'Admin');
        }
      } else {
        setState(() => _userName = 'Admin');
      }
    } catch (e) {
      // If fetch fails, keep a safe default
      setState(() => _userName = 'Admin');
    }
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
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const gradientStart = Color(0xFF00B3A8);
    const gradientEnd = Color(0xFF0EA5E9);

    return Scaffold(
      bottomNavigationBar: const _AdminBottomNav(),
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
              child: const Text('Home', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
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
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [gradientStart, gradientEnd], begin: Alignment.topLeft, end: Alignment.bottomRight),
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
                              const CircleAvatar(radius: 28, backgroundColor: Colors.white, child: Icon(Icons.person, size: 28, color: Colors.black54)),
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
                Text("Dashboard", style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w700)),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: const StadiumBorder(),
                    side: BorderSide(color: Colors.blue.shade300),
                  ),
                  onPressed: () {},
                  child: const Text("View History"),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: const [
                Expanded(child: _AdminStatCard(label: 'Accepted', value: '12', icon: Icons.check_circle_outline)),
                SizedBox(width: 8),
                Expanded(child: _AdminStatCard(label: 'Pending', value: '03', icon: Icons.pending_outlined)),
                SizedBox(width: 8),
                Expanded(child: _AdminStatCard(label: 'Rejected', value: '05', icon: Icons.cancel_outlined)),
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

            _AdminOptionTile(icon: Icons.person_add_alt, title: 'Add new student', onTap: () {}),
            const SizedBox(height: 10),
            _AdminOptionTile(icon: Icons.remove_red_eye_outlined, title: 'View Students', onTap: () {}),
            const SizedBox(height: 10),
            _AdminOptionTile(icon: Icons.bar_chart, title: 'Report & Analytics', onTap: () {}),

            const SizedBox(height: 18),

            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Quick Summary', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    _smallMetric('Today', '08'),
                    _smallMetric('This Week', '43'),
                    _smallMetric('This Month', '210'),
                  ]),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallMetric(String label, String value) {
    return Column(children: [Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 4), Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey))]);
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
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, color: Colors.black54, size: 20),
            const SizedBox(width: 6),
            Expanded(
              child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
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
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)]),
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
            Navigator.pushReplacementNamed(context, AdminDashboardScreen.route);
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/active-requests');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/history');
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
