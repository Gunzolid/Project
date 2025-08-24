import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mtproject/pages/home_page.dart';
import 'package:mtproject/services/firebase_parking_service.dart';
import 'dart:async';

class SearchingPage extends StatefulWidget {
  const SearchingPage({super.key});

  @override
  State<SearchingPage> createState() => _SearchingPageState();
}

class _SearchingPageState extends State<SearchingPage> {
  final FirebaseParkingService _parkingService = FirebaseParkingService();

  DocumentSnapshot? recommendedSpot;

  @override
  void initState() {
    super.initState();
    _startSearching();
  }

  Future<void> _startSearching() async {
    try {
      recommendedSpot = await _parkingService
          .getRecommendedSpot()
          .timeout(const Duration(seconds: 5));
    } on TimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ค้นหานานเกินไป กรุณาลองใหม่")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
      return;
    }

    if (recommendedSpot != null) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            recommendedSpot: recommendedSpot!['id'], // ส่ง id ไป home
          ),
        ),
      );
    }
    else {
      if (!mounted) return;

      // ❗ ไม่พบช่องว่าง → กลับหน้าเดิม + แจ้งเตือน
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ไม่พบที่จอดรถว่างในขณะนี้")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
    }
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
