import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // Import the dart:io package for File


class HodProfilePage extends StatefulWidget {
  @override
  _HodPfPageState createState() => _HodPfPageState();
}

class _HodPfPageState extends State<HodProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _hodIdController = TextEditingController();
  String _selectedCourse = 'Engineering';
  String _selectedBranch = '';
  String? _imagePath; // To store the image path

  final List<String> courses = ['Engineering', 'Management'];
  final Map<String, List<String>> branches = {
    'Engineering': ['CSE', 'ISE', 'ECE', 'AIML', 'IOT', 'Data Science'],
    'Management': ['BBA', 'BCA', 'BHM', 'B.COM', 'MBA', 'MCA'],
  };

  // Pick image from gallery
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  // Function to handle profile creation
  void _createProfile() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Profile created successfully!'),
      ));

      // Clear fields after creation
      _hodIdController.clear();
      setState(() {
        _selectedCourse = 'Engineering';
        _selectedBranch = '';
        _imagePath = null; // Clear the selected image
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('HOD Profile Creation', style: TextStyle(color: Colors.white)),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Profile Picture Section (Top Center)
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _imagePath != null
                          ? FileImage(File(_imagePath!))
                          : AssetImage('assets/placeholder.png') as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        icon: Icon(Icons.camera_alt),
                        onPressed: _pickImage,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),

              // HOD ID Field
              TextFormField(
                controller: _hodIdController,
                decoration: InputDecoration(
                  labelText: 'HOD ID',
                  prefixIcon: Icon(Icons.card_membership, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your HOD ID';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),

              // Course Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCourse,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCourse = newValue!;
                    _selectedBranch = ''; // Reset branch when course changes
                  });
                },
                items: courses
                    .map((course) => DropdownMenuItem<String>(
                  value: course,
                  child: Text(course),
                ))
                    .toList(),
                decoration: InputDecoration(
                  labelText: 'Course',
                  prefixIcon: Icon(Icons.book, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 15),

              // Branch Dropdown
              DropdownButtonFormField<String>(
                value: _selectedBranch.isEmpty ? null : _selectedBranch,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedBranch = newValue!;
                  });
                },
                items: _selectedCourse.isNotEmpty
                    ? branches[_selectedCourse]!.map((branch) => DropdownMenuItem<String>(
                  value: branch,
                  child: Text(branch),
                )).toList()
                    : [],
                decoration: InputDecoration(
                  labelText: 'Branch',
                  prefixIcon: Icon(Icons.business, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 30),

              // Create Profile Button
              ElevatedButton(
                onPressed: _createProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('Create Profile', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
