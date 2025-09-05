import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final _db = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> validateUser({
    required String rollNo,
    required String collegeName,
    required String email,
    required String password,
  }) async {
    try {
      final snapshot = await _db
          .collection("Colleges")
          .doc(collegeName) // 👈 match the college
          .collection("Users")
          .where("rollNo", isEqualTo: rollNo)
          .where("email", isEqualTo: email)
          .where("password", isEqualTo: password)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.data();
      } else {
        return null; // user not found
      }
    } catch (e) {
      print("❌ Firestore validation error: $e");
      return null;
    }
  }
}
