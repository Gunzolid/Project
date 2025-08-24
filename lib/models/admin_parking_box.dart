import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mtproject/services/firebase_parking_service.dart';

class AdminParkingBox extends StatelessWidget {
  final String docId;
  final int id;
  final Axis direction;
  AdminParkingBox({
    super.key,
    required this.docId,
    required this.id,
    this.direction = Axis.vertical,
  });

  final _svc = FirebaseParkingService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('parking_spots')
              .doc(docId)
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data?.data() == null) {
          return const SizedBox(width: 30, height: 45);
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final status = (data['status'] ?? 'unknown') as String;

        Color color;
        switch (status) {
          case 'available':
            color = Colors.green;
            break;
          case 'occupied':
            color = Colors.red;
            break;
          case 'unavailable':
            color = Colors.grey;
            break;
          default:
            color = Colors.black;
        }

        return GestureDetector(
          onTap: () async {
            try {
              final next = _nextStatus(status);
              await _svc.setStatus(docId, next);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('เปลี่ยนสถานะไม่สำเร็จ: $e')),
              );
            }
          },
          child: Container(
            width: direction == Axis.vertical ? 30 : 45,
            height: direction == Axis.vertical ? 45 : 30,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: FittedBox(
              child: Text('$id', style: const TextStyle(color: Colors.white)),
            ),
          ),
        );
      },
    );
  }

  String _nextStatus(String current) {
    if (current == 'available') return 'occupied';
    if (current == 'occupied') return 'unavailable';
    return 'available'; // รวมกรณี unavailable/unknown → available
  }
}
