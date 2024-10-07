import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'hod_profile.dart'; // Make sure to import your HOD Profile page
import 'student_profile.dart'; // Make sure to import your Student Profile page

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures binding before Firebase initializes
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const PermitProApp());
}


class PermitProApp extends StatelessWidget {
  const PermitProApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PermitPro',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(), // Main home page with login options
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('PermitPro')),
        toolbarHeight: 70, // Optional: Adjust the height of the AppBar
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to PermitPro',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            // HOD Login Button
            SizedBox(
              width: 200, // Set a fixed width for consistent button size
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HODProfilePage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text('HOD Login'),
              ),
            ),
            const SizedBox(height: 20),
            // Student Login Button
            SizedBox(
              width: 200, // Set a fixed width for consistent button size
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StudentProfilePage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text('Student Login'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
