// lib/models/admin_parking_map_layout.dart
import 'package:flutter/material.dart';
// 1. Import ข้อมูลตำแหน่ง
import 'package:mtproject/data/layout_xy.dart';
import 'package:mtproject/models/admin_parking_box.dart';

class AdminParkingMapLayout extends StatelessWidget {
  const AdminParkingMapLayout({super.key});

  @override
  Widget build(BuildContext context) {
    // ดึงค่า Brightness และกำหนดสีถนน/พื้นหลัง
    final brightness = Theme.of(context).brightness;
    final roadColor =
        brightness == Brightness.dark ? Colors.white : Colors.black;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return InteractiveViewer(
      maxScale: 3.0,
      minScale: 0.1,
      child: Center(
        child: Container(
          width: 800,
          height: 1400,
          color: backgroundColor,
          child: Stack(
            children: [
              // --- ใช้ roadColor กับ Container ของถนน ---
              Positioned(
                top: 100,
                left: 50,
                child: Container(width: 300, height: 40, color: roadColor),
              ),
              Positioned(
                top: 570,
                left: 50,
                child: Container(width: 300, height: 40, color: roadColor),
              ),
              Positioned(
                top: 100,
                left: 50,
                child: Container(width: 40, height: 500, color: roadColor),
              ),
              Positioned(
                top: 100,
                left: 270,
                child: Container(width: 40, height: 500, color: roadColor),
              ),

              // --- ใช้ Loop สร้าง AdminParkingBox ---
              for (final spotInfo in kParkingLayoutXY)
                Positioned(
                  top: spotInfo.y,
                  left: spotInfo.x,
                  child: AdminParkingBox(
                    // <-- ตอนนี้รู้จักแล้ว
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
}
