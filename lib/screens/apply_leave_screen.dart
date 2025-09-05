import 'package:flutter/material.dart';
import 'student_dashboard_screen.dart';

class ApplyLeaveScreen extends StatefulWidget {
  static const route = '/apply-leave';
  const ApplyLeaveScreen({super.key});

  @override
  State<ApplyLeaveScreen> createState() => _ApplyLeaveScreenState();
}

class _ApplyLeaveScreenState extends State<ApplyLeaveScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedType;
  DateTimeRange? _dateRange;
  final _reasonController = TextEditingController();
  String? _uploadedFile;

  final leaveTypes = ['Annual Leave', 'Medical Leave', 'Half Day', 'Full Day'];

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year, now.month - 3),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) setState(() => _dateRange = picked);
  }

  void _uploadFile() async {
    // TODO: implement file picker + backend upload
    setState(() => _uploadedFile = "medical_certificate.pdf");
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _dateRange != null) {
      // TODO: Send to backend
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Leave application submitted!')),
      );
      Navigator.pushReplacementNamed(context, StudentDashboardScreen.route);
    }
  }

  void _goBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, StudentDashboardScreen.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🔹 Bottom navigation (Apply tab selected)
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1, // Home=0, Apply=1, History=2
        onDestinationSelected: (i) {
          switch (i) {
            case 0:
              Navigator.pushReplacementNamed(
                context,
                StudentDashboardScreen.route,
              );
              break;
            case 1:
              // already here
              break;
            case 2:
              // TODO: implement History route
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('History screen coming soon')),
              );
              break;
          }
        },
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

      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Top Header with Back Arrow
            Container(
              height: 90,
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _goBack,
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Apply Leave",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 Form body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        "Leave Application Form",
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),

                      // Leave type dropdown
                      DropdownButtonFormField<String>(
                        initialValue: _selectedType,
                        items: leaveTypes
                            .map(
                              (t) => DropdownMenuItem(value: t, child: Text(t)),
                            )
                            .toList(),
                        onChanged: (val) => setState(() => _selectedType = val),
                        validator: (val) =>
                            val == null ? 'Please choose leave type' : null,
                        decoration: const InputDecoration(
                          labelText: 'Leave Type',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Date range picker
                      TextFormField(
                        readOnly: true,
                        onTap: _pickDateRange,
                        decoration: InputDecoration(
                          labelText: 'Select Date',
                          border: const OutlineInputBorder(),
                          suffixIcon: const Icon(Icons.calendar_today_outlined),
                          hintText: _dateRange == null
                              ? 'Select leave date...'
                              : '${_dateRange!.start.toLocal()} → ${_dateRange!.end.toLocal()}',
                        ),
                        validator: (_) => _dateRange == null
                            ? 'Please select a date range'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Reason
                      TextFormField(
                        controller: _reasonController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Reason',
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) => val == null || val.isEmpty
                            ? 'Enter a reason'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // File upload
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _uploadedFile ?? 'No file chosen',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _uploadFile,
                            child: const Text("Upload"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Submit
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submit,
                          child: const Text('Apply Leave'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
