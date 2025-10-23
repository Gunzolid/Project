// lib/models/admin_parking_map_layout.dart
import 'package:flutter/material.dart';
// 1. Import ข้อมูลตำแหน่ง และ AdminParkingBox
import 'package:mtproject/data/layout_xy.dart';
import 'admin_parking_box.dart';

class AdminParkingMapLayout extends StatelessWidget {
  const AdminParkingMapLayout({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. ดึงค่า Brightness และกำหนดสีถนน/พื้นหลัง
    final brightness = Theme.of(context).brightness;
    final roadColor =
        brightness == Brightness.dark ? Colors.white : Colors.black;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return InteractiveViewer(
      maxScale: 3.0,
      minScale: 0.1,
      child: Center(
        child: Container(
          // <-- ใช้ Container ครอบ
          width: 800,
          height: 1400, // <-- ปรับความสูงให้เท่ากับ User layout
          color: backgroundColor, // <-- ใช้สีพื้นหลังตาม Theme
          child: Stack(
            // clipBehavior: Clip.hardEdge, // เอาออกได้ถ้าไม่ต้องการ
            children: [
              // --- 3. ใช้ roadColor กับ Container ของถนน ---
              // ถนนแนวนอนบน
              Positioned(
                top: 100,
                left: 50,
                child: Container(width: 300, height: 40, color: roadColor),
              ),
              // ถนนแนวนอนล่าง (ปรับตำแหน่ง bottom เป็น top ให้เหมือน User layout)
              Positioned(
                top: 570, // <-- ใช้ top แทน bottom
                left: 50,
                child: Container(width: 300, height: 40, color: roadColor),
              ),
              // ถนนแนวตั้งซ้าย
              Positioned(
                top: 100,
                left: 50,
                child: Container(width: 40, height: 500, color: roadColor),
              ),
              // ถนนแนวตั้งขวา
              Positioned(
                top: 100,
                left: 270, // <-- ตำแหน่งเดิมจากโค้ดของคุณ
                child: Container(width: 40, height: 500, color: roadColor),
              ),

              // --- 4. ใช้ Loop สร้าง AdminParkingBox ---
              for (final spotInfo in kParkingLayoutXY)
                Positioned(
                  top: spotInfo.y,
                  left: spotInfo.x,
                  child: AdminParkingBox(
                    // <-- ใช้ AdminParkingBox
                    docId: '${spotInfo.id}',
                    id: spotInfo.id,
                    direction: spotInfo.direction,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 5. ลบฟังก์ชัน _toggleStatus ที่ไม่ได้ใช้ออกไป ---
  // ฟังก์ชันนี้ถูกย้ายไปอยู่ใน AdminParkingBox แล้ว
}
