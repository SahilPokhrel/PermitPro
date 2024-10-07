import 'dart:io';
import 'package:flutter/material.dart';
import 'requests_page.dart';

class StudentsHomePage extends StatelessWidget {
  final String name;
  final String phoneNo;
  final String selectedCourse;
  final String selectedBranch;
  final String selectedSemester;
  final String imagePath;

  const StudentsHomePage({
    super.key,
    required this.name,
    required this.phoneNo,
    required this.selectedCourse,
    required this.selectedBranch,
    required this.selectedSemester,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Home Page'),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: FileImage(File(imagePath)),
                backgroundColor: Colors.grey[300],
                child: imagePath.isEmpty
                    ? const Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.white,
                )
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Name: $name',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Phone No: $phoneNo',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Course: $selectedCourse',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Branch: $selectedBranch',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Semester: $selectedSemester',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Requests and Status Buttons
            const SizedBox(height: 20), // Space before the buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavButton(context, 'Requests', RequestsPage()),
                const SizedBox(width: 10),
                _buildNavButton(context, 'Status', StatusPage()),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, String title, Widget page) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        child: Text(
          title,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

// Placeholder pages for Requests and Status
class StatusPage extends StatelessWidget {
  const StatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Status'),
      ),
      body: const Center(
        child: Text('Status Page'),
      ),
    );
  }
}

// New Request Form Page
class RequestFormPage extends StatefulWidget {
  const RequestFormPage({super.key});

  @override
  _RequestFormPageState createState() => _RequestFormPageState();
}

class _RequestFormPageState extends State<RequestFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usnController = TextEditingController();
  final TextEditingController rollNoController = TextEditingController();
  String? selectedLeaveType;
  final TextEditingController reasonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Leave'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: usnController,
                decoration: const InputDecoration(labelText: 'USN'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your USN';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: rollNoController,
                decoration: const InputDecoration(labelText: 'Roll No'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Roll No';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: selectedLeaveType,
                decoration: const InputDecoration(labelText: 'Leave Type'),
                items: <String>['Full Day', 'Part Day', 'On Job']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedLeaveType = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a leave type';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: reasonController,
                decoration: const InputDecoration(labelText: 'Reason'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please provide a reason';
                  }
                  return null;
                },
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Process the leave request
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Processing Leave Request')),
                    );
                    // Here you can add the code to save the request
                  }
                },
                child: const Text('Submit Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
