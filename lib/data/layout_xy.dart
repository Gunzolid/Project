// lib/data/layout_xy.dart
import 'package:flutter/material.dart';

class ParkingLayoutInfo {
  final int id;
  final double x; // left
  final double y; // top
  final Axis direction;

  const ParkingLayoutInfo({
    required this.id,
    required this.x,
    required this.y,
    this.direction = Axis.vertical, // ค่าเริ่มต้นคือแนวตั้ง
  });
}

const List<ParkingLayoutInfo> kParkingLayoutXY = [
  // เรียงตาม ID เพื่อให้อ่านง่าย
  ParkingLayoutInfo(id: 1, x: 195, y: 140),
  ParkingLayoutInfo(id: 2, x: 165, y: 140),
  ParkingLayoutInfo(id: 3, x: 135, y: 140),
  ParkingLayoutInfo(id: 4, x: 90, y: 150, direction: Axis.horizontal),
  ParkingLayoutInfo(id: 5, x: 90, y: 180, direction: Axis.horizontal),
  ParkingLayoutInfo(id: 6, x: 90, y: 230, direction: Axis.horizontal),
  ParkingLayoutInfo(id: 7, x: 90, y: 260, direction: Axis.horizontal),
  ParkingLayoutInfo(id: 8, x: 90, y: 290, direction: Axis.horizontal),
  ParkingLayoutInfo(id: 9, x: 90, y: 380, direction: Axis.horizontal),
  ParkingLayoutInfo(id: 10, x: 90, y: 410, direction: Axis.horizontal),
  ParkingLayoutInfo(id: 11, x: 90, y: 440, direction: Axis.horizontal),
  ParkingLayoutInfo(id: 12, x: 90, y: 500, direction: Axis.horizontal),
  ParkingLayoutInfo(id: 13, x: 90, y: 530, direction: Axis.horizontal),
  ParkingLayoutInfo(id: 14, x: 135, y: 520),
  ParkingLayoutInfo(id: 15, x: 165, y: 520),
  ParkingLayoutInfo(id: 16, x: 195, y: 520),
  ParkingLayoutInfo(id: 17, x: 225, y: 530, direction: Axis.horizontal),
  ParkingLayoutInfo(id: 18, x: 225, y: 500, direction: Axis.horizontal),
  ParkingLayoutInfo(id: 19, x: 225, y: 440, direction: Axis.horizontal),
  ParkingLayoutInfo(id: 20, x: 225, y: 410, direction: Axis.horizontal),
  ParkingLayoutInfo(id: 21, x: 225, y: 380, direction: Axis.horizontal),
  ParkingLayoutInfo(id: 22, x: 225, y: 290, direction: Axis.horizontal),
  ParkingLayoutInfo(id: 23, x: 225, y: 260, direction: Axis.horizontal),
  ParkingLayoutInfo(id: 24, x: 225, y: 230, direction: Axis.horizontal),
  ParkingLayoutInfo(id: 25, x: 225, y: 180, direction: Axis.horizontal),
  ParkingLayoutInfo(id: 26, x: 225, y: 150, direction: Axis.horizontal),
  ParkingLayoutInfo(id: 27, x: 130, y: 50),
  ParkingLayoutInfo(id: 28, x: 100, y: 50),
  ParkingLayoutInfo(id: 29, x: 70, y: 50),
  ParkingLayoutInfo(id: 30, x: 5, y: 150, direction: Axis.horizontal),
  ParkingLayoutInfo(id: 31, x: 5, y: 180, direction: Axis.horizontal),
  ParkingLayoutInfo(id: 32, x: 5, y: 230, direction: Axis.horizontal),
  ParkingLayoutInfo(id: 33, x: 5, y: 260, direction: Axis.horizontal),
  ParkingLayoutInfo(id: 34, x: 5, y: 290, direction: Axis.horizontal),
  ParkingLayoutInfo(id: 35, x: 5, y: 380, direction: Axis.horizontal),
  ParkingLayoutInfo(id: 36, x: 5, y: 410, direction: Axis.horizontal),
  ParkingLayoutInfo(id: 37, x: 5, y: 440, direction: Axis.horizontal),
  ParkingLayoutInfo(id: 38, x: 5, y: 500, direction: Axis.horizontal),
  ParkingLayoutInfo(id: 39, x: 5, y: 530, direction: Axis.horizontal),
  ParkingLayoutInfo(id: 40, x: 70, y: 615),
  ParkingLayoutInfo(id: 41, x: 100, y: 615),
  ParkingLayoutInfo(id: 42, x: 130, y: 615),
  ParkingLayoutInfo(id: 43, x: 310, y: 530, direction: Axis.horizontal),
  ParkingLayoutInfo(id: 44, x: 310, y: 500, direction: Axis.horizontal),
  ParkingLayoutInfo(id: 45, x: 310, y: 440, direction: Axis.horizontal),
  ParkingLayoutInfo(id: 46, x: 310, y: 410, direction: Axis.horizontal),
  ParkingLayoutInfo(id: 47, x: 310, y: 380, direction: Axis.horizontal),
  ParkingLayoutInfo(id: 48, x: 310, y: 290, direction: Axis.horizontal),
  ParkingLayoutInfo(id: 49, x: 310, y: 260, direction: Axis.horizontal),
  ParkingLayoutInfo(id: 50, x: 310, y: 230, direction: Axis.horizontal),
  ParkingLayoutInfo(id: 51, x: 310, y: 180, direction: Axis.horizontal),
  ParkingLayoutInfo(id: 52, x: 310, y: 150, direction: Axis.horizontal),
];
