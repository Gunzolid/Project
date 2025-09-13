// lib/services/firebase_parking_service.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseParkingService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  FirebaseParkingService({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// เลือก candidate (เปลี่ยนเป็น logic จริง เช่น orderBy('path_order'))
  Future<int?> _pickCandidateId() async {
    final qs = await _db
        .collection('parking_spots')
        .where('status', isEqualTo: 'available')
        .orderBy('id')
        .limit(1)
        .get();

    if (qs.docs.isEmpty) return null;
    final data = qs.docs.first.data() as Map<String, dynamic>;
    final id = data['id'];
    if (id is int) return id;
    if (id is num) return id.toInt();
    return null;
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
