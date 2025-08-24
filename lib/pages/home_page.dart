import 'package:flutter/material.dart';
import 'package:mtproject/pages/searching_page.dart';
import 'package:mtproject/pages/profile_page.dart';
import 'package:mtproject/models/parking_map_layout.dart'; // ✅ ใช้อันนี้แทน grid
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatelessWidget {
  final int? recommendedSpot; // ✅ ปรับให้รับ int (ตาม searching page ใหม่)

  const HomePage({super.key, this.recommendedSpot});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Parking Assistant"),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ✅ แสดงแผนผังแบบ Stack
            Expanded(
              child: ParkingMapLayout(
                recommendedSpot: recommendedSpot,
              ),
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
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (recommendedSpot != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "แนะนำช่องที่จอด: ช่อง $recommendedSpot",
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SearchingPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'ค้นหา',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
