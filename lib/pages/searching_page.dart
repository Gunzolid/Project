import 'package:flutter/material.dart';
import 'dart:async';
import 'package:mtproject/pages/home_page.dart';
import 'package:mtproject/services/parking_functions.dart'; // สำหรับโหมดจริง (Functions)
import 'package:mtproject/services/firebase_parking_service.dart'; // fallback โหมด dev (client)

class SearchingPage extends StatefulWidget {
  const SearchingPage({super.key});

  @override
  State<SearchingPage> createState() => _SearchingPageState();
}

class _SearchingPageState extends State<SearchingPage> {
  final _svc = FirebaseParkingService();

  @override
  void initState() {
    super.initState();
    _startSearching();
  }

  Future<void> _startSearching() async {
    // 1) ลองเรียก Cloud Function (ถ้าคุณ deploy ไว้แล้ว)
    try {
      final result = await ParkingFunctions.recommend(
        entryX: 310,
        entryY: 150,
        holdSeconds: 120,
      ) // จุดเข้า "ขวาบน"
      .timeout(const Duration(seconds: 6));

      if (mounted && result != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomePage(recommendedSpot: result.id),
          ),
        );
        return;
      }
    } catch (_) {
      // เงียบ ๆ แล้วไป fallback ด้านล่าง
    }

    // 2) Fallback โหมด dev: เลือกตาม "ลำดับเส้นทาง one-way" บน client
    try {
      final doc = await _svc.getRecommendedByPathOrder().timeout(
        const Duration(seconds: 4),
      );
      if (!mounted) return;

      if (doc != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomePage(recommendedSpot: doc['id'] as int),
          ),
        );
      } else {
        _noSpotAndBack();
      }
    } on TimeoutException {
      if (!mounted) return;
      _show('ค้นหานานเกินไป กรุณาลองใหม่');
      _goHome();
    } catch (e) {
      if (!mounted) return;
      _show('เกิดข้อผิดพลาด: $e');
      _goHome();
    }
  }

  void _noSpotAndBack() {
    _show('ขณะนี้ไม่มีช่องว่าง');
    _goHome();
  }

  void _goHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  void _show(String msg) {
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
