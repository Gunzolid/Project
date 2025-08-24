import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminParkingBox extends StatelessWidget {
  final String docId;
  final int id;
  final Axis direction;

  const AdminParkingBox({
    super.key,
    required this.docId,
    required this.id,
    this.direction = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('parking_spots')
          .doc(docId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(width: 30, height: 45);
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final status = data['status'] ?? 'unknown';

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
          onTap: () => _toggleStatus(docId, status),
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
              child: Text(
                '$id',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
      },
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
