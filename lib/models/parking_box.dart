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
      // ความเร็วกระพริบ ปรับได้
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // เปลี่ยนสีจาก "เขียว -> เหลือง" แล้ว reverse กลับเป็น "เขียว"
    _blinkColor = ColorTween(
      begin: Colors.green,
      end: Colors.yellow,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // เรียกทุกครั้งที่ prop เปลี่ยน เพื่อ start/stop ตามสถานะ blink
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('parking_spots')
          .doc(widget.docId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.data() == null) {
          return const SizedBox(width: 30, height: 45);
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final String status = (data['status'] ?? 'available') as String;
        final Timestamp? startTime = data['start_time'] as Timestamp?;
        final String? holdBy = data['hold_by'] as String?;
        final String? currentUid = FirebaseAuth.instance.currentUser?.uid;

        final bool isRecommended = widget.recommendedId == widget.id;

        // ถ้าอยากให้กระพริบเฉพาะ "ที่จองของฉัน" ให้ใช้บรรทัดล่างแทน:
        // final bool blink = status == 'held' && holdBy != null && currentUid != null && holdBy == currentUid && isRecommended;

        // จากคำขอ: กดค้นหาแล้วอยากให้ "ช่องที่ถูกแนะนำ" กระพริบเขียว↔เหลือง
        final bool blink = isRecommended;

        // base color ตามสถานะ (ใช้ตอน "ไม่กระพริบ")
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
          case 'held':
            baseColor = Colors.amber.shade700;
            break;
          default:
            baseColor = Colors.black;
        }

        // คุมแอนิเมชันตาม blink
        _ensureBlinking(blink);

        Widget box(Color color) {
          return Container(
            width: widget.direction == Axis.vertical ? 30 : 45,
            height: widget.direction == Axis.vertical ? 45 : 30,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: FittedBox(
              child: Text(
                '${widget.id}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          );
        }

        final child = GestureDetector(
          onTap: () {
            if (status == 'occupied' && startTime != null) {
              final elapsed = _getElapsedTime(startTime);
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
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
          child: blink
              // โหมด "กระพริบ": ใช้สีจากทวีน (เขียว↔เหลือง)
              ? AnimatedBuilder(
                  animation: _blinkColor,
                  builder: (_, __) => box(_blinkColor.value ?? Colors.green),
                )
              // โหมดปกติ: ใช้สีฐานตามสถานะจริง
              : box(baseColor),
        );

        return child;
      },
    );
  }
}
