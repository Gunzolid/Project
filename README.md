# mtproject (ระบบค้นหาที่จอดรถอัจฉริยะ)

โปรเจกต์ Flutter นี้เป็นแอปพลิเคชันสำหรับระบบค้นหาที่จอดรถอัจฉริยะ (Smart Parking Finder) ที่เชื่อมต่อกับ Firebase แอปนี้ช่วยให้ผู้ใช้สามารถค้นหาและจองช่องจอดรถที่ว่างได้แบบเรียลไทม์ และมีส่วนสำหรับผู้ดูแลระบบ (Admin) เพื่อใช้จัดการสถานะของที่จอดรถทั้งหมด

## คุณสมบัติหลัก

### 👤 สำหรับผู้ใช้งานทั่วไป (User)

  * **ระบบสมาชิก:** รองรับการลงทะเบียน (Sign Up) และเข้าสู่ระบบ (Login) ผ่าน Firebase Authentication
  * **ค้นหาที่จอดรถ:** ค้นหาช่องจอดที่ว่างและเหมาะสมที่สุด โดยเรียกใช้ Firebase Cloud Function (`recommendAndHold`) เพื่อประมวลผล
  * **จองช่องจอด (Hold):** เมื่อระบบแนะนำช่องจอดให้ แอปจะทำการ "จอง" ช่องนั้นไว้สำหรับผู้ใช้เป็นเวลา 15 นาที
  * **แผนผังเรียลไทม์:** ดูสถานะของช่องจอดทั้งหมด 52 ช่อง (ว่าง, ไม่ว่าง, กำลังจอง) ได้แบบสดๆ ผ่านการเชื่อมต่อ Stream กับ Cloud Firestore
  * **ยกเลิกการจอง:** ผู้ใช้สามารถกดยกเลิกการจองช่องจอดของตนเองได้ตลอดเวลา
  * **ตรวจสอบการจองค้าง:** หากผู้ใช้ปิดแอปไปในขณะที่ยังมีช่องจอดที่จองไว้ เมื่อเปิดแอปใหม่ ระบบจะตรวจพบและแสดงสถานะการจองนั้นต่อทันที
  * **Dark Mode:** แอปพลิเคชันรองรับการเปลี่ยน Theme ระหว่างโหมดสว่าง (Light) และโหมดมืด (Dark)

### 👑 สำหรับผู้ดูแลระบบ (Admin)

  * **การตรวจสอบ Role:** เมื่อเข้าสู่ระบบ แอปจะตรวจสอบ `role` จาก Firestore ถ้าเป็น 'admin' จะถูกส่งไปยังหน้าสำหรับผู้ดูแล
  * **จัดการสถานะ:** ผู้ดูแลสามารถสั่ง "เปิดทั้งหมด" (set all to 'available') หรือ "ปิดทั้งหมด" (set all to 'unavailable') ได้ในปุ่มเดียว
  * **อัปเดตแบบ Batch:** การอัปเดตสถานะทั้งหมดจะถูกส่งไปทำงานแบบ Batch Write เพื่อประสิทธิภาพสูงสุด

## 🛠️ เทคโนโลยีที่ใช้

  * **Frontend:** Flutter
  * **Backend & Database:** Firebase
      * **Firebase Authentication:** สำหรับระบบสมาชิก (Login/Register)
      * **Cloud Firestore:** สำหรับเก็บข้อมูลสถานะที่จอดรถและข้อมูลผู้ใช้ (เช่น role)
      * **Firebase Cloud Functions:** สำหรับประมวลผล Logic การแนะนำที่จอดรถ (`recommendAndHold`)
  * **Assets:**
      * `assets/parking_map.png`: ภาพแผนผังที่จอดรถที่ใช้เป็นพื้นหลัง
  * **Dependencies (จาก `pubspec.yaml`):**
      * `firebase_core`: สำหรับเชื่อมต่อ Firebase
      * `cloud_firestore`: สำหรับฐานข้อมูล
      * `firebase_auth`: สำหรับการยืนันตัวตน
      * `cloud_functions`: สำหรับเรียกใช้ Cloud Function
      * `geolocator`: สำหรับการระบุตำแหน่ง
      * `url_launcher`: สำหรับการเปิด URL
      * `email_validator`: สำหรับตรวจสอบความถูกต้องของอีเมล

## 🚀 การติดตั้งและเริ่มใช้งาน

1.  **Clone โปรเจกต์:**
    ```bash
    git clone [YOUR_REPOSITORY_URL]
    cd mtproject
    ```
2.  **ตั้งค่า Firebase:**
      * โปรเจกต์นี้จำเป็นต้องเชื่อมต่อกับ Firebase
      * คุณต้องสร้างโปรเจกต์ Firebase ของคุณเอง และตั้งค่า `firebase_options.dart` (ซึ่งมีอยู่ในโปรเจกต์แล้ว)
      * คุณต้อง Deploy Firebase Cloud Function ที่ชื่อ `recommendAndHold` (โค้ดอยู่ในโฟลเดอร์ `functions`)
      * คุณต้องตั้งค่า Cloud Firestore Database ให้มี collections `parking_spots` (สำหรับเก็บข้อมูลช่องจอด 52 ช่อง) และ `users` (สำหรับเก็บข้อมูลผู้ใช้และ role)
3.  **ติดตั้ง Dependencies:**
    ```bash
    flutter pub get
    ```
4.  **รันแอปพลิเคชัน:**
    ```bash
    flutter run
    ```

## 📂 โครงสร้างไฟล์ที่สำคัญ

  * `lib/main.dart`: จุดเริ่มต้นของแอป, จัดการ Theme (Light/Dark Mode) และ `AuthChecker` เพื่อแยกระหว่าง User กับ Admin
  * `lib/pages/home_page.dart`: หน้าหลักสำหรับผู้ใช้ (แสดงแผนผัง, ค้นหา, ยกเลิกการจอง)
  * `lib/pages/admin_parking_page.dart`: หน้าหลักสำหรับ Admin (จัดการสถานะที่จอด)
  * `lib/pages/searching_page.dart`: หน้าจอ "กำลังค้นหา..." ที่เรียกใช้ Cloud Function
  * `lib/services/firebase_parking_service.dart`: Service หลักฝั่ง Client สำหรับจัดการข้อมูลที่จอดรถ (ดึงข้อมูล, อัปเดต, ติดตามสถานะ, ยกเลิกจอง)
  * `lib/services/parking_functions.dart`: โค้ดสำหรับเรียกใช้ Firebase Cloud Function `recommendAndHold`
  * `lib/data/layout_xy.dart`: เก็บข้อมูลพิกัด (X, Y) ของช่องจอดทั้ง 52 ช่องสำหรับแสดงบนแผนผัง
  * `pubspec.yaml`: ไฟล์ที่ระบุ Dependencies ทั้งหมดของโปรเจกต์ และ assets ที่ใช้
