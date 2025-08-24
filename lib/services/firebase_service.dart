import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // อัปเดตข้อมูลโปรไฟล์ของผู้ใช้
  Future<void> updateUserProfile(String name, String email) async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "test_user";

    await _firestore.collection('users').doc(userId).set({
      'name': name,
      'email': email,
    }, SetOptions(merge: true)); // ใช้ merge เพื่อไม่ลบข้อมูลเก่า
  }

  // ดึงข้อมูลโปรไฟล์จาก Firestore
  Future<Map<String, dynamic>?> getUserProfile() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "test_user";
    DocumentSnapshot doc =
        await _firestore.collection('users').doc(userId).get();

    return doc.exists ? doc.data() as Map<String, dynamic> : null;
  }
}
