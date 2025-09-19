import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'student_dashboard_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'student_history_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApplyLeaveScreen extends StatefulWidget {
  static const route = '/apply-leave';
  const ApplyLeaveScreen({super.key});

  @override
  State<ApplyLeaveScreen> createState() => _ApplyLeaveScreenState();
}

class _ApplyLeaveScreenState extends State<ApplyLeaveScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedType;
  DateTime? _fromDate;
  DateTime? _toDate;
  TimeOfDay? _halfDayTime;
  final _reasonController = TextEditingController();
  final List<PlatformFile> _selectedFiles = [];

  // Controllers for date/time display
  final _fromDateController = TextEditingController();
  final _toDateController = TextEditingController();
  final _timeController = TextEditingController();

  final leaveTypes = ['Medical Leave', 'Half Day', 'Full Day'];

  bool _submitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    _fromDateController.dispose();
    _toDateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _pickFromDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      setState(() {
        _fromDate = picked;
        _fromDateController.text = _fromDate!.toLocal().toString().split(
          ' ',
        )[0];
        if (_toDate != null && _toDate!.isBefore(_fromDate!)) {
          _toDate = null;
          _toDateController.clear();
        }
      });
    }
  }

  Future<void> _pickToDate() async {
    if (_fromDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Select From Date first")));
      return;
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: _toDate ?? _fromDate!,
      firstDate: _fromDate!,
      lastDate: DateTime(_fromDate!.year + 1),
    );
    if (picked != null) {
      setState(() {
        _toDate = picked;
        _toDateController.text = _toDate!.toLocal().toString().split(' ')[0];
      });
    }
  }

  Future<void> _pickHalfDayTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: _halfDayTime ?? now,
    );
    if (picked != null) {
      if (_fromDate != null) {
        final today = DateTime.now();
        if (_fromDate!.year == today.year &&
            _fromDate!.month == today.month &&
            _fromDate!.day == today.day) {
          if (picked.hour < now.hour ||
              (picked.hour == now.hour && picked.minute < now.minute)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Select a time after the current time"),
              ),
            );
            return;
          }
        }
      }
      setState(() {
        _halfDayTime = picked;
        _timeController.text = _halfDayTime!.format(context);
      });
    }
  }

  Future<void> _uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
      withData: true,
    );
    if (result != null) {
      setState(() {
        _selectedFiles.addAll(result.files);
      });
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  Future<void> _showSuccessDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  builder: (context, val, child) {
                    return Transform.scale(scale: val, child: child);
                  },
                  child: const Icon(
                    Icons.check_circle,
                    size: 96,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Leave Requested Successfully!",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedType == "Medical Leave" && _selectedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Upload file is mandatory for Medical Leave"),
        ),
      );
      return;
    }

    if (_fromDate == null || _toDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select from and to dates")),
      );
      return;
    }

    if (_selectedType == "Half Day" && _halfDayTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select timing for half day leave"),
        ),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      // ✅ Fetch session
      final prefs = await SharedPreferences.getInstance();
      final rollNo = prefs.getString('rollNo');
      final collegeName = prefs.getString('collegeName');

      if (rollNo == null || collegeName == null) {
        throw Exception("Session expired. Please log in again.");
      }

      // ✅ Fetch user profile (must have department + semester)
      final userDoc = await FirebaseFirestore.instance
          .collection("Colleges")
          .doc(collegeName)
          .collection("Users")
          .doc(rollNo)
          .get();

      if (!userDoc.exists) throw Exception("User profile not found");

      final departmentName = userDoc["department"];
      final semester = userDoc["semester"];

      if (departmentName == null || semester == null) {
        throw Exception("Department or semester missing in user profile");
      }

      // ✅ Upload files to Supabase
      final supabase = Supabase.instance.client;
      List<String> uploadedFilePaths = [];

      for (final file in _selectedFiles) {
        final remotePath = "$rollNo/${file.name}";
        Uint8List? bytes = file.bytes;

        if (bytes != null) {
          await supabase.storage
              .from('leave-docs')
              .uploadBinary(
                remotePath,
                bytes,
                fileOptions: const FileOptions(upsert: true),
              );
        } else if (file.path != null) {
          final fileBytes = await File(file.path!).readAsBytes();
          await supabase.storage
              .from('leave-docs')
              .uploadBinary(
                remotePath,
                fileBytes,
                fileOptions: const FileOptions(upsert: true),
              );
        }

        uploadedFilePaths.add(remotePath);
      }

      // ✅ Firestore path for leave request
      final firestore = FirebaseFirestore.instance;
      final requestRef = firestore
          .collection("Colleges")
          .doc(collegeName)
          .collection("Departments")
          .doc(departmentName)
          .collection("Semesters")
          .doc(semester)
          .collection("Requests")
          .doc(rollNo)
          .collection("leave_requests")
          .doc();

      // ✅ Store all required fields (no more mismatches)
      await requestRef.set({
        "type": _selectedType,
        "fromDate": Timestamp.fromDate(_fromDate!),
        "toDate": Timestamp.fromDate(_toDate!),
        "halfDayTime": _halfDayTime?.format(context),
        "reason": _reasonController.text.trim(),
        "files": uploadedFilePaths,
        "timestamp": FieldValue.serverTimestamp(),
        "status": "pending",
        "collegeName": collegeName,
        "department": departmentName,
        "semester": semester,
        "studentId": rollNo,
      });

      await _showSuccessDialog();
      Navigator.pushReplacementNamed(context, StudentDashboardScreen.route);
    } catch (e, st) {
      debugPrint("Submit error: $e\n$st");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error submitting leave: $e")));
    } finally {
      setState(() => _submitting = false);
    }
  }

  void _goBack() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      StudentDashboardScreen.route,
      (route) => false, // remove all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (i) async {
          switch (i) {
            case 0:
              Navigator.pushReplacementNamed(
                context,
                StudentDashboardScreen.route,
              );
              break;
            case 1:
              break;
            case 2:
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
                  final data = snap.data()!;
                  final department = data['department'];
                  final semester = data['semester'];

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StudentHistoryScreen(
                        collegeName: collegeName,
                        department: department,
                        semester: semester,
                        rollNo: rollNo,
                      ),
                    ),
                  );
                  return;
                }
              }

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Student details not found")),
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

      body: Column(
        children: [
          // 🔹 Top Header
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
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      items: leaveTypes
                          .map(
                            (t) => DropdownMenuItem(value: t, child: Text(t)),
                          )
                          .toList(),
                      onChanged: (val) => setState(() {
                        _selectedType = val;
                        if (_selectedType != "Half Day") {
                          _halfDayTime = null;
                          _timeController.clear();
                        }
                      }),
                      validator: (val) =>
                          val == null ? 'Please choose leave type' : null,
                      decoration: const InputDecoration(
                        labelText: 'Leave Type',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _fromDateController,
                      readOnly: true,
                      onTap: _pickFromDate,
                      decoration: const InputDecoration(
                        labelText: 'From Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      validator: (_) =>
                          _fromDate == null ? 'Please select from date' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _toDateController,
                      readOnly: true,
                      onTap: _pickToDate,
                      decoration: const InputDecoration(
                        labelText: 'To Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      validator: (_) =>
                          _toDate == null ? 'Please select to date' : null,
                    ),
                    const SizedBox(height: 16),

                    if (_selectedType == "Half Day")
                      TextFormField(
                        controller: _timeController,
                        readOnly: true,
                        onTap: _pickHalfDayTime,
                        decoration: const InputDecoration(
                          labelText: 'Select Time',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.access_time_outlined),
                        ),
                        validator: (_) =>
                            _halfDayTime == null ? 'Please select time' : null,
                      ),
                    if (_selectedType == "Half Day") const SizedBox(height: 16),

                    TextFormField(
                      controller: _reasonController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Reason',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Enter a reason' : null,
                    ),
                    const SizedBox(height: 16),

                    // File upload with remove option
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_selectedFiles.isEmpty)
                          const Text(
                            'No files chosen',
                            style: TextStyle(color: Colors.grey),
                          )
                        else
                          Column(
                            children: _selectedFiles.asMap().entries.map((
                              entry,
                            ) {
                              final index = entry.key;
                              final file = entry.value;
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      file.name,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _removeFile(index),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _uploadFile,
                          child: const Text("Upload"),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitting ? null : _submit,
                        child: _submitting
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Apply Leave'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
