import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

    if (hours > 0) {
      return '$hours ชม. ${minutes} นาที';
    } else {
      return '$minutes นาที';
    }
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
        final status = data['status'] ?? 'available';
        final startTime = data['start_time'];
        final isRecommended = widget.recommendedId == widget.id;

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
          default:
            baseColor = Colors.black;
        }

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final blinkColor = isRecommended
                ? Color.alphaBlend(_colorAnimation.value!, baseColor)
                : baseColor;

            return GestureDetector(
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
                        )
                      ],
                    ),
                  );
                }
              },
              child: Container(
                width: widget.direction == Axis.vertical ? 30 : 45,
                height: widget.direction == Axis.vertical ? 45 : 30,
                decoration: BoxDecoration(
                  color: blinkColor,
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
