// lib/models/parking_map_layout.dart
import 'package:flutter/material.dart';
import 'package:mtproject/data/layout_xy.dart'; // ตรวจสอบว่า import ถูกต้อง
import 'parking_box.dart';

class ParkingMapLayout extends StatelessWidget {
  final int? recommendedSpot;

  const ParkingMapLayout({super.key, this.recommendedSpot});

  @override
  Widget build(BuildContext context) {
    // --- 1. ดึงค่า Brightness และกำหนดสีถนน ---
    final brightness = Theme.of(context).brightness;
    final roadColor =
        brightness == Brightness.dark ? Colors.white : Colors.black;
    final backgroundColor =
        Theme.of(context).scaffoldBackgroundColor; // สีพื้นหลังตาม Theme

    return InteractiveViewer(
      maxScale: 3.0,
      minScale: 0.1,
      child: Center(
        child: Container(
          // <-- เพิ่ม Container ครอบเพื่อให้มีพื้นหลัง
          color: backgroundColor, // <-- ใช้สีพื้นหลังตาม Theme
          width: 800,
          height: 1400,
          child: Stack(
            children: [
              // --- 2. ใช้ roadColor กับ Container ของถนน ---
              // ถนนแนวนอนบน
              Positioned(
                top: 100,
                left: 50,
                child: Container(
                  width: 300,
                  height: 40,
                  color: roadColor,
                ), // <-- ใช้ roadColor
              ),
              // ถนนแนวนอนล่าง
              Positioned(
                top: 570,
                left: 50,
                child: Container(
                  width: 300,
                  height: 40,
                  color: roadColor,
                ), // <-- ใช้ roadColor
              ),
              // ถนนแนวตั้งซ้าย
              Positioned(
                top: 100,
                left: 50,
                child: Container(
                  width: 40,
                  height: 500,
                  color: roadColor,
                ), // <-- ใช้ roadColor
              ),
              // ถนนแนวตั้งขวา
              Positioned(
                top: 100,
                left: 270, // <-- ตำแหน่งเดิมจากโค้ดของคุณ
                child: Container(
                  width: 40,
                  height: 500,
                  color: roadColor,
                ), // <-- ใช้ roadColor
              ),

              // --- ช่องที่จอด (ใช้ Loop สร้างจาก layout_xy.dart) ---
              // การใช้ Loop จะทำให้โค้ดสั้นลง และง่ายต่อการแก้ไขตำแหน่งในอนาคต
              for (final spotInfo in kParkingLayoutXY)
                Positioned(
                  top: spotInfo.y,
                  left: spotInfo.x,
                  child: ParkingBox(
                    docId: '${spotInfo.id}', // ใช้ id จาก spotInfo
                    id: spotInfo.id,
                    direction: spotInfo.direction,
                    recommendedId: recommendedSpot,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
