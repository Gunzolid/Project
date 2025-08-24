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
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _colorAnimation = ColorTween(
      begin: Colors.yellow,
      end: Colors.transparent,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getElapsedTime(Timestamp startTime) {
    final now = DateTime.now();
    final started = startTime.toDate();
    final diff = now.difference(started);
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    if (hours > 0) return '$hours ชม. ${minutes} นาที';
    return '$minutes นาที';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
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

        // เงื่อนไข: เป็นช่องที่ถูกแนะนำ "ของฉัน" จริง ๆ (held + hold_by เป็น uid ของฉัน + id ตรง)
        bool isMyHeldRecommended() {
          return status == 'held' &&
              holdBy != null &&
              currentUid != null &&
              holdBy == currentUid &&
              isRecommended;
        }

        // base color ตามสถานะ
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
            // ถูกจับจองอยู่ (ถ้าเป็นของเรา เดี๋ยวจะมี overlay กระพริบ)
            baseColor = Colors.amber.shade700;
            break;
          default:
            baseColor = Colors.black;
        }

        final bool blink = isMyHeldRecommended();

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // ถ้า blink ให้ overlay สีเหลืองโปร่งใสสลับ เพื่อเอฟเฟกต์กระพริบ
            final Color renderColor =
                blink
                    ? Color.alphaBlend(_colorAnimation.value!, baseColor)
                    : baseColor;

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
              child: Container(
                width: widget.direction == Axis.vertical ? 30 : 45,
                height: widget.direction == Axis.vertical ? 45 : 30,
                decoration: BoxDecoration(
                  color: renderColor,
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
              ),
            );
          },
        );
      },
    );
  }
}
