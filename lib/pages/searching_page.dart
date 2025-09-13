import 'package:flutter/material.dart';
import 'dart:async';
import 'package:mtproject/services/parking_functions.dart'; // โหมดจริง (Cloud Functions)
import 'package:mtproject/services/firebase_parking_service.dart'; // โหมด dev (client)

class SearchingPage extends StatefulWidget {
  const SearchingPage({super.key});

  @override
  State<SearchingPage> createState() => _SearchingPageState();
}

class _SearchingPageState extends State<SearchingPage> {
  final _svc = FirebaseParkingService();
  bool _done = false; // กัน pop ซ้ำ

  @override
  void initState() {
    super.initState();
    _startSearching();
  }

  Future<void> _startSearching() async {
    // 1) ลองเรียก Cloud Function (ถ้ามี)
    try {
      final result = await ParkingFunctions.recommend(
        entryX: 310,
        entryY: 150,
        holdSeconds: 120,
      ).timeout(const Duration(seconds: 6));

      if (mounted && !_done && result != null) {
        _done = true;
        Navigator.pop<int>(context, result.id); // ✅ ส่ง spotId กลับไป HomePage
        return;
      }
    } catch (_) {
      // เงียบ ๆ แล้วไป fallback
    }

    // 2) Fallback โหมด dev บน client
    try {
  final spotId = await FirebaseParkingService().recommendAndHoldClient(
    holdSeconds: 900, // 15 นาที
  );
  if (!mounted) return;

  if (spotId != null) {
    Navigator.pop<int>(context, spotId); // ให้ Home โชว์ popup ต่อ
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ช่วงนี้มีคนจองพร้อมกัน ลองใหม่อีกครั้ง')),
    );
    Navigator.pop<int?>(context, null);
  }
} catch (e) {
  if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
  );
  Navigator.pop<int?>(context, null);
}
  }

  void _noSpotAndBack() {
    _show('ขณะนี้ไม่มีช่องว่าง');
    _backWithoutSpot();
  }

  void _backWithoutSpot() {
    _done = true;
    Navigator.pop<int?>(context, null); // ✅ กลับโดยไม่มีผลลัพธ์
  }

  void _show(String msg) {
    // แสดงบนหน้านี้ก่อน pop (ถ้าอยากให้ไปโผล่ที่ Home ให้ย้ายไปแสดงหลังรับผลลัพธ์แทน)
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              "กำลังค้นหาที่จอดรถ...",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
