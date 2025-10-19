import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <-- 1. Import FirebaseAuth
import 'package:mtproject/pages/searching_page.dart';
import 'package:mtproject/pages/profile_page.dart';
import 'package:mtproject/models/parking_map_layout.dart';
import 'package:mtproject/services/firebase_parking_service.dart';

class HomePage extends StatefulWidget {
  final int? recommendedSpot;
  const HomePage({super.key, this.recommendedSpot});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? _recommendedSpotLocal;
  StreamSubscription? _recSub;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _recommendedSpotLocal = widget.recommendedSpot;
    // 2. เรียกใช้ฟังก์ชันตรวจสอบการจองเมื่อหน้านี้ถูกสร้าง
    _checkExistingHold();
  }

  // =================================================================
  //  VVV      3. เพิ่มฟังก์ชันใหม่สำหรับตรวจสอบการจอง      VVV
  // =================================================================
  Future<void> _checkExistingHold() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final heldSpotQuery =
        await FirebaseFirestore.instance
            .collection('parking_spots')
            .where('hold_by', isEqualTo: user.uid)
            .limit(1)
            .get();

    if (heldSpotQuery.docs.isNotEmpty) {
      final heldSpotDoc = heldSpotQuery.docs.first;
      final spotId = int.tryParse(heldSpotDoc.id);

      if (spotId != null && mounted) {
        print("Found existing held spot: $spotId");
        setState(() {
          _recommendedSpotLocal = spotId; // อัปเดต State ของแอป
        });
        _watchSpot(spotId); // เริ่มติดตามสถานะของช่องที่จองไว้
      }
    }
  }
  // =================================================================

  @override
  void dispose() {
    _recSub?.cancel();
    super.dispose();
  }

  Future<void> _startSearching() async {
    if (_isSearching) return;

    setState(() {
      _isSearching = true;
    });

    try {
      final resultSpotId = await Navigator.push<int?>(
        context,
        MaterialPageRoute(builder: (_) => const SearchingPage()),
      );

      if (resultSpotId != null) {
        setState(() => _recommendedSpotLocal = resultSpotId);

        if (mounted) {
          showDialog(
            context: context,
            builder:
                (_) => AlertDialog(
                  title: const Text('ผลการค้นหา'),
                  content: Text(
                    'แนะนำช่องที่จอด: ช่อง $resultSpotId\nคุณมีเวลา 15 นาทีในการเข้าที่จอดนี้',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('ปิด'),
                    ),
                  ],
                ),
          );
        }
        _watchSpot(resultSpotId);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  void _watchSpot(int spotId) {
    _recSub?.cancel();
    _recSub = FirebaseParkingService().watchRecommendation(spotId).listen((
      recommendation,
    ) {
      // รับ object ที่มีข้อมูลครบถ้วน

      // ตรวจสอบว่าการจองสิ้นสุดลงแล้วหรือยัง (ไม่ว่าจะด้วยเหตุผลใดก็ตาม)
      if (!recommendation.isActive) {
        // ใช้ข้อความจาก Service เพื่อแจ้งผู้ใช้
        final msg = recommendation.reason ?? 'การจองสิ้นสุดลงแล้ว';

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(msg)));

          // **คำสั่งสำคัญ:** ล้างค่าการจองในแอป และปลดล็อกปุ่มค้นหา
          setState(() => _recommendedSpotLocal = null);
        }
        _recSub?.cancel(); // หยุดการติดตาม
      }
      // ถ้า recommendation.isActive เป็น true แสดงว่าการจองยังดำเนินอยู่ ก็ไม่ต้องทำอะไร
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool canSearch = !_isSearching && _recommendedSpotLocal == null;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Parking Assistant"),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ParkingMapLayout(recommendedSpot: _recommendedSpotLocal),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('parking_spots')
                          .where('status', isEqualTo: 'available')
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Text('โหลดข้อมูลไม่ได้');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text('กำลังเชื่อมต่อ...');
                    }
                    final available = snapshot.data?.docs.length ?? 0;
                    return Text(
                      "จำนวนพื้นที่ว่าง: $available/52",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_recommendedSpotLocal != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "แนะนำช่องที่จอด: ช่อง $_recommendedSpotLocal",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: canSearch ? _startSearching : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      canSearch ? Colors.blueGrey[200] : Colors.grey[350],
                  foregroundColor: canSearch ? Colors.black87 : Colors.black45,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  _isSearching
                      ? 'กำลังค้นหา...'
                      : (_recommendedSpotLocal != null
                          ? 'คุณมีช่องจอดที่แนะนำแล้ว'
                          : 'ค้นหาที่จอดรถ'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
