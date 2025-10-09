import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    if (_recommendedSpotLocal != null) {
      _watchSpot(_recommendedSpotLocal!);
    }
  }

  @override
  void dispose() {
    _recSub?.cancel();
    super.dispose();
  }

  Future<void> _startSearching() async {
    // =================================================================
    //  VVV      จุดแก้ไขที่สำคัญที่สุดอยู่ตรงนี้      VVV
    // =================================================================
    // หากกำลังค้นหาอยู่ ให้หยุดการทำงานทันที ไม่ต้องทำอะไรต่อ
    if (_isSearching) {
      print("Blocked a repeat-press!"); // สำหรับ Debug
      return;
    }
    // =================================================================

    setState(() {
      _isSearching = true; // ปิดการใช้งานปุ่มทันที
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
          _isSearching = false; // คืนค่าเมื่อการค้นหาทั้งหมดจบลง
        });
      }
    }
  }

  void _watchSpot(int spotId) {
    _recSub?.cancel();
    _recSub = FirebaseParkingService().watchRecommendation(spotId).listen((st) {
      if (!st.isActive) {
        final msg = st.reason ?? 'ช่องหมดเวลา/ถูกเปลี่ยนสถานะ';
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(msg)));
          setState(() => _recommendedSpotLocal = null);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // รวมเงื่อนไขการปิดปุ่มไว้ในตัวแปรเดียวเพื่อความชัดเจน
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
                // ใช้เงื่อนไขโดยตรงในการควบคุม onPressed และ style
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
