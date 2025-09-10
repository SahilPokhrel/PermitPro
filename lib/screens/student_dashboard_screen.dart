import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentDashboardScreen extends StatefulWidget {
  static const route = '/student-dashboard';
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _WelcomeBlock extends StatelessWidget {
  final String name;
  const _WelcomeBlock({required this.name});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('welcome-expanded'),
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

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  bool _collapsed = false;
  String _userName = "Loading...";

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
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
          _userName = snap.data()?['name'] ?? 'Student';
        });
      }
    }
  }

  Future<void> _logout() async {
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

    return Scaffold(
      bottomNavigationBar: const _BottomNav(),
      body: NestedScrollView(
        headerSliverBuilder: (context, inner) => [
          SliverAppBar(
            pinned: true,
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
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),

            actionsIconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
              PopupMenuButton<String>(
                icon: const Icon(Icons.settings_outlined),
                onSelected: (value) {
                  if (value == 'logout') _logout();
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
                        colors: [Color(0xFF17B1A7), Color(0xFF11A0C8)],
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
                            children: [
                              const CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.white,
                                child: Icon(Icons.person, size: 28, color: Colors.black54),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: _WelcomeBlock(name: _userName)),
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
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(shape: const StadiumBorder(), side: BorderSide(color: Colors.blue.shade300)),
                  child: const Text("Leave History"),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: const [
                Expanded(child: _StatCard(icon: Icons.wb_sunny_outlined, label: 'Half Day', value: '07')),
                SizedBox(width: 8),
                Expanded(child: _StatCard(icon: Icons.medical_services_outlined, label: 'Medical', value: '10')),
                SizedBox(width: 8),
                Expanded(child: _StatCard(icon: Icons.calendar_today_outlined, label: 'Full Day', value: '05')),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Your Past Leaves", style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w700)),
                TextButton(onPressed: () {}, child: const Text("See more ›")),
              ],
            ),

            const _LeaveCard(
              color: Color(0xFFE7F6FF),
              iconColor: Color(0xFF0EA5E9),
              title: 'Annual Leave',
              subtitle: '1 Jan 2023 - 1 Jan 2023 (1 day)',
              note: 'Personal Matter',
            ),
            const _LeaveCard(
              color: Color(0xFFE6FFF3),
              iconColor: Color(0xFF10B981),
              title: 'Medical Leave',
              subtitle: '22 Dec 2022 - 23 Dec 2022 (2 day)',
              note: 'Ear infection caused by a polluted swimming pool',
            ),
            const _LeaveCard(
              color: Color(0xFFFFF7E6),
              iconColor: Color(0xFFF59E0B),
              title: 'Medical Leave',
              subtitle: '16 Nov 2022 - 23 Nov 2023 (7 day)',
              note: 'Got COVID and need to be quarantined at least a week.',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(icon, color: Colors.black54, size: 20), const SizedBox(width: 6), Expanded(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)))]),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

class _LeaveCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String note;
  final Color color;
  final Color iconColor;

  const _LeaveCard({required this.title, required this.subtitle, required this.note, required this.color, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
          child: Icon(Icons.event_note_outlined, color: iconColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(subtitle),
            const SizedBox(height: 4),
            Text(note, style: const TextStyle(color: Colors.black54)),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: 0,
      onDestinationSelected: (i) {
        switch (i) {
          case 0:
            Navigator.pushReplacementNamed(context, StudentDashboardScreen.route);
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/apply-leave');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/history');
            break;
        }
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.add_circle_outline), selectedIcon: Icon(Icons.add_circle), label: 'Apply Leave'),
        NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history), label: 'History'),
      ],
    );
  }
}
