// lib/services/firebase_parking_service.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const List<int> kSpotOrder = [
  // ขอบด้าน บน
  1, 2, 3, 27, 28, 29,
  // ขอบด้าน ซ้าย
  4, 5, 30, 31, 6, 7, 8, 32, 33, 34, 9, 10, 11, 35, 36, 37, 12, 13, 38, 39,
  // ขอบด้าน ล่าง
  40, 41, 42, 14, 15, 16,
  // ขอบด้าน ขวา
  17, 18, 43, 44, 19, 20, 21, 45, 46, 47, 22, 23, 24, 48, 49, 50, 25, 26, 51, 52,
];
class FirebaseParkingService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  FirebaseParkingService({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;



  /// เลือก candidate (เปลี่ยนเป็น logic จริง เช่น orderBy('path_order'))
  Future<int?> _pickCandidateId() async {
  // ดึงเฉพาะช่องที่ว่าง จากนั้น sort ตาม kSpotOrder ในฝั่งแอป
  final qs = await _db
      .collection('parking_spots')
      .where('status', isEqualTo: 'available')
      .get();

  if (qs.docs.isEmpty) return null;

  // แปลงเป็นเซ็ตของ id ที่ว่าง
  final availableIds = qs.docs
      .map((d) => (d.data()['id'] as num).toInt())
      .toSet();

  // เดินตามลำดับที่กำหนดไว้ แล้วเลือกตัวแรกที่ว่าง
  for (final id in kSpotOrder) {
    if (availableIds.contains(id)) return id;
  }
  // เผื่อกรณีมี id ใหม่ที่ไม่อยู่ในลิสต์ ให้ตกลงมาเลือกตัวแรกๆ
  return availableIds.isNotEmpty ? availableIds.first : null;
}

  /// จองชั่วคราว (ดีฟอลต์ 15 นาที = 900 วินาที)
  Future<int?> recommendAndHoldClient({int holdSeconds = 900}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('ต้องล็อกอินก่อน');

    final candidateId = await _pickCandidateId();
    if (candidateId == null) return null;

    final ref = _db.collection('parking_spots').doc('$candidateId');

    return _db.runTransaction<int?>((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return null;
      final data = snap.data() as Map<String, dynamic>;

      final String status = (data['status'] ?? 'available') as String;
      final Timestamp? holdExp = data['hold_expires_at'] as Timestamp?;
      final now = DateTime.now();

      final bool notExpired =
          holdExp != null && holdExp.toDate().isAfter(now);
      if (status != 'available' || notExpired) return null;

      tx.update(ref, {
        'status': 'held',
        'hold_by': uid,
        'hold_expires_at':
            Timestamp.fromDate(now.add(Duration(seconds: holdSeconds))),
        'last_updated': FieldValue.serverTimestamp(),
      });

      final idVal = data['id'];
      return (idVal is num) ? idVal.toInt() : null;
    });
  }

  /// ฟังสถานะช่องที่ถูกจอง: ถ้าหมดเวลา/ถูกเปลี่ยน → expired
  Stream<RecommendationState> watchRecommendation(int spotId) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return Stream<RecommendationState>.value(
        RecommendationState.expired('ไม่ได้ล็อกอิน'),
      );
    }

    final ref = _db.collection('parking_spots').doc('$spotId');
    return ref.snapshots().map((snap) {
      if (!snap.exists) {
        return RecommendationState.expired('ข้อมูลช่องถูกลบ');
      }
      final data = snap.data() as Map<String, dynamic>?;
      if (data == null) {
        return RecommendationState.expired('ไม่มีข้อมูลช่อง');
      }

      final String status = (data['status'] ?? 'available') as String;
      final String? holdBy = data['hold_by'] as String?;
      final Timestamp? holdExp = data['hold_expires_at'] as Timestamp?;
      final now = DateTime.now();

      if (status != 'held' || holdBy != uid) {
        return RecommendationState.expired('ช่องถูกเปลี่ยนสถานะ');
      }

      if (holdExp != null && holdExp.toDate().isBefore(now)) {
        return RecommendationState.expired('หมดเวลา 15 นาทีแล้ว');
      }

      return RecommendationState.active(expiresAt: holdExp?.toDate());
    });
  }

  /// เช็คอิน (held -> occupied)
  Future<void> checkIn(int spotId) async {
    final ref = _db.collection('parking_spots').doc('$spotId');
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return;
      final data = snap.data() as Map<String, dynamic>;
      if (data['status'] != 'held') return;

      tx.update(ref, {
        'status': 'occupied',
        'start_time': FieldValue.serverTimestamp(),
        'last_updated': FieldValue.serverTimestamp(),
      });
    });
  }

  /// เคลียร์ hold ถ้าหมดเวลาแล้ว
  Future<void> clearIfExpired(int spotId) async {
    final ref = _db.collection('parking_spots').doc('$spotId');
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return;
      final data = snap.data() as Map<String, dynamic>;
      if (data['status'] != 'held') return;

      final Timestamp? holdExp = data['hold_expires_at'] as Timestamp?;
      final now = DateTime.now();
      if (holdExp != null && holdExp.toDate().isAfter(now)) return;

      tx.update(ref, {
        'status': 'available',
        'hold_by': null,
        'hold_expires_at': null,
        'start_time': null,
        'last_updated': FieldValue.serverTimestamp(),
      });
    });
  }

    /// Admin เปลี่ยนสถานะช่อง (ใช้ docId ซึ่งเป็น String)
  Future<void> setStatus(String docId, String newStatus) async {
    final ref = _db.collection('parking_spots').doc(docId);

    await ref.update({
      'status': newStatus,
      'last_updated': FieldValue.serverTimestamp(),
      if (newStatus == 'available') ...{
        'hold_by': null,
        'hold_expires_at': null,
        'start_time': null,
      }
    });
  }
}

/// ใช้บอกสถานะ recommendation
class RecommendationState {
  final bool isActive;
  final DateTime? expiresAt;
  final String? reason;

  const RecommendationState._(this.isActive, this.expiresAt, this.reason);

  factory RecommendationState.active({DateTime? expiresAt}) =>
      RecommendationState._(true, expiresAt, null);

  factory RecommendationState.expired(String? reason) =>
      RecommendationState._(false, null, reason);
}
