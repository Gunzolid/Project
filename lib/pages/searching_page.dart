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
      final doc = await _svc.getRecommendedByPathOrder()
          .timeout(const Duration(seconds: 4));

      if (!mounted || _done) return;

      if (doc != null) {
        _done = true;
        Navigator.pop<int>(context, doc['id'] as int); // ✅ ส่ง spotId กลับ
      } else {
        _noSpotAndBack();
      }
    } on TimeoutException {
      if (!mounted || _done) return;
      _show('ค้นหานานเกินไป กรุณาลองใหม่');
      _backWithoutSpot();
    } catch (e) {
      if (!mounted || _done) return;
      _show('เกิดข้อผิดพลาด: $e');
      _backWithoutSpot();
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
