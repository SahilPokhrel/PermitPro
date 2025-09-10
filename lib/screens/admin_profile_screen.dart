// lib/screens/admin_profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'admin_dashboard_screen.dart';

class AdminProfileScreen extends StatefulWidget {
  static const route = '/admin-profile';
  final String collegeName;
  final String rollNo;

  const AdminProfileScreen({
    super.key,
    required this.collegeName,
    required this.rollNo,
  });

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();

  File? _pickedImage;
  String? _uploadedUrl;
  final ImagePicker _picker = ImagePicker();

  String? _department;
  String? _semester;

  // ✅ Departments
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
      final path = "${widget.rollNo}/admin_profile.jpg";

      await supabase.storage
          .from("profile-photos")
          .upload(path, file, fileOptions: const FileOptions(upsert: true));

      final publicUrl = supabase.storage
          .from("profile-photos")
          .getPublicUrl(path);

      setState(() => _uploadedUrl = publicUrl);

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
        "department": _department,
        "semester": _semesterMap[_semester] ?? "sem1",
        "profileImageUrl": _uploadedUrl,
        "isProfileEdited": true,
      }, SetOptions(merge: true));

      // save session defensively
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('collegeName', widget.collegeName);
      await prefs.setString('rollNo', widget.rollNo);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Profile saved ✅")));

      Navigator.pushNamedAndRemoveUntil(
        context,
        AdminDashboardScreen.route,
        (route) => false,
        arguments: {"collegeName": widget.collegeName, "rollNo": widget.rollNo},
      );
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
      appBar: AppBar(title: const Text('Admin Profile'), centerTitle: true),
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

                // Department dropdown
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

                // Semester dropdown
                Text('Semester', style: labelStyle),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _semester,
                  items: _semesterMap.keys
                      .map(
                        (roman) =>
                            DropdownMenuItem(value: roman, child: Text(roman)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _semester = v),
                  decoration: const InputDecoration(
                    hintText: 'Select semester',
                  ),
                  validator: (v) => v == null ? 'Please select semester' : null,
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
