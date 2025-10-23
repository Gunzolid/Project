// lib/theme_manager.dart
import 'package:flutter/material.dart';

// สร้าง ValueNotifier สำหรับเก็บ ThemeMode ปัจจุบัน
// ThemeMode.system คือค่าเริ่มต้น (ตามระบบ)
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);
