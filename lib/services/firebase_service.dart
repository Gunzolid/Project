import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // อัปเดตข้อมูลโปรไฟล์ของผู้ใช้
  Future<void> updateUserProfile(String uid, String name) async {
    print(">>> Updating profile for UID: $uid");
    print(">>> New name to save: $name"); // ดูว่าค่า name ถูกต้องไหม
    try {
      await _firestore.collection('users').doc(uid).update({'name': name});
      print(">>> Successfully updated 'name' field.");
    } catch (e) {
      print(">>> Error updating profile: $e");
    }
  }

  // ดึงข้อมูลโปรไฟล์จาก Firestore
  Future<Map<String, dynamic>?> getUserProfile() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "test_user";
    DocumentSnapshot doc =
        await _firestore.collection('users').doc(userId).get();

    return doc.exists ? doc.data() as Map<String, dynamic> : null;
  }

  Future<void> deleteUserData(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
      print("User data deleted from Firestore for UID: $uid");
    } catch (e) {
      print("Error deleting user data from Firestore: $e");
      // อาจจะ rethrow หรือจัดการ error ตามความเหมาะสม
      rethrow;
    }
  }
}
