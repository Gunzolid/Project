import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mtproject/pages/login_page.dart';
import 'package:mtproject/pages/home_page.dart';
import 'package:mtproject/pages/admin_parking_page.dart';
import 'firebase_options.dart';
import 'package:mtproject/services/theme_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. ใช้ ValueListenableBuilder ครอบ MaterialApp
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier, // ฟังการเปลี่ยนแปลงจาก themeNotifier
      builder: (_, currentMode, __) {
        // currentMode คือ ThemeMode ปัจจุบัน
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          // Theme สว่าง
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),

          // Theme มืด
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),

          // 3. ตั้งค่า themeMode ตามค่าที่ได้จาก ValueListenableBuilder
          themeMode: currentMode,

          home: const AuthChecker(),
        );
      },
    );
  }
}

// ... (AuthChecker เหมือนเดิม) ...
class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  Future<Widget> _getStartPage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const LoginPage();

    final uid = user.uid;
    final docSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final role =
        docSnapshot.exists ? (docSnapshot.data()?['role'] ?? 'user') : 'user';

    if (role == 'admin') {
      return const AdminParkingPage();
    } else {
      return const HomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _getStartPage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('เกิดข้อผิดพลาดในการโหลดข้อมูลผู้ใช้')),
          );
        }
        if (snapshot.hasData) {
          return snapshot.data!;
        }
        return const LoginPage();
      },
    );
  }
}
