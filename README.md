diff --git a/README.md b/README.md
index 2aa62ee4a87d89cc2f119444592df2375a328fcb..af4070782956e3c90a6b71ca9c1a07a8655458fb 100644
--- a/README.md
+++ b/README.md
@@ -1,16 +1,419 @@
-# mtproject
+# Smart Parking Flutter App
 
-A new Flutter project.
+## Table of Contents
+- [English](#english)
+  - [Project Overview](#project-overview)
+  - [Key Features](#key-features)
+  - [Architecture](#architecture)
+  - [Tech Stack](#tech-stack)
+  - [Prerequisites](#prerequisites)
+  - [Setup & Installation](#setup--installation)
+  - [Running & Building](#running--building)
+  - [Configuration](#configuration)
+  - [Folder Structure](#folder-structure)
+  - [API Endpoints](#api-endpoints)
+  - [IoT Firmware (C++)](#iot-firmware-c)
+  - [Screenshots / Demo](#screenshots--demo)
+  - [Testing](#testing)
+  - [CI/CD](#cicd)
+  - [Roadmap / TODO](#roadmap--todo)
+  - [Known Issues & Troubleshooting](#known-issues--troubleshooting)
+  - [Contributing Guidelines](#contributing-guidelines)
+  - [License](#license)
+  - [Changelog](#changelog)
+- [ภาษาไทย](#ภาษาไทย)
+  - [Project Overview](#project-overview-1)
+  - [Key Features](#key-features-1)
+  - [Architecture](#architecture-1)
+  - [Tech Stack](#tech-stack-1)
+  - [Prerequisites](#prerequisites-1)
+  - [Setup & Installation](#setup--installation-1)
+  - [Running & Building](#running--building-1)
+  - [Configuration](#configuration-1)
+  - [Folder Structure](#folder-structure-1)
+  - [API Endpoints](#api-endpoints-1)
+  - [IoT Firmware (C++)](#iot-firmware-c-1)
+  - [Screenshots / Demo](#screenshots--demo-1)
+  - [Testing](#testing-1)
+  - [CI/CD](#cicd-1)
+  - [Roadmap / TODO](#roadmap--todo-1)
+  - [Known Issues & Troubleshooting](#known-issues--troubleshooting-1)
+  - [Contributing Guidelines](#contributing-guidelines-1)
+  - [License](#license-1)
+  - [Changelog](#changelog-1)
 
-## Getting Started
+## English
 
-This project is a starting point for a Flutter application.
+### Project Overview
+A Flutter-based smart parking application that integrates Firebase Authentication, Firestore, and Cloud Functions to orchestrate real-time parking spot availability for drivers and administrators. The app renders an interactive parking map, reserves spots on demand, streams occupancy updates, and routes users based on their roles. An external IoT firmware (not yet committed) is expected to publish bay telemetry to Firestore.
 
-A few resources to get you started if this is your first Flutter project:
+### Key Features
+- Email/password authentication with automatic Firestore profile provisioning and role-based routing between public home and admin consoles.
+- Interactive parking-lot layout (`ParkingMapLayout`) with zoom/pan, live Firestore streams, and highlight of held spots.
+- One-tap reservation flow (`SearchingPage`) invoking the `recommendAndHold` Cloud Function and surfacing recommended bays via `showRecommendDialog`.
+- Real-time hold monitoring (`FirebaseParkingService.watchRecommendation`) that cancels holds when they expire, are revoked, or the spot becomes occupied.
+- Google Maps deep-linking (`openGoogleMapsToPSUPK`) from recommendations for turn-by-turn navigation to PSU Phuket Building 6.
+- Admin dashboard (`AdminParkingPage`) with per-slot cycling across `available → occupied → unavailable → available`, batched “set all” controls, and automatic hold cleanup via Cloud Functions triggers.
+- Profile management (rename, theme toggle, account deletion, logout) and theme persistence through a global `ValueNotifier<ThemeMode>`.
+- Cloud Functions v2 codebase handling recommendations, email synchronization, and hold cleanup, with Node 20 runtime support.
 
-- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
-- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
+### Architecture
+- **Presentation layer**: Flutter `pages/` for login, signup, home, search, admin, profile, and edit profile flows. `ui/recommend_dialog.dart` encapsulates modal UX.
+- **State & services**: `services/` contains Firebase integration (`FirebaseParkingService`, `FirebaseService`, `ParkingFunctions`, `UserBootstrap`, `theme_manager`). Logic subscribes to Firestore streams and callable Cloud Functions.
+- **Models**: Layout metadata (`models/parking_layout_config.dart`, `parking_map_layout.dart`, `admin_parking_map_layout.dart`) and helper classes (e.g., Google Maps directions).
+- **Data flow**: Flutter widgets read/write Firestore collections (`parking_spots`, `users`) and call Cloud Functions. Firestore triggers enforce data consistency (hold cleanup, email sync). IoT firmware (C++) will ultimately push occupancy data to `parking_spots` via REST/SDK once integrated.
+- **IoT boundary**: Firmware runs outside this repo; the mobile app expects consistent document schemas and spot IDs published by the device network.
 
-For help getting started with Flutter development, view the
-[online documentation](https://docs.flutter.dev/), which offers tutorials,
-samples, guidance on mobile development, and a full API reference.
+### Tech Stack
+- **Frontend**: Flutter 3.x / Dart >= 3.7 (`environment.sdk ^3.7.0`), Material 3 UI.
+- **Packages**: `firebase_core`, `firebase_auth`, `cloud_firestore`, `cloud_functions`, `geolocator`, `url_launcher`, `email_validator`, `cupertino_icons`.
+- **Backend services**: Firebase Authentication, Firestore, Cloud Functions (Node 20), Firebase Hosting (for web) if enabled.
+- **Tooling**: FlutterFire CLI (`firebase.json`, `.firebaserc`), Firebase CLI, Android Studio / Xcode, optional VS Code.
+- **Assets**: `assets/parking_map.png` for map reference.
+
+### Prerequisites
+- Flutter SDK 3.27+ (or any release bundling Dart 3.7.0) and matching Dart SDK.
+- Android Studio (with Android SDK & emulator) and/or Xcode (with iOS simulator).
+- Node.js 20.x (for Firebase Functions dev scripts) and npm.
+- Firebase CLI (`firebase-tools`) and FlutterFire CLI (`dart pub global activate flutterfire_cli`).
+- Google Maps app installed on target device for navigation handoff.
+- Apple developer setup for iOS builds (if targeting iOS).
+
+### Setup & Installation
+```bash
+# Clone
+git clone <your-fork-or-origin-url>
+cd Project
+
+# Install Flutter dependencies
+flutter pub get
+
+# (Optional) Configure your Firebase project
+flutterfire configure --project=<your-project-id>
+
+# Install Cloud Functions dependencies
+cd functions
+npm install
+cd ..
+```
+- Replace the bundled Firebase options with your own if you are not using `project-4f636`.
+- Ensure `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`, and `web/firebase-config.js` (if web) match your Firebase apps.
+
+### Running & Building
+```bash
+# Run on a connected Android/iOS/Web device
+flutter run -d <device-id>
+
+# Build release binaries
+flutter build apk        # Android
+flutter build appbundle  # Play Store
+flutter build ios        # iOS
+flutter build web        # Web (requires Firebase hosting config)
+
+# Serve Cloud Functions locally
+npm --prefix functions run serve
+```
+- Allow location permissions on first launch to enable Google Maps integration.
+- Use `firebase emulators:start --only functions,firestore` for local end-to-end testing if desired.
+
+### Configuration
+- Generated Firebase config resides in `lib/firebase_options.dart`; update via `flutterfire configure` for new projects.
+- Mobile platform configs live in `android/app/google-services.json` and `ios/Runner/GoogleService-Info.plist` (placeholders should be replaced with your credentials if absent: `<ADD YOUR FIREBASE OPTIONS HERE>`).
+- Cloud Functions use the default project in `.firebaserc` (`project-4f636`); update for other environments.
+- Location services require Android `ACCESS_FINE_LOCATION` / `ACCESS_COARSE_LOCATION` permissions and iOS `NSLocationWhenInUseUsageDescription` entries (add or verify in platform-specific manifests).
+- Define any runtime secrets (e.g., REST API keys for IoT bridge) through `--dart-define` or platform-specific keystores once requirements are known. `<TODO: document IoT gateway credentials>`.
+
+### Folder Structure
+```
+.
+├── analysis_options.yaml
+├── assets/
+│   └── parking_map.png
+├── functions/
+│   ├── index.js
+│   ├── package.json
+│   └── (node_modules/)
+├── lib/
+│   ├── main.dart
+│   ├── firebase_options.dart
+│   ├── models/
+│   │   ├── admin_parking_map_layout.dart
+│   │   ├── parking_layout_config.dart
+│   │   ├── parking_map_layout.dart
+│   │   └── directions.dart
+│   ├── pages/
+│   │   ├── admin_parking_page.dart
+│   │   ├── home_page.dart
+│   │   ├── login_page.dart
+│   │   ├── profile_page.dart
+│   │   ├── sign_up_page.dart
+│   │   ├── searching_page.dart
+│   │   └── edit_profile_page.dart
+│   ├── services/
+│   │   ├── firebase_parking_service.dart
+│   │   ├── firebase_service.dart
+│   │   ├── parking_functions.dart
+│   │   ├── theme_manager.dart
+│   │   └── user_bootstrap.dart
+│   └── ui/
+│       └── recommend_dialog.dart
+├── test/
+│   └── widget_test.dart
+├── android/ ios/ macos/ linux/ windows/ web/
+└── firebase.json / .firebaserc
+```
+
+### API Endpoints
+- **Callable Cloud Function**: `recommendAndHold` (HTTP callable) selects the next available spot, reserves it, and returns `{docId, id, hold_expires_at}`.
+- **Firestore triggers**:
+  - `onSpotTaken` clears hold metadata when status changes to `occupied` or `unavailable`.
+  - `syncAuthEmailToFirestoreOnUpdate` enforces email parity between Auth and Firestore user docs.
+- **Firestore collections**:
+  - `parking_spots`: documents keyed by numeric ID strings containing `status`, `hold_by`, `hold_until`, `start_time`.
+  - `users`: stores profile metadata (`name`, `email`, `role`, timestamps) for routing and profiles.
+- **External integrations**: IoT firmware is expected to update `parking_spots`; confirm REST/SDK endpoints once firmware is available. `<TODO: document IoT publish API>`.
+
+### IoT Firmware (C++)
+- **Repository**: Not yet committed. `<TODO: add firmware repo link/path>`.
+- **Hardware target**: Anticipated ESP32/ESP8266-class microcontroller with Wi-Fi for Firebase connectivity. `<CONFIRM HARDWARE>`.
+- **Sensors**: Likely ultrasonic or magnetic vehicle presence sensors per bay. `<CONFIRM SENSOR TYPE>`.
+- **Connectivity**: Preferred over Wi-Fi using Firebase REST API or HTTPS Cloud Function bridge; BLE/serial gateway optional. `<DECIDE COMM CHANNEL>`.
+- **Message format**: Expected JSON payload mapping spot IDs to statuses (`available|occupied|unavailable|held`) and timestamps. `<DEFINE EXACT SCHEMA>`.
+- **Synchronization**: Firmware should debounce occupancy changes and update Firestore `parking_spots` documents; mobile app reacts via streams.
+- **Provisioning**: Secure credentials via environment variables or secrets manager; avoid hardcoding tokens in firmware.
+
+### Screenshots / Demo
+| Screen | Description | Asset |
+| --- | --- | --- |
+| Home (Driver) | Interactive lot map with availability overlay | `<ADD IMAGE>` |
+| Recommendation Dialog | Suggested bay with Google Maps CTA | `<ADD IMAGE>` |
+| Admin Dashboard | Slot management controls | `<ADD IMAGE>` |
+| Profile | Theme toggle and account actions | `<ADD IMAGE>` |
+
+### Testing
+```bash
+# Flutter widget/unit tests
+flutter test
+
+# Cloud Functions lint
+npm --prefix functions run lint
+```
+- Add integration tests for reservation flows and Firestore interactions. `<TODO: expand automated test coverage>`.
+
+### CI/CD
+- No automated pipeline is defined yet (no `.github/workflows`). Consider adding GitHub Actions for `flutter test` and Cloud Functions linting. `<TODO: set up CI>`.
+
+### Roadmap / TODO
+- Integrate and document the IoT firmware repository, message schema, and deployment steps.
+- Add driver push notifications for hold expirations and spot releases.
+- Implement analytics/usage metrics dashboards for admins.
+- Write integration/widget tests for authentication, reservations, and admin flows.
+- Configure GitHub Actions or other CI/CD for automated testing and deployments.
+- Localize UI strings (Thai/English) via Flutter `intl` or `flutter_localizations` packages.
+
+### Known Issues & Troubleshooting
+- **Missing Firebase config**: Update `firebase_options.dart` and platform config files if the bundled project is not accessible; otherwise Firebase init will fail.
+- **Location permission denied**: `openGoogleMapsToPSUPK` throws when GPS or permissions are disabled; instruct users to enable services.
+- **Cloud Function errors**: Ensure `functions/index.js` is deployed and Node 20 runtime is selected; check Firebase logs when `recommendAndHold` returns `{ok: false}`.
+- **Hold conflicts**: Users already holding a spot receive “Already has a held spot”; provide UI messaging or automatic release as needed.
+- **Out-of-sync roles**: Admin routing depends on `users/{uid}.role`; confirm Firestore documents contain the expected value.
+
+### Contributing Guidelines
+1. Fork the repository and create a feature branch (`git checkout -b feat/<name>`).
+2. Keep Flutter code formatted via `dart format` and adhere to `analysis_options.yaml` lints.
+3. Run `flutter test` (and `npm --prefix functions run lint` when touching Cloud Functions).
+4. Submit a PR with descriptive summary and reference any related issues or TODOs.
+
+### License
+- License file not yet provided. `<TODO: add LICENSE>`.
+
+### Changelog
+- No formal changelog maintained. Use Git history or create `CHANGELOG.md`. `<TODO: document releases>`.
+
+## ภาษาไทย
+
+### Project Overview
+แอปสมาร์ตที่จอดรถพัฒนาด้วย Flutter เชื่อมต่อ Firebase Authentication, Firestore และ Cloud Functions เพื่ออัปเดตสถานะช่องจอดแบบเรียลไทม์ทั้งฝั่งผู้ใช้ทั่วไปและผู้ดูแลระบบ แอปรวมแผนที่ที่จอดรถแบบโต้ตอบ ระบบจองช่องอัตโนมัติ และการนำทางไปยังอาคารปลายทาง พร้อมคาดหวังให้มีเฟิร์มแวร์ IoT (ยังไม่อยู่ในที่เก็บนี้) ส่งข้อมูลการใช้งานจริงเข้าสู่ Firestore
+
+### Key Features
+- เข้าสู่ระบบ/สมัครสมาชิกด้วยอีเมลและรหัสผ่าน สร้างข้อมูลผู้ใช้ใน Firestore อัตโนมัติ และนำทางตามบทบาท (หน้า Home หรือแดชบอร์ดผู้ดูแล)
+- แผนผังที่จอด (`ParkingMapLayout`) ซูม/เลื่อนได้ พร้อมข้อมูลสถานะจาก Firestore แบบสด และไฮไลต์ช่องที่ถูกจอง
+- ขั้นตอนค้นหาและจองช่อง (`SearchingPage`) เรียกใช้ Cloud Function `recommendAndHold` และแสดงผลผ่าน `showRecommendDialog`
+- การติดตามสถานะการจองแบบเรียลไทม์ (`FirebaseParkingService.watchRecommendation`) ยกเลิกเมื่อหมดเวลา ถูกยกเลิก หรือเมื่อมีการเข้าจอดจริง
+- ลิงก์ไปยัง Google Maps (`openGoogleMapsToPSUPK`) เพื่อขับไปยังอาคาร 6 ม.อ.ภูเก็ตจากตำแหน่งปัจจุบัน
+- หน้าผู้ดูแล (`AdminParkingPage`) เปลี่ยนสถานะช่องแบบวนรอบ และมีปุ่มตั้งค่าทุกช่องให้ว่าง/ปิด พร้อม Cloud Function จัดการข้อมูล hold อัตโนมัติ
+- หน้าจัดการโปรไฟล์ (แก้ชื่อ เปิด/ปิดโหมดมืด ลบบัญชี ออกจากระบบ) และสลับธีมทั่วแอปผ่าน `ValueNotifier<ThemeMode>`
+- Cloud Functions เวอร์ชัน 2 สำหรับจองช่อง ซิงก์อีเมล และล้างสถานะการจอง รองรับ Node 20
+
+### Architecture
+- **ชั้นนำเสนอ**: ไฟล์ใน `pages/` สำหรับหน้าล็อกอิน สมัครสมาชิก หน้าแรก ค้นหา ผู้ดูแล โปรไฟล์ และแก้ไขชื่อ พร้อม `ui/recommend_dialog.dart` สำหรับกล่องโต้ตอบ
+- **การจัดการสถานะ/บริการ**: โค้ดใน `services/` เชื่อม Firebase (`FirebaseParkingService`, `FirebaseService`, `ParkingFunctions`, `UserBootstrap`, `theme_manager`) ดึงสตรีม Firestore และเรียก Cloud Function
+- **โมเดล**: เมทาดาทาแผนผัง (`models/parking_layout_config.dart`, `parking_map_layout.dart`, `admin_parking_map_layout.dart`) และยูทิลิตีสำหรับ Google Maps
+- **ทิศทางข้อมูล**: วิดเจ็ต Flutter อ่าน/เขียนคอลเลกชัน Firestore (`parking_spots`, `users`) และเรียก Cloud Function ทริกเกอร์ Firestore ดูแลความถูกต้องของข้อมูล (ลบ hold, ซิงก์อีเมล) ขณะที่เฟิร์มแวร์ IoT จะส่งสถานะช่องจอดเข้า `parking_spots`
+- **ขอบเขต IoT**: เฟิร์มแวร์อยู่นอกที่เก็บนี้ แต่แอปคาดหวังโครงสร้างเอกสารและหมายเลขช่องที่สอดคล้องกันจากอุปกรณ์
+
+### Tech Stack
+- **ส่วนหน้า**: Flutter 3.x / Dart >= 3.7 (`environment.sdk ^3.7.0`) พร้อม Material 3
+- **แพ็กเกจ**: `firebase_core`, `firebase_auth`, `cloud_firestore`, `cloud_functions`, `geolocator`, `url_launcher`, `email_validator`, `cupertino_icons`
+- **บริการหลังบ้าน**: Firebase Authentication, Firestore, Cloud Functions (Node 20), Firebase Hosting (หากเปิดใช้งาน Web)
+- **เครื่องมือ**: FlutterFire CLI, Firebase CLI, Android Studio / Xcode, VS Code (ตัวเลือก)
+- **ทรัพยากร**: ภาพแผนผัง `assets/parking_map.png`
+
+### Prerequisites
+- ติดตั้ง Flutter SDK 3.27+ (หรือเวอร์ชันที่มาพร้อม Dart 3.7.0) และ Dart ที่สอดคล้อง
+- ติดตั้ง Android Studio (พร้อม Android SDK/Emulator) และ/หรือ Xcode (พร้อม iOS Simulator)
+- ติดตั้ง Node.js 20.x และ npm สำหรับ Cloud Functions
+- ติดตั้ง Firebase CLI (`firebase-tools`) และ FlutterFire CLI (`dart pub global activate flutterfire_cli`)
+- มีแอป Google Maps บนอุปกรณ์สำหรับการนำทาง
+- ถ้าสร้างแอป iOS ต้องมี Apple Developer Account/Provisioning
+
+### Setup & Installation
+```bash
+# โคลนโปรเจ็กต์
+git clone <ลิงก์-repo-หรือ-fork>
+cd Project
+
+# ติดตั้งไลบรารี Flutter
+flutter pub get
+
+# (ตัวเลือก) ตั้งค่า Firebase ของคุณเอง
+flutterfire configure --project=<project-id ของคุณ>
+
+# ติดตั้งไลบรารี Cloud Functions
+cd functions
+npm install
+cd ..
+```
+- หากไม่ใช้โปรเจ็กต์ Firebase เดิม ให้แทนที่คอนฟิกทั้งหมดด้วยของคุณเอง
+- ตรวจสอบให้แน่ใจว่าไฟล์ `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`, และไฟล์เว็บ (ถ้ามี) ถูกต้อง
+
+### Running & Building
+```bash
+# รันบนอุปกรณ์ Android/iOS/Web
+flutter run -d <device-id>
+
+# สร้างไฟล์เผยแพร่
+flutter build apk        # Android
+flutter build appbundle  # สำหรับ Play Store
+flutter build ios        # iOS
+flutter build web        # Web (ต้องตั้งค่า Firebase Hosting เพิ่ม)
+
+# รัน Cloud Functions ในเครื่อง
+npm --prefix functions run serve
+```
+- เมื่อเปิดแอปครั้งแรก ให้อนุญาตสิทธิ์ตำแหน่งเพื่อใช้งาน Google Maps
+- ใช้ `firebase emulators:start --only functions,firestore` หากต้องการทดสอบครบวงจรในเครื่อง
+
+### Configuration
+- การตั้งค่า Firebase แบบอัตโนมัติอยู่ใน `lib/firebase_options.dart`; รัน `flutterfire configure` เพื่อสร้างไฟล์ใหม่หากโปรเจ็กต์ต่างกัน
+- ไฟล์คอนฟิกบนแพลตฟอร์ม (`google-services.json`, `GoogleService-Info.plist`) ต้องใส่ข้อมูลจริง หากว่างให้เติม `<ADD YOUR FIREBASE OPTIONS HERE>`
+- `.firebaserc` ระบุโปรเจ็กต์ดีฟอลต์ (`project-4f636`); เปลี่ยนตามสภาพแวดล้อมของคุณ
+- การขอสิทธิ์ตำแหน่งต้องประกาศใน `AndroidManifest.xml` และ `Info.plist` (`NSLocationWhenInUseUsageDescription`)
+- หากมีการเชื่อมต่อ IoT เพิ่มเติม ให้กำหนดคีย์/ซีเคร็ตผ่าน `--dart-define` หรือระบบจัดการความลับ `<TODO: จัดทำข้อมูลรับรอง IoT>`
+
+### Folder Structure
+```
+.
+├── analysis_options.yaml
+├── assets/
+│   └── parking_map.png
+├── functions/
+│   ├── index.js
+│   ├── package.json
+│   └── (node_modules/)
+├── lib/
+│   ├── main.dart
+│   ├── firebase_options.dart
+│   ├── models/
+│   │   ├── admin_parking_map_layout.dart
+│   │   ├── parking_layout_config.dart
+│   │   ├── parking_map_layout.dart
+│   │   └── directions.dart
+│   ├── pages/
+│   │   ├── admin_parking_page.dart
+│   │   ├── home_page.dart
+│   │   ├── login_page.dart
+│   │   ├── profile_page.dart
+│   │   ├── sign_up_page.dart
+│   │   ├── searching_page.dart
+│   │   └── edit_profile_page.dart
+│   ├── services/
+│   │   ├── firebase_parking_service.dart
+│   │   ├── firebase_service.dart
+│   │   ├── parking_functions.dart
+│   │   ├── theme_manager.dart
+│   │   └── user_bootstrap.dart
+│   └── ui/
+│       └── recommend_dialog.dart
+├── test/
+│   └── widget_test.dart
+├── android/ ios/ macos/ linux/ windows/ web/
+└── firebase.json / .firebaserc
+```
+
+### API Endpoints
+- **Cloud Function เรียกผ่านแอป**: `recommendAndHold` เลือกช่องว่างถัดไป จอง และตอบกลับ `{docId, id, hold_expires_at}`
+- **ทริกเกอร์ Firestore**:
+  - `onSpotTaken` ล้างข้อมูลการจองเมื่อสถานะเปลี่ยนเป็น `occupied` หรือ `unavailable`
+  - `syncAuthEmailToFirestoreOnUpdate` ให้ข้อมูลอีเมลใน Firestore ตรงกับ Firebase Auth
+- **คอลเลกชัน Firestore**:
+  - `parking_spots`: เอกสารตามหมายเลขช่อง มี `status`, `hold_by`, `hold_until`, `start_time`
+  - `users`: เก็บชื่อ อีเมล บทบาท และ timestamp สำหรับการนำทางและโปรไฟล์
+- **การเชื่อมต่อภายนอก**: เฟิร์มแวร์ IoT จะอัปเดต `parking_spots`; ต้องยืนยัน API/โปรโตคอลอีกครั้ง `<TODO: ระบุ API สำหรับ IoT>`
+
+### IoT Firmware (C++)
+- **ที่เก็บโค้ด**: ยังไม่ถูกรวมในรีโปนี้ `<TODO: เพิ่มลิงก์เฟิร์มแวร์>`
+- **ฮาร์ดแวร์เป้าหมาย**: คาดว่าใช้ไมโครคอนโทรลเลอร์ที่มี Wi-Fi เช่น ESP32/ESP8266 `<รอยืนยัน>`
+- **เซนเซอร์**: อาจใช้เซนเซอร์อัลตราโซนิกหรือแม่เหล็กเพื่อตรวจจับรถ `<รอยืนยันประเภทเซนเซอร์>`
+- **การเชื่อมต่อ**: แนะนำผ่าน Wi-Fi ใช้ Firebase REST API หรือเรียก Cloud Function; BLE/Serial เป็นตัวเลือก `<ต้องตัดสินใจ>`
+- **รูปแบบข้อความ**: คาดหวัง JSON ที่แมปหมายเลขช่องกับสถานะ (`available|occupied|unavailable|held`) และเวลา `<กำหนดสคีมาที่ชัดเจน>`
+- **การซิงก์ข้อมูล**: เฟิร์มแวร์ควรกรองสัญญาณรบกวนก่อนอัปเดต `parking_spots` เพื่อให้แอปตอบสนองได้ถูกต้อง
+- **การจัดการคีย์**: ควรดึงข้อมูลรับรองจากตัวแปรสภาพแวดล้อม/ระบบจัดเก็บความลับ ไม่ฮาร์ดโค้ดในเฟิร์มแวร์
+
+### Screenshots / Demo
+| หน้าจอ | คำอธิบาย | ไฟล์ |
+| --- | --- | --- |
+| Home (ผู้ใช้ทั่วไป) | แผนผังที่จอดพร้อมจำนวนช่องว่าง | `<ADD IMAGE>` |
+| Recommendation Dialog | แสดงช่องแนะนำและปุ่มเปิด Google Maps | `<ADD IMAGE>` |
+| Admin Dashboard | จัดการสถานะช่องและปุ่มควบคุมรวม | `<ADD IMAGE>` |
+| Profile | ปรับชื่อ สลับธีม ลบบัญชี/ออกจากระบบ | `<ADD IMAGE>` |
+
+### Testing
+```bash
+# ทดสอบ Flutter
+flutter test
+
+# ตรวจสอบโค้ด Cloud Functions
+npm --prefix functions run lint
+```
+- เพิ่มการทดสอบการทำงานจริง (integration/widget) สำหรับการจองและผู้ดูแล `<TODO: ขยายการทดสอบ>`
+
+### CI/CD
+- ยังไม่มีระบบอัตโนมัติ (ไม่มี `.github/workflows`) เสนอให้เพิ่ม GitHub Actions สำหรับ `flutter test` และ lint ของ Cloud Functions `<TODO: ตั้งค่า CI>`
+
+### Roadmap / TODO
+- รวมและจัดทำเอกสารเฟิร์มแวร์ IoT, สคีมาข้อมูล และขั้นตอนดีพลอย
+- เพิ่มการแจ้งเตือนให้ผู้ใช้เมื่อการจองจะหมดเวลาหรือถูกยกเลิก
+- สร้างแดชบอร์ดสถิติเพื่อวิเคราะห์การใช้งานที่จอด
+- เขียนการทดสอบรวม/วิดเจ็ตสำหรับระบบล็อกอิน การจอง และผู้ดูแล
+- ตั้งค่า CI/CD (เช่น GitHub Actions) เพื่อรันทดสอบและดีพลอยอัตโนมัติ
+- รองรับหลายภาษา (ไทย/อังกฤษ) ผ่าน `intl` หรือ `flutter_localizations`
+
+### Known Issues & Troubleshooting
+- **ไม่มีคอนฟิก Firebase**: ต้องอัปเดต `firebase_options.dart` และไฟล์แพลตฟอร์ม มิฉะนั้นการเริ่มต้น Firebase จะล้มเหลว
+- **ปฏิเสธสิทธิ์ตำแหน่ง**: ฟังก์ชัน `openGoogleMapsToPSUPK` จะ error หาก GPS หรือสิทธิ์ถูกปิด ต้องให้ผู้ใช้เปิดก่อน
+- **Cloud Function ทำงานผิดพลาด**: ตรวจสอบว่าได้ดีพลอย `functions/index.js` และตั้ง Node 20 แล้ว ดูบันทึกใน Firebase เมื่อ `recommendAndHold` ตอบกลับ `{ok: false}`
+- **การจองซ้ำ**: หากผู้ใช้มีการจองอยู่แล้วจะได้รับข้อความ "Already has a held spot" ควรจัดการ UX ให้ชัดเจน
+- **บทบาทไม่ตรง**: การเข้าสู่แดชบอร์ดผู้ดูแลขึ้นกับ `users/{uid}.role`; ตรวจสอบว่าข้อมูลถูกต้อง
+
+### Contributing Guidelines
+1. ฟอร์กและสร้างกิ่งงาน (`git checkout -b feat/<ชื่อฟีเจอร์>`)
+2. จัดรูปแบบโค้ดด้วย `dart format` และปฏิบัติตาม lint ใน `analysis_options.yaml`
+3. รัน `flutter test` (และ `npm --prefix functions run lint` หากแก้ไข Cloud Functions)
+4. ส่ง Pull Request พร้อมสรุปการเปลี่ยนแปลงและอ้างอิง issue/TODO ที่เกี่ยวข้อง
+
+### License
+- ยังไม่มีไฟล์สัญญาอนุญาต `<TODO: เพิ่ม LICENSE>`
+
+### Changelog
+- ยังไม่มีแฟ้มบันทึกการเปลี่ยนแปลง ใช้ Git history หรือสร้าง `CHANGELOG.md` `<TODO: จัดทำบันทึกเวอร์ชัน>`
