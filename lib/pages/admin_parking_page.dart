import 'package:flutter/material.dart';
import 'package:mtproject/models/admin_parking_map_layout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mtproject/pages/login_page.dart';

class AdminParkingPage extends StatelessWidget {
  const AdminParkingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Parking Map"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'ออกจากระบบ',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: const AdminParkingMapLayout(),
    );
  }
}
