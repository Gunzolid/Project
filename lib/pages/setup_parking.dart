import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class SetupParkingData extends StatelessWidget {
  const SetupParkingData({super.key});

  Future<void> createParkingSpots() async {
    final CollectionReference spots =
    FirebaseFirestore.instance.collection('parking_spots');

    const int totalSpots = 50;
    final List<int> unavailableSpots = [5, 12, 18, 27, 41]; // ช่องที่ใช้งานไม่ได้
    final now = Timestamp.now();

    for (int i = 1; i <= totalSpots; i++) {
      String status = unavailableSpots.contains(i) ? 'unavailable' : 'available';

      await spots.doc(i.toString()).set({
        'id': i,
        'status': status,
        'start_time': null,
        'duration_minutes': 0,
        'last_updated': now,
      });
    }

    debugPrint('เพิ่มที่จอดรถทั้งหมด $totalSpots ช่องเรียบร้อยแล้ว');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Setup Parking")),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await createParkingSpots();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("เพิ่มข้อมูลสำเร็จ")),
            );
          },
          child: const Text("สร้างข้อมูลที่จอดรถ"),
        ),
      ),
    );
  }
}
