// lib/pages/edit_profile_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mtproject/services/firebase_service.dart'; // ตรวจสอบว่า import ถูกต้อง

class EditProfilePage extends StatefulWidget {
  // 1. เพิ่ม parameter เพื่อรับค่าปัจจุบัน
  final String currentName;
  final String currentEmail;

  // 2. แก้ไข Constructor ให้รับค่าเข้ามา
  const EditProfilePage({
    super.key,
    required this.currentName,
    required this.currentEmail,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController
  _emailController; // ใช้สำหรับแสดงผล ไม่ควรให้แก้ไขตรงๆ
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 3. ใช้ค่าที่รับมาเป็นค่าเริ่มต้นของ Controller
    _nameController = TextEditingController(text: widget.currentName);
    _emailController = TextEditingController(text: widget.currentEmail);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          // อัปเดตเฉพาะชื่อใน Firestore
          await _firebaseService.updateUserProfile(
            user.uid,
            _nameController.text,
          );

          // พิจารณา: การอัปเดต Email ใน Auth ต้องมีการยืนยันตัวตนใหม่
          // และอาจจะต้องส่ง Email verification
          // if (_emailController.text != user.email) {
          //   await user.verifyBeforeUpdateEmail(_emailController.text);
          //   // แจ้งให้ผู้ใช้ไปเช็ค Email เพื่อยืนยัน
          // }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('บันทึกข้อมูลโปรไฟล์สำเร็จ')),
            );
            // ส่งค่า true กลับไปบอกหน้า Profile ว่ามีการเปลี่ยนแปลง
            Navigator.pop(context, true);
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
          }
        } finally {
          if (mounted) {
            setState(() => _isLoading = false);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('แก้ไขโปรไฟล์')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'ชื่อ'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกชื่อ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'อีเมล (ไม่สามารถแก้ไขได้)', // แจ้งผู้ใช้
                ),
                readOnly: true, // ทำให้แก้ไขไม่ได้
                // validator: ... (ถ้าต้องการ validate email)
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: _saveProfile,
                    child: const Text('บันทึก'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
