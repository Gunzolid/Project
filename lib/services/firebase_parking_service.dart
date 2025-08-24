import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mtproject/data/layout_xy.dart';
import 'package:mtproject/data/path_order.dart';

class FirebaseParkingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get spotsCollection => _db.collection('parking_spots');

  /// ดึงที่จอดว่าง (client-side) — ใช้ชั่วคราวช่วง dev
  Future<DocumentSnapshot?> getRecommendedSpot() async {
    final query =
        await spotsCollection.where('status', isEqualTo: 'available').get();

    if (query.docs.isNotEmpty) {
      query.docs.sort((a, b) {
        final idA = int.tryParse(a['id']?.toString() ?? '') ?? 999999;
        final idB = int.tryParse(b['id']?.toString() ?? '') ?? 999999;
        return idA.compareTo(idB);
      });
      return query.docs.first;
    }
    return null;
  }

  Future<void> occupySpot(String docId) async {
    await spotsCollection.doc(docId).update({
      'status': 'occupied',
      'start_time': FieldValue.serverTimestamp(),
      'duration_minutes': 0,
      'last_updated': FieldValue.serverTimestamp(),
      'hold_by': null,
      'hold_expires_at': null,
    });
  }

  Future<void> releaseSpot(String docId) async {
    await spotsCollection.doc(docId).update({
      'status': 'available',
      'start_time': null,
      'duration_minutes': 0,
      'last_updated': FieldValue.serverTimestamp(),
      'hold_by': null,
      'hold_expires_at': null,
    });
  }

  Future<void> markSpotUnavailable(String docId) async {
    await spotsCollection.doc(docId).update({
      'status': 'unavailable',
      'start_time': null,
      'duration_minutes': 0,
      'last_updated': FieldValue.serverTimestamp(),
      'hold_by': null,
      'hold_expires_at': null,
    });
  }

  Future<void> updateDuration(String docId) async {
    final snap = await spotsCollection.doc(docId).get();
    final data = snap.data() as Map<String, dynamic>?;
    if (data == null) return;

    if (data['start_time'] != null && data['status'] == 'occupied') {
      final Timestamp start = data['start_time'];
      final minutes = DateTime.now().difference(start.toDate()).inMinutes;
      await spotsCollection.doc(docId).update({
        'duration_minutes': minutes,
        'last_updated': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<List<Map<String, dynamic>>> getAllSpots() async {
    final query = await spotsCollection.orderBy('id').get();
    return query.docs.map((doc) {
      final data = (doc.data() as Map<String, dynamic>)..['docId'] = doc.id;
      return data;
    }).toList();
  }

  // ========= SEED HELPERS =========

  /// เติม/อัปเดต x,y และ hold_* สำหรับช่อง 1..[count] จาก layout
  /// - ถ้าเอกสารยังไม่มี จะถูกสร้าง
  /// - ไม่ทับสถานะ/เวลาเดิม (status/start_time/duration_minutes)
  Future<void> seedFromLayout({int count = 52}) async {
    final now = FieldValue.serverTimestamp();
    final batch = _db.batch();

    for (int i = 1; i <= count; i++) {
      final ref = spotsCollection.doc(i.toString());
      final xy = kLayoutXY[i] ?? const {'x': 0, 'y': 0};

      batch.set(
        ref,
        {
          // ensure id และพิกัด
          'id': i,
          'x': xy['x'] ?? 0,
          'y': xy['y'] ?? 0,

          // เตรียมฟิลด์สำหรับระบบแนะนำ/IoT
          'hold_by': null,
          'hold_expires_at': null,

          // metadata
          'last_updated': now,

          // *** ไม่ยุ่งกับ status/start_time/duration_minutes ***
        },
        SetOptions(merge: true), // จะเติมฟิลด์ที่ขาด และไม่ทับของเดิม
      );
    }

    await batch.commit();
  }

  /// (ออปชัน) seed เฉพาะช่วงเลขช่อง
  Future<void> seedRange(int startId, int endId) async {
    final now = FieldValue.serverTimestamp();
    final batch = _db.batch();

    for (int i = startId; i <= endId; i++) {
      final ref = spotsCollection.doc(i.toString());
      final xy = kLayoutXY[i] ?? const {'x': 0, 'y': 0};
      batch.set(ref, {
        'id': i,
        'x': xy['x'] ?? 0,
        'y': xy['y'] ?? 0,
        'hold_by': null,
        'hold_expires_at': null,
        'last_updated': now,
      }, SetOptions(merge: true));
    }
    await batch.commit();
  }

  // ===== ช่วยช่วง dev (ปุ่ม/เมนู) =====
  Future<void> setStatus(String docId, String status) async {
    final ref = spotsCollection.doc(docId);
    final now = Timestamp.now();

    final base = <String, dynamic>{'status': status, 'last_updated': now};

    if (status == 'occupied') {
      base['start_time'] = now;
      base['duration_minutes'] = 0;
      base['hold_by'] = null;
      base['hold_expires_at'] = null;
    } else if (status == 'available') {
      base['start_time'] = null;
      base['duration_minutes'] = 0;
      base['hold_by'] = null;
      base['hold_expires_at'] = null;
    } else if (status == 'unavailable') {
      base['start_time'] = null;
      base['duration_minutes'] = 0;
      base['hold_by'] = null;
      base['hold_expires_at'] = null;
    }

    await ref.set(base, SetOptions(merge: true));
  }

  Future<void> setAllAvailable() async {
    final qs = await spotsCollection.get();
    final now = Timestamp.now();
    final batch = _db.batch();
    for (final d in qs.docs) {
      batch.set(d.reference, {
        'status': 'available',
        'start_time': null,
        'duration_minutes': 0,
        'hold_by': null,
        'hold_expires_at': null,
        'last_updated': now,
      }, SetOptions(merge: true));
    }
    await batch.commit();
  }

  Future<void> releaseAllHeld() async {
    final qs = await spotsCollection.where('status', isEqualTo: 'held').get();
    final now = Timestamp.now();
    final batch = _db.batch();
    for (final d in qs.docs) {
      batch.set(d.reference, {
        'status': 'available',
        'start_time': null,
        'duration_minutes': 0,
        'hold_by': null,
        'hold_expires_at': null,
        'last_updated': now,
      }, SetOptions(merge: true));
    }
    await batch.commit();
  }

  // เพิ่มเมธอดนี้ใน class FirebaseParkingService
  /// เลือกที่จอดตาม "ลำดับเส้นทาง one-way"
  /// - ดึงเฉพาะช่องที่ status == available แล้วเลือกตัวแรกที่ปรากฏใน kPathOrder
  Future<DocumentSnapshot?> getRecommendedByPathOrder() async {
    final qs =
        await spotsCollection.where('status', isEqualTo: 'available').get();
    if (qs.docs.isEmpty) return null;

    // map: id -> DocumentSnapshot
    final byId = <int, DocumentSnapshot>{};
    for (final d in qs.docs) {
      final id = int.tryParse((d['id'] ?? '').toString());
      if (id != null) byId[id] = d;
    }

    for (final id in kPathOrder) {
      final doc = byId[id];
      if (doc != null) return doc;
    }

    // fallback: ถ้าไม่มีใน order (ไม่น่าจะเกิด)
    return qs.docs.first;
  }
}
