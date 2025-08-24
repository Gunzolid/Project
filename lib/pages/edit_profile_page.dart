import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mtproject/services/firebase_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }

  Future<void> _loadCurrentProfile() async {
    var userProfile = await FirebaseService().getUserProfile();

    if (userProfile != null) {
      setState(() {
        _nameController.text = userProfile['name'] ?? "";
        _emailController.text = userProfile['email'] ?? "";
      });
    }
  }

  Future<void> _saveProfile() async {
    await FirebaseService().updateUserProfile(
      _nameController.text,
      _emailController.text,
    );

    Navigator.pop(context); // กลับไปหน้า Profile
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("แก้ไขโปรไฟล์")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("ชื่อผู้ใช้"),
            TextField(controller: _nameController),
            const SizedBox(height: 20),
            const Text("อีเมล"),
            TextField(controller: _emailController),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveProfile,
                child: const Text("บันทึก"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
