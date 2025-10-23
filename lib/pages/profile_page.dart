import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mtproject/pages/edit_profile_page.dart';
import 'package:mtproject/pages/login_page.dart';
// 1. Import theme manager
import 'package:mtproject/services/theme_manager.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = '';
  String email = '';
  bool isLoading = true;

  Future<void> fetchUserData() async {
    // ทำให้ State อัปเดตเมื่อข้อมูลมาถึง (แม้จะเกิด error)
    // เพิ่มการตรวจสอบ mounted ก่อน setState
    setState(() => isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    Map<String, dynamic>? data;
    if (user != null) {
      try {
        final doc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();
        if (doc.exists) {
          data = doc.data();
        }
      } catch (e) {
        print("Error fetching user data: $e");
        // อาจจะแสดง SnackBar แจ้งเตือนผู้ใช้
      }
    }
    if (mounted) {
      setState(() {
        name = data?['name'] ?? '';
        // ควรใช้ email จาก Auth โดยตรงจะปลอดภัยกว่า
        email = user?.email ?? data?['email'] ?? '';
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    // ใช้ ValueListenableBuilder เพื่อให้ Icon และปุ่มเปลี่ยนสีตาม Theme
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, currentMode, __) {
        // กำหนดสีไอคอนตาม Theme ปัจจุบัน
        final iconColor =
            Theme.of(context).iconTheme.color ??
            (currentMode == ThemeMode.dark ? Colors.white70 : Colors.black54);

        return Scaffold(
          appBar: AppBar(title: const Text("Profile")),
          // เปลี่ยนเป็น ListView เพื่อให้เลื่อนได้ ถ้า Widget เยอะ
          body: ListView(
            // <-- เปลี่ยนเป็น ListView
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            children: [
              Icon(
                Icons.account_circle,
                size: 100,
                color: iconColor,
              ), // <-- ใช้ iconColor
              const SizedBox(height: 20),
              if (isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ) // <-- แสดง Loading กลางจอ
              else
                Column(
                  children: [
                    Text(
                      name,
                      style:
                          Theme.of(
                            context,
                          ).textTheme.headlineSmall, // ใช้ TextTheme
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style:
                          Theme.of(
                            context,
                          ).textTheme.bodyMedium, // ใช้ TextTheme
                    ),
                  ],
                ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                // <-- เพิ่ม icon ให้ปุ่ม
                icon: const Icon(Icons.edit, color: Colors.white),
                label: const Text(
                  "แก้ไขโปรไฟล์",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  // <-- ทำให้เป็น async
                  final result = await Navigator.push<bool>(
                    // <-- รับค่า bool กลับมา
                    context,
                    MaterialPageRoute(
                      // ส่งค่าปัจจุบันไปด้วย เพื่อให้หน้า Edit แสดงค่าเริ่มต้น
                      builder:
                          (context) => EditProfilePage(
                            currentName: name,
                            currentEmail: email,
                          ),
                    ),
                  );
                  // ถ้ามีการแก้ไข (result == true) ให้โหลดข้อมูลใหม่
                  if (result == true && mounted) {
                    fetchUserData();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors
                          .blue, // พิจารณาใช้ Theme.of(context).colorScheme.primary
                  minimumSize: const Size(200, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),

              // =================================================================
              //  VVV      2. เพิ่ม Switch สลับ Theme ตรงนี้      VVV
              // =================================================================
              const SizedBox(height: 15), // เพิ่มระยะห่าง
              SwitchListTile(
                // ใช้ค่าจาก ValueListenableBuilder ด้านบน
                title: const Text('โหมดกลางคืน'),
                value: currentMode == ThemeMode.dark,
                onChanged: (value) {
                  // อัปเดตค่าใน themeNotifier
                  themeNotifier.value =
                      value ? ThemeMode.dark : ThemeMode.light;
                },
                secondary: Icon(
                  currentMode == ThemeMode.dark
                      ? Icons.dark_mode_outlined
                      : Icons.light_mode_outlined,
                  color: iconColor, // <-- ใช้ iconColor
                ),
              ),

              // =================================================================
              const SizedBox(height: 15),
              ElevatedButton.icon(
                // <-- เพิ่ม icon ให้ปุ่ม
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  "ออกจากระบบ",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors
                          .red, // พิจารณาใช้ Theme.of(context).colorScheme.error
                  minimumSize: const Size(200, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
