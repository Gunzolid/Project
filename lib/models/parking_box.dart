// lib/models/parking_box.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ParkingBox extends StatefulWidget {
  final String docId;
  final int id;
  final Axis direction;
  final int? recommendedId;

  const ParkingBox({
    super.key,
    required this.docId,
    required this.id,
    this.direction = Axis.vertical,
    this.recommendedId,
  });

  @override
  State<ParkingBox> createState() => _ParkingBoxState();
}

class _ParkingBoxState extends State<ParkingBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _blinkColor;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _blinkColor = ColorTween(
      begin: Colors.green, // อาจจะต้องปรับสีนี้ตาม Theme
      end: Colors.yellow,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _ensureBlinking(bool shouldBlink) {
    if (shouldBlink) {
      if (!_controller.isAnimating) {
        _controller.repeat(reverse: true);
      }
    } else {
      if (_controller.isAnimating) {
        _controller.stop();
      }
    }
  }

  String _getElapsedTime(Timestamp startTime) {
    final now = DateTime.now();
    final started = startTime.toDate();
    final diff = now.difference(started);
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    if (hours > 0) return '$hours ชม. $minutes นาที';
    return '$minutes นาที';
  }

  // --- สร้าง Helper function สำหรับวาดกล่อง ---
  Widget _buildBox(Color color, {Color textColor = Colors.white}) {
    return Container(
      width: widget.direction == Axis.vertical ? 30 : 45,
      height: widget.direction == Axis.vertical ? 45 : 30,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
        ), // ลดความเข้มขอบ
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: FittedBox(
        child: Text(
          '${widget.id}',
          style: TextStyle(color: textColor, fontSize: 12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ดึง uid ของผู้ใช้ปัจจุบัน (อาจจะเป็น null ถ้ายังไม่ login)
    final String? currentUid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('parking_spots')
              .doc(widget.docId)
              .snapshots(),
      builder: (context, snapshot) {
        // =================================================================
        //  VVV      1. จัดการ Offline/Loading View      VVV
        // =================================================================
        // ถ้ายังไม่มีข้อมูล (กำลังโหลด หรือ offline)
        if (snapshot.connectionState == ConnectionState.waiting ||
            !snapshot.hasData ||
            snapshot.data!.data() == null) {
          // ใช้สีเทาที่เข้ากับ Theme
          final offlineColor =
              Theme.of(context).brightness == Brightness.light
                  ? Colors.grey.shade300
                  : Colors.grey.shade800;
          final offlineTextColor =
              Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;
          return _buildBox(offlineColor, textColor: offlineTextColor);
        }

        // ถ้า Error (เช่น ไม่มี permission หรือ offline นานๆ)
        if (snapshot.hasError) {
          return _buildBox(Colors.black, textColor: Colors.red); // แสดงเป็นสีดำ
        }
        // =================================================================

        // --- ถ้ามีข้อมูล (Online) ---
        final data = snapshot.data!.data() as Map<String, dynamic>;
        final String status = (data['status'] ?? 'available') as String;
        final Timestamp? startTime = data['start_time'] as Timestamp?;
        final String? holdBy = data['hold_by'] as String?;

        final bool isRecommended = widget.recommendedId == widget.id;
        final bool blink = isRecommended;

        Color baseColor;
        switch (status) {
          case 'available':
            baseColor = Colors.green;
            break;
          case 'occupied':
            baseColor = Colors.red;
            break;
          case 'unavailable':
            baseColor = Colors.grey;
            break;

          // =================================================================
          //  VVV      2. จัดการ Anonymous View (held)      VVV
          // =================================================================
          case 'held':
            // ถ้า login อยู่ และเป็นคนจอง ให้แสดงสีส้ม
            if (currentUid != null && holdBy == currentUid) {
              baseColor = Colors.orange;
            } else {
              // ถ้าไม่ login หรือเป็นคนอื่นจอง ให้แสดงเป็นสีเขียว
              baseColor = Colors.green;
            }
            break;
          // =================================================================

          default:
            baseColor = Colors.black;
        }

        _ensureBlinking(blink);

        // --- ส่วน GestureDetector (เหมือนเดิม) ---
        return GestureDetector(
          onTap: () {
            if (status == 'occupied' && startTime != null) {
              final elapsed = _getElapsedTime(startTime);
              showDialog(
                context: context,
                builder:
                    (_) => AlertDialog(
                      title: Text('ช่อง ${widget.id}'),
                      content: Text('ใช้งานมาแล้ว: $elapsed'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('ปิด'),
                        ),
                      ],
                    ),
              );
            }
          },
          child:
              blink
                  ? AnimatedBuilder(
                    animation: _blinkColor,
                    builder:
                        (_, __) => _buildBox(
                          _blinkColor.value ?? Colors.green,
                        ), // ใช้ _buildBox
                  )
                  : _buildBox(baseColor), // ใช้ _buildBox
        );
      },
    );
  }
}
