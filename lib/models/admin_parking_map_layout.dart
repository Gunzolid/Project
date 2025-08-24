import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_parking_box.dart';

class AdminParkingMapLayout extends StatelessWidget {
  const AdminParkingMapLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      maxScale: 3.0,
      minScale: 0.1,
      child: Center(
        child: Container(
          width: 800,
          height: 800,
          color: Colors.white,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // ถนน
              Positioned(
                top: 100,
                left: 50,
                child: Container(width: 300, height: 40, color: Colors.black),
              ),
              // ถนนแนวนอนล่าง
              Positioned(
                bottom: 190,
                left: 50,
                child: Container(width: 300, height: 40, color: Colors.black),
              ),
              // ถนนแนวตั้งซ้าย
              Positioned(
                top: 100,
                left: 50,
                child: Container(width: 40, height: 500, color: Colors.black),
              ),
              // ถนนแนวตั้งขวา
              Positioned(
                top: 100,
                left: 270,
                child: Container(width: 40, height: 500, color: Colors.black),
              ),
              // กล่องช่องจอดทั้งหมด
              Positioned(top: 140, left: 135, child: AdminParkingBox(docId: '3', id: 3)),
              Positioned(top: 140, left: 165, child: AdminParkingBox(docId: '2', id: 2)),
              Positioned(top: 140, left: 195, child: AdminParkingBox(docId: '1', id: 1)),

              Positioned(top: 150, left: 90, child: AdminParkingBox(docId: '4', id: 4, direction: Axis.horizontal)),
              Positioned(top: 180, left: 90, child: AdminParkingBox(docId: '5', id: 5, direction: Axis.horizontal)),
              Positioned(top: 230, left: 90, child: AdminParkingBox(docId: '6', id: 6, direction: Axis.horizontal)),
              Positioned(top: 260, left: 90, child: AdminParkingBox(docId: '7', id: 7, direction: Axis.horizontal)),
              Positioned(top: 290, left: 90, child: AdminParkingBox(docId: '8', id: 8, direction: Axis.horizontal)),
              Positioned(top: 380, left: 90, child: AdminParkingBox(docId: '9', id: 9, direction: Axis.horizontal)),
              Positioned(top: 410, left: 90, child: AdminParkingBox(docId: '10', id: 10, direction: Axis.horizontal)),
              Positioned(top: 440, left: 90, child: AdminParkingBox(docId: '11', id: 11, direction: Axis.horizontal)),
              Positioned(top: 500, left: 90, child: AdminParkingBox(docId: '12', id: 12, direction: Axis.horizontal)),
              Positioned(top: 530, left: 90, child: AdminParkingBox(docId: '13', id: 13, direction: Axis.horizontal)),

              Positioned(top: 520, left: 135, child: AdminParkingBox(docId: '14', id: 14)),
              Positioned(top: 520, left: 165, child: AdminParkingBox(docId: '15', id: 15)),
              Positioned(top: 520, left: 195, child: AdminParkingBox(docId: '16', id: 16)),

              Positioned(top: 530, left: 225, child: AdminParkingBox(docId: '17', id: 17, direction: Axis.horizontal)),
              Positioned(top: 500, left: 225, child: AdminParkingBox(docId: '18', id: 18, direction: Axis.horizontal)),
              Positioned(top: 440, left: 225, child: AdminParkingBox(docId: '19', id: 19, direction: Axis.horizontal)),
              Positioned(top: 410, left: 225, child: AdminParkingBox(docId: '20', id: 20, direction: Axis.horizontal)),
              Positioned(top: 380, left: 225, child: AdminParkingBox(docId: '21', id: 21, direction: Axis.horizontal)),
              Positioned(top: 290, left: 225, child: AdminParkingBox(docId: '22', id: 22, direction: Axis.horizontal)),
              Positioned(top: 260, left: 225, child: AdminParkingBox(docId: '23', id: 23, direction: Axis.horizontal)),
              Positioned(top: 230, left: 225, child: AdminParkingBox(docId: '24', id: 24, direction: Axis.horizontal)),
              Positioned(top: 180, left: 225, child: AdminParkingBox(docId: '25', id: 25, direction: Axis.horizontal)),
              Positioned(top: 150, left: 225, child: AdminParkingBox(docId: '26', id: 26, direction: Axis.horizontal)),

              Positioned(top: 50, left: 130, child: AdminParkingBox(docId: '27', id: 27)),
              Positioned(top: 50, left: 100, child: AdminParkingBox(docId: '28', id: 28)),
              Positioned(top: 50, left: 70, child: AdminParkingBox(docId: '29', id: 29)),

              Positioned(top: 150, left: 5, child: AdminParkingBox(docId: '30', id: 30, direction: Axis.horizontal)),
              Positioned(top: 180, left: 5, child: AdminParkingBox(docId: '31', id: 31, direction: Axis.horizontal)),
              Positioned(top: 230, left: 5, child: AdminParkingBox(docId: '32', id: 32, direction: Axis.horizontal)),
              Positioned(top: 260, left: 5, child: AdminParkingBox(docId: '33', id: 33, direction: Axis.horizontal)),
              Positioned(top: 290, left: 5, child: AdminParkingBox(docId: '34', id: 34, direction: Axis.horizontal)),
              Positioned(top: 380, left: 5, child: AdminParkingBox(docId: '35', id: 35, direction: Axis.horizontal)),
              Positioned(top: 410, left: 5, child: AdminParkingBox(docId: '36', id: 36, direction: Axis.horizontal)),
              Positioned(top: 440, left: 5, child: AdminParkingBox(docId: '37', id: 37, direction: Axis.horizontal)),
              Positioned(top: 500, left: 5, child: AdminParkingBox(docId: '38', id: 38, direction: Axis.horizontal)),
              Positioned(top: 530, left: 5, child: AdminParkingBox(docId: '39', id: 39, direction: Axis.horizontal)),

              Positioned(top: 615, left: 70, child: AdminParkingBox(docId: '40', id: 40)),
              Positioned(top: 615, left: 100, child: AdminParkingBox(docId: '41', id: 41)),
              Positioned(top: 615, left: 130, child: AdminParkingBox(docId: '42', id: 42)),

              Positioned(top: 530, left: 310, child: AdminParkingBox(docId: '43', id: 43, direction: Axis.horizontal)),
              Positioned(top: 500, left: 310, child: AdminParkingBox(docId: '44', id: 44, direction: Axis.horizontal)),
              Positioned(top: 440, left: 310, child: AdminParkingBox(docId: '45', id: 45, direction: Axis.horizontal)),
              Positioned(top: 410, left: 310, child: AdminParkingBox(docId: '46', id: 46, direction: Axis.horizontal)),
              Positioned(top: 380, left: 310, child: AdminParkingBox(docId: '47', id: 47, direction: Axis.horizontal)),
              Positioned(top: 290, left: 310, child: AdminParkingBox(docId: '48', id: 48, direction: Axis.horizontal)),
              Positioned(top: 260, left: 310, child: AdminParkingBox(docId: '49', id: 49, direction: Axis.horizontal)),
              Positioned(top: 230, left: 310, child: AdminParkingBox(docId: '50', id: 50, direction: Axis.horizontal)),
              Positioned(top: 180, left: 310, child: AdminParkingBox(docId: '51', id: 51, direction: Axis.horizontal)),
              Positioned(top: 150, left: 310, child: AdminParkingBox(docId: '52', id: 52, direction: Axis.horizontal)),


            ],
          ),
        ),
      ),
    );
  }


  void _toggleStatus(String docId, String currentStatus) {
    String nextStatus;
    if (currentStatus == 'available') {
      nextStatus = 'occupied';
    } else if (currentStatus == 'occupied') {
      nextStatus = 'unavailable';
    } else {
      nextStatus = 'available';
    }

    FirebaseFirestore.instance.collection('parking_spots').doc(docId).update({
      'status': nextStatus,
      'start_time': nextStatus == 'occupied' ? Timestamp.now() : null,
      'duration_minutes': 0,
    });
  }
}
