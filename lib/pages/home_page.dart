// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mtproject/pages/searching_page.dart';
import 'package:mtproject/pages/profile_page.dart';
import 'package:mtproject/models/parking_map_layout.dart';
import 'package:mtproject/ui/recommend_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.recommendedSpot});
  final int? recommendedSpot;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? _recommendedSpotLocal;

  @override
  void initState() {
    super.initState();
    _recommendedSpotLocal = widget.recommendedSpot;
  }

  Future<void> _onSearchPressed() async {
    // ✅ รอผลลัพธ์จาก SearchingPage (ต้อง pop กลับมาด้วย spotId)
    final int? resultSpotId = await Navigator.push<int?>(
      context,
      MaterialPageRoute(builder: (_) => const SearchingPage()),
    );

    if (!mounted) return;

    if (resultSpotId != null) {
      setState(() => _recommendedSpotLocal = resultSpotId);

      // ✅ โชว์ popup: ช่องที่แนะนำ + ถามเปิด Google Maps
      await showRecommendDialog(context, recommendedIds: [resultSpotId]);
    } else {
      // ไม่เจอ/ยกเลิก
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่พบช่องที่เหมาะสมในตอนนี้')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final rec = _recommendedSpotLocal;

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
              child: ParkingMapLayout(recommendedSpot: rec),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('parking_spots')
                      .where('status', isEqualTo: 'available')
                      .snapshots(),
                  builder: (context, snapshot) {
                    final available = snapshot.data?.docs.length ?? 0;
                    return Text(
                      "จำนวนพื้นที่ว่าง: $available/52",
                      style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    );
                  },
                ),
              ],
            ),

            if (rec != null) ...[
              const SizedBox(height: 8),
              Text(
                "แนะนำช่องที่จอด: ช่อง $rec",
                style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ],

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: _onSearchPressed, // ✅ ใช้เมธอดด้านบน
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('ค้นหา', style: TextStyle(color: Colors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
