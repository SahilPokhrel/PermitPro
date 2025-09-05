import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'student_dashboard_screen.dart';

class StudentProfileScreen extends StatefulWidget {
  static const route = '/student-profile';
  final String collegeName;
  final String rollNo;

  const StudentProfileScreen({
    super.key,
    required this.collegeName,
    required this.rollNo,
  });

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _parentMobileCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  String? _department;
  String? _semester;
  String? _batch = '2022 - 26';

  File? _pickedImage;
  String? _uploadedUrl;

  final ImagePicker _picker = ImagePicker();

  // ✅ Departments (from screenshot)
  final List<String> _departments = [
    "Artificial Intelligence and Machine Learning",
    "Bachelor of Business Administration",
    "Bachelor of Computer Applications",
    "Bachelor of Hotel Management",
    "Bachelor of Pharmacy",
    "Computer Science and Engineering",
    "Data Science",
    "Electronics and Communication Engineering",
    "Information Science and Engineering",
    "Internet of Things",
    "Nursing",
  ];

  // ✅ Map Roman → semX
  final Map<String, String> _semesterMap = {
    "I": "sem1",
    "II": "sem2",
    "III": "sem3",
    "IV": "sem4",
    "V": "sem5",
    "VI": "sem6",
    "VII": "sem7",
    "VIII": "sem8",
  };

  @override
  void dispose() {
    _nameCtrl.dispose();
    _mobileCtrl.dispose();
    _parentMobileCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
      await _uploadToSupabase(File(picked.path));
    }
  }

  Future<void> _uploadToSupabase(File file) async {
    try {
      final supabase = Supabase.instance.client;
      final path = "${widget.rollNo}/profile.jpg";

      await supabase.storage
          .from("profile-photos")
          .upload(path, file, fileOptions: const FileOptions(upsert: true));

      final publicUrl = supabase.storage
          .from("profile-photos")
          .getPublicUrl(path);

      setState(() {
        _uploadedUrl = publicUrl;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("✅ Profile photo uploaded")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Upload failed: $e")));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final docRef = FirebaseFirestore.instance
          .collection("Colleges")
          .doc(widget.collegeName)
          .collection("Users")
          .doc(widget.rollNo);

      await docRef.set({
        "name": _nameCtrl.text.trim(),
        "mobile": _mobileCtrl.text.trim(),
        "parentMobile": _parentMobileCtrl.text.trim(),
        "address": _addressCtrl.text.trim(),
        "department": _department,
        "semester": _semesterMap[_semester] ?? "sem1",
        "batch": _batch,
        "profileImageUrl": _uploadedUrl,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Profile saved ✅")));

      Navigator.pushReplacementNamed(context, StudentDashboardScreen.route);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Save failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final divider = const SizedBox(height: 16);
    final labelStyle = TextStyle(
      color: Colors.grey.shade700,
      fontWeight: FontWeight.w600,
      fontSize: 13,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Avatar
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: const Color(0xFFE5E7EB),
                        backgroundImage: _pickedImage != null
                            ? FileImage(_pickedImage!)
                            : (_uploadedUrl != null
                                  ? NetworkImage(_uploadedUrl!)
                                  : null),
                        child: _pickedImage == null && _uploadedUrl == null
                            ? const Icon(
                                Icons.person,
                                size: 48,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Material(
                          color: Colors.blue,
                          elevation: 2,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: _pickImage,
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(
                                Icons.edit,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // Name
                Text('Name', style: labelStyle),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(hintText: 'Full Name'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter name' : null,
                ),
                divider,

                // Mobile
                Text('Mobile', style: labelStyle),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _mobileCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: '98490XXXXX',
                    suffixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (v) {
                    final s = v?.trim() ?? '';
                    if (s.isEmpty) return 'Enter mobile number';
                    if (s.length != 10) return 'Enter valid number';
                    return null;
                  },
                ),
                divider,

                // Department
                Text('Department', style: labelStyle),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _department,
                  items: _departments
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
                  onChanged: (v) => setState(() => _department = v),
                  decoration: const InputDecoration(
                    hintText: 'Select department',
                  ),
                  validator: (v) =>
                      v == null ? 'Please select department' : null,
                ),
                divider,

                // Semester + Batch
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Semester', style: labelStyle),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: _semester,
                            items: _semesterMap.keys
                                .map(
                                  (roman) => DropdownMenuItem(
                                    value: roman,
                                    child: Text(roman),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setState(() => _semester = v),
                            decoration: const InputDecoration(
                              hintText: 'Semester',
                            ),
                            validator: (v) =>
                                v == null ? 'Please select semester' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Batch', style: labelStyle),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: _batch,
                            items: const [
                              DropdownMenuItem(
                                value: '2021 - 25',
                                child: Text('2021 - 25'),
                              ),
                              DropdownMenuItem(
                                value: '2022 - 26',
                                child: Text('2022 - 26'),
                              ),
                              DropdownMenuItem(
                                value: '2023 - 27',
                                child: Text('2023 - 27'),
                              ),
                              DropdownMenuItem(
                                value: '2024 - 28',
                                child: Text('2024 - 28'),
                              ),
                              DropdownMenuItem(
                                value: '2025 - 29',
                                child: Text('2025 - 29'),
                              ),
                            ],
                            onChanged: (v) => setState(() => _batch = v),
                            decoration: const InputDecoration(
                              hintText: '20XX - XX',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                divider,

                // Parent's Mobile
                Text("Parent's Mobile", style: labelStyle),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _parentMobileCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: '98490XXXXX',
                    suffixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (v) {
                    final s = v?.trim() ?? '';
                    if (s.isEmpty) return 'Enter parent mobile number';
                    if (s.length != 10) return 'Enter valid number';
                    return null;
                  },
                ),
                divider,

                // Address
                Text('Address', style: labelStyle),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _addressCtrl,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Your address',
                    alignLabelWithHint: true,
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter address' : null,
                ),
                const SizedBox(height: 22),

                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _save,
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
