import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseParkingService {
  final CollectionReference spotsCollection = FirebaseFirestore.instance
      .collection('parking_spots');

  /// ดึงที่จอดว่างที่สามารถใช้งานได้
  Future<DocumentSnapshot?> getRecommendedSpot() async {
    final query =
    await spotsCollection.where('status', isEqualTo: 'available').get();

    if (query.docs.isNotEmpty) {
      // sort โดยใช้ doc['id'] ถ้ามี หรือใช้ docId เองก็ได้
      query.docs.sort((a, b) {
        final idA = int.tryParse(a['id'].toString()) ?? 999;
        final idB = int.tryParse(b['id'].toString()) ?? 999;
        return idA.compareTo(idB);
      });

      return query.docs.first;
    }
    return null;
  }


  /// อัปเดตช่องจอดเป็น occupied พร้อมบันทึกเวลาเริ่มต้น
  Future<void> occupySpot(String docId) async {
    await spotsCollection.doc(docId).update({
      'status': 'occupied',
      'start_time': FieldValue.serverTimestamp(),
    });
  }

  /// อัปเดตช่องจอดเป็น available และรีเซ็ตเวลา
  Future<void> releaseSpot(String docId) async {
    await spotsCollection.doc(docId).update({
      'status': 'available',
      'start_time': null,
      'duration_minutes': 0,
    });
  }

  /// อัปเดตสถานะเป็น unavailable
  Future<void> markSpotUnavailable(String docId) async {
    await spotsCollection.doc(docId).update({
      'status': 'unavailable',
      'start_time': null,
      'duration_minutes': 0,
    });
  }

  /// คำนวณเวลาใช้งานจาก start_time และบันทึกลง duration_minutes
  Future<void> updateDuration(String docId) async {
    final doc = await spotsCollection.doc(docId).get();
    final data = doc.data() as Map<String, dynamic>;

    if (data['start_time'] != null && data['status'] == 'occupied') {
      Timestamp start = data['start_time'];
      final now = DateTime.now();
      final diff = now.difference(start.toDate());
      final minutes = diff.inMinutes;

      await spotsCollection.doc(docId).update({'duration_minutes': minutes});
    }
  }

  /// ดึงข้อมูลช่องจอดทั้งหมด
  Future<List<Map<String, dynamic>>> getAllSpots() async {
    final query = await spotsCollection.orderBy('id').get();
    return query.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['docId'] = doc.id;
      return data;
    }).toList();
  }
}
