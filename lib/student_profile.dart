import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'students_home_page.dart'; // Import the home page
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore

class StudentProfilePage extends StatefulWidget {
  const StudentProfilePage({super.key});

  @override
  _StudentProfilePageState createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String phoneNo = '';
  String selectedCourse = '';
  String selectedBranch = '';
  String selectedSemester = '';
  XFile? _imageFile;

  final Map<String, List<String>> branches = {
    'Engineering': [
      'Computer Science',
      'Information Science',
      'Artificial Intelligence',
      'ECE',
      'Civil Engineering',
      'Mechanical Engineering',
      'Data Science',
    ],
    'BBA': ['Business Management', 'Finance', 'Marketing'],
    'BCA': ['Computer Applications', 'Software Development'],
    'BHM': ['Hotel Management', 'Catering', 'Tourism'],
    'Nursing': ['General Nursing', 'Midwifery'],
    'B Pharma': ['Pharmacy', 'Clinical Pharmacy'],
  };

  final Map<String, List<String>> semesters = {
    'Engineering': ['1', '2', '3', '4', '5', '6', '7', '8'],
    'BBA': ['1', '2', '3', '4', '5', '6'],
    'BCA': ['1', '2', '3', '4', '5', '6'],
    'BHM': ['1', '2', '3', '4', '5', '6'],
    'Nursing': ['1', '2', '3', '4', '5', '6', '7', '8'],
    'B Pharma': ['1', '2', '3', '4', '5', '6'],
  };

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source != null) {
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _imageFile = image;
        });
      }
    }
  }

  Future<void> saveProfileToFirestore() async {
    try {
      String imagePath = _imageFile != null ? _imageFile!.path : '';

      await FirebaseFirestore.instance.collection('student_profiles').add({
        'name': name,
        'phoneNo': phoneNo,
        'selectedCourse': selectedCourse,
        'selectedBranch': selectedBranch,
        'selectedSemester': selectedSemester,
        'imagePath': imagePath,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> courseBranches = branches[selectedCourse] ?? [];
    List<String> courseSemesters = semesters[selectedCourse] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Student Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _imageFile != null
                          ? FileImage(File(_imageFile!.path))
                          : null,
                      backgroundColor: Colors.grey[300],
                      child: _imageFile == null
                          ? const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.white,
                      )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.teal,
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildTextField(
                        label: 'Name',
                        hintText: 'Enter your name',
                        onChanged: (value) => name = value,
                      ),
                      _buildTextField(
                        label: 'Phone No.',
                        hintText: 'Enter your phone number',
                        keyboardType: TextInputType.phone,
                        onChanged: (value) => phoneNo = value,
                      ),
                      _buildDropdown(
                        label: 'Course',
                        value: selectedCourse.isEmpty ? null : selectedCourse,
                        items: branches.keys.toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCourse = value!;
                            selectedBranch = '';
                            selectedSemester = '';
                          });
                        },
                      ),
                      if (courseBranches.isNotEmpty)
                        _buildDropdown(
                          label: 'Branch',
                          value: selectedBranch.isEmpty ? null : selectedBranch,
                          items: courseBranches,
                          onChanged: (value) {
                            setState(() {
                              selectedBranch = value!;
                            });
                          },
                        ),
                      if (courseSemesters.isNotEmpty)
                        _buildDropdown(
                          label: 'Semester',
                          value: selectedSemester.isEmpty
                              ? null
                              : selectedSemester,
                          items: courseSemesters,
                          onChanged: (value) {
                            setState(() {
                              selectedSemester = value!;
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await saveProfileToFirestore();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile Created!')),
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) {
                          return StudentsHomePage(
                            name: name,
                            phoneNo: phoneNo,
                            selectedCourse: selectedCourse,
                            selectedBranch: selectedBranch,
                            selectedSemester: selectedSemester,
                            imagePath: _imageFile != null
                                ? _imageFile!.path
                                : '', // Pass the image path to the home page
                          );
                        }),
                      );
                    }
                  },
                  child: const Text(
                    'Create Profile',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    required Function(String) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding:
          const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        keyboardType: keyboardType,
        onChanged: onChanged,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          } else if (label == 'Phone No.' &&
              !RegExp(r'^\d{10}$').hasMatch(value)) {
            return 'Please enter a valid 10-digit phone number';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding:
          const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        value: value,
        items: items
            .map((item) => DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        ))
            .toList(),
        onChanged: onChanged,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select $label';
          }
          return null;
        },
      ),
    );
  }
}
