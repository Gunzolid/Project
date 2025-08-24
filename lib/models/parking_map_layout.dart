import 'package:flutter/material.dart';
import 'parking_box.dart';

class ParkingMapLayout extends StatelessWidget {
  final int? recommendedSpot;

  const ParkingMapLayout({super.key, this.recommendedSpot});

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      maxScale: 3.0,
      minScale: 0.1, //
      child: Center(
        child: Container(
          width: 800,
          height: 1400,
          child: Stack(
            children: [
              // ถนนแนวนอนบน
              Positioned(
                top: 100,
                left: 50,
                child: Container(width: 300, height: 40, color: Colors.black),
              ),
              // ถนนแนวนอนล่าง
              Positioned(
                bottom: 50,
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

              // ช่องที่จอด
              Positioned(top: 140, left: 135, child: ParkingBox(docId: '3', id: 3, recommendedId: recommendedSpot)),
              Positioned(top: 140, left: 165, child: ParkingBox(docId: '2', id: 2, recommendedId: recommendedSpot)),
              Positioned(top: 140, left: 195, child: ParkingBox(docId: '1', id: 1, recommendedId: recommendedSpot)),

              Positioned(top: 150, left: 90, child: ParkingBox(docId: '4', id: 4, direction: Axis.horizontal, recommendedId: recommendedSpot)),
              Positioned(top: 180, left: 90, child: ParkingBox(docId: '5', id: 5, direction: Axis.horizontal, recommendedId: recommendedSpot)),
              Positioned(top: 230, left: 90, child: ParkingBox(docId: '6', id: 6, direction: Axis.horizontal, recommendedId: recommendedSpot)),
              Positioned(top: 260, left: 90, child: ParkingBox(docId: '7', id: 7, direction: Axis.horizontal, recommendedId: recommendedSpot)),
              Positioned(top: 290, left: 90, child: ParkingBox(docId: '8', id: 8, direction: Axis.horizontal, recommendedId: recommendedSpot)),
              Positioned(top: 380, left: 90, child: ParkingBox(docId: '9', id: 9, direction: Axis.horizontal, recommendedId: recommendedSpot)),
              Positioned(top: 410, left: 90, child: ParkingBox(docId: '10', id: 10, direction: Axis.horizontal, recommendedId: recommendedSpot)),
              Positioned(top: 440, left: 90, child: ParkingBox(docId: '11', id: 11, direction: Axis.horizontal, recommendedId: recommendedSpot)),
              Positioned(top: 500, left: 90, child: ParkingBox(docId: '12', id: 12, direction: Axis.horizontal, recommendedId: recommendedSpot)),
              Positioned(top: 530, left: 90, child: ParkingBox(docId: '13', id: 13, direction: Axis.horizontal, recommendedId: recommendedSpot)),

              Positioned(top: 520, left: 135, child: ParkingBox(docId: '14', id: 14, recommendedId: recommendedSpot)),
              Positioned(top: 520, left: 165, child: ParkingBox(docId: '15', id: 15, recommendedId: recommendedSpot)),
              Positioned(top: 520, left: 195, child: ParkingBox(docId: '16', id: 16, recommendedId: recommendedSpot)),

              Positioned(top: 530, left: 225, child: ParkingBox(docId: '17', id: 17, direction: Axis.horizontal, recommendedId: recommendedSpot)),
              Positioned(top: 500, left: 225, child: ParkingBox(docId: '18', id: 18, direction: Axis.horizontal, recommendedId: recommendedSpot)),
              Positioned(top: 440, left: 225, child: ParkingBox(docId: '19', id: 19, direction: Axis.horizontal, recommendedId: recommendedSpot)),
              Positioned(top: 410, left: 225, child: ParkingBox(docId: '20', id: 20, direction: Axis.horizontal, recommendedId: recommendedSpot)),
              Positioned(top: 380, left: 225, child: ParkingBox(docId: '21', id: 21, direction: Axis.horizontal, recommendedId: recommendedSpot)),
              Positioned(top: 290, left: 225, child: ParkingBox(docId: '22', id: 22, direction: Axis.horizontal, recommendedId: recommendedSpot)),
              Positioned(top: 260, left: 225, child: ParkingBox(docId: '23', id: 23, direction: Axis.horizontal, recommendedId: recommendedSpot)),
              Positioned(top: 230, left: 225, child: ParkingBox(docId: '24', id: 24, direction: Axis.horizontal, recommendedId: recommendedSpot)),
              Positioned(top: 180, left: 225, child: ParkingBox(docId: '25', id: 25, direction: Axis.horizontal, recommendedId: recommendedSpot)),
              Positioned(top: 150, left: 225, child: ParkingBox(docId: '26', id: 26, direction: Axis.horizontal, recommendedId: recommendedSpot)),

              Positioned(top: 50, left: 130, child: ParkingBox(docId: '27', id: 27, recommendedId: recommendedSpot)),
              Positioned(top: 50, left: 100, child: ParkingBox(docId: '28', id: 28, recommendedId: recommendedSpot)),
              Positioned(top: 50, left: 70, child: ParkingBox(docId: '29', id: 29, recommendedId: recommendedSpot)),

              Positioned(top: 150, left: 5, child: ParkingBox(docId: '30', id: 30, direction: Axis.horizontal, recommendedId: recommendedSpot)),
              Positioned(top: 180, left: 5, child: ParkingBox(docId: '31', id: 31, direction: Axis.horizontal, recommendedId: recommendedSpot)),
              Positioned(top: 230, left: 5, child: ParkingBox(docId: '32', id: 32, direction: Axis.horizontal, recommendedId: recommendedSpot)),
              Positioned(top: 260, left: 5, child: ParkingBox(docId: '33', id: 33, direction: Axis.horizontal, recommendedId: recommendedSpot)),
              Positioned(top: 290, left: 5, child: ParkingBox(docId: '34', id: 34, direction: Axis.horizontal, recommendedId: recommendedSpot)),
              Positioned(top: 380, left: 5, child: ParkingBox(docId: '35', id: 35, direction: Axis.horizontal, recommendedId: recommendedSpot)),
              Positioned(top: 410, left: 5, child: ParkingBox(docId: '36', id: 36, direction: Axis.horizontal, recommendedId: recommendedSpot)),
              Positioned(top: 440, left: 5, child: ParkingBox(docId: '37', id: 37, direction: Axis.horizontal, recommendedId: recommendedSpot)),
              Positioned(top: 500, left: 5, child: ParkingBox(docId: '38', id: 38, direction: Axis.horizontal, recommendedId: recommendedSpot)),
              Positioned(top: 530, left: 5, child: ParkingBox(docId: '39', id: 39, direction: Axis.horizontal, recommendedId: recommendedSpot)),

              Positioned(top: 615, left: 70, child: ParkingBox(docId: '40', id: 40, recommendedId: recommendedSpot)),
              Positioned(top: 615, left: 100, child: ParkingBox(docId: '41', id: 41, recommendedId: recommendedSpot)),
              Positioned(top: 615, left: 130, child: ParkingBox(docId: '42', id: 42, recommendedId: recommendedSpot)),

              Positioned(top: 530, left: 310, child: ParkingBox(docId: '43', id: 43, direction: Axis.horizontal, recommendedId: recommendedSpot)),
              Positioned(top: 500, left: 310, child: ParkingBox(docId: '44', id: 44, direction: Axis.horizontal, recommendedId: recommendedSpot)),
              Positioned(top: 440, left: 310, child: ParkingBox(docId: '45', id: 45, direction: Axis.horizontal, recommendedId: recommendedSpot)),
              Positioned(top: 410, left: 310, child: ParkingBox(docId: '46', id: 46, direction: Axis.horizontal, recommendedId: recommendedSpot)),
              Positioned(top: 380, left: 310, child: ParkingBox(docId: '47', id: 47, direction: Axis.horizontal, recommendedId: recommendedSpot)),
              Positioned(top: 290, left: 310, child: ParkingBox(docId: '48', id: 48, direction: Axis.horizontal, recommendedId: recommendedSpot)),
              Positioned(top: 260, left: 310, child: ParkingBox(docId: '49', id: 49, direction: Axis.horizontal, recommendedId: recommendedSpot)),
              Positioned(top: 230, left: 310, child: ParkingBox(docId: '50', id: 50, direction: Axis.horizontal, recommendedId: recommendedSpot)),
              Positioned(top: 180, left: 310, child: ParkingBox(docId: '51', id: 51, direction: Axis.horizontal, recommendedId: recommendedSpot)),
              Positioned(top: 150, left: 310, child: ParkingBox(docId: '52', id: 52, direction: Axis.horizontal, recommendedId: recommendedSpot)),
            ],
          ),
        ),
      ),
    );
  }
}
