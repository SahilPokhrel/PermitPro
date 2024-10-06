import 'dart:io';
import 'package:flutter/material.dart';

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
            const SizedBox(height: 20), // Space before the buttons

            const Spacer(),

            // Requests and Status Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      // Navigate to the Requests page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RequestsPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Requests',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 10), // Space between buttons
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      // Navigate to the Status page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StatusPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Status',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// Placeholder pages for Requests and Status
class RequestsPage extends StatelessWidget {
  const RequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Requests'),
      ),
      body: const Center(
        child: Text('Requests Page'),
      ),
    );
  }
}

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

// Assume that this is your student_profile.dart file
class StudentProfilePage extends StatelessWidget {
  final String name;
  final String phoneNo;
  final String selectedCourse;
  final String selectedBranch;
  final String selectedSemester;
  final String imagePath;

  const StudentProfilePage({
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
        title: const Text('Edit Profile'),
      ),
      body: Center(
        child: Text('Editing Profile: $name'), // Example text
      ),
    );
  }
}
