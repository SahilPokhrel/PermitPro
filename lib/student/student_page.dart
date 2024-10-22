import 'package:flutter/material.dart';
import 'dart:io';
import 'status_page.dart'; // Adjust the path according to your project structure
import '';

class StudentPage extends StatelessWidget {
  final String usn;
  final String course;
  final String branch;
  final String semester;
  final File? profileImage;

  StudentPage({
    required this.usn,
    required this.course,
    required this.branch,
    required this.semester,
    this.profileImage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Profile'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Picture
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[200],
              backgroundImage: profileImage != null ? FileImage(profileImage!) : null,
              child: profileImage == null
                  ? Icon(Icons.person, size: 60, color: Colors.grey)
                  : null,
            ),
            SizedBox(height: 20),

            // USN
            InfoCard(label: 'USN', value: usn),
            SizedBox(height: 10),

            // Course
            InfoCard(label: 'Course', value: course),
            SizedBox(height: 10),

            // Branch
            InfoCard(label: 'Branch', value: branch),
            SizedBox(height: 10),

            // Semester
            InfoCard(label: 'Semester', value: semester),
            SizedBox(height: 30),

            // Action Buttons
            ElevatedButton(
              onPressed: () {
                // Navigate to leave request page or any other action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 5,
                minimumSize: Size(double.infinity, 50), // Full-width button
              ),
              child: Text(
                'Request Leave',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                // Navigate to status page or any other action
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StatusPage()), // Adjust the StatusPage as needed
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 5,
                minimumSize: Size(double.infinity, 50), // Full-width button
              ),
              child: Text(
                'Check Status',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                // Handle logout or navigate back to the profile creation
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PermitProApp()), // Adjust the StatusPage as needed
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 5,
                minimumSize: Size(double.infinity, 50), // Full-width button
              ),
              child: Text(
                'Log Out',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String label;
  final String value;

  const InfoCard({Key? key, required this.label, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(value, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
