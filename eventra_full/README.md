# Eventra - Flutter App

แอปจัดการกิจกรรม สร้างด้วย Flutter

## โครงสร้างโปรเจค

```
lib/
├── main.dart                    # Entry point
├── utils/
│   └── app_theme.dart           # สี, theme ทั้งหมด
├── models/
│   ├── event.dart               # Event model
│   └── guest.dart               # Guest model
├── data/
│   └── mock_data.dart           # ข้อมูลจำลอง (mock)
├── services/
│   └── api_service.dart         # API calls (ต่อ Laravel)
├── widgets/
│   └── event_card.dart          # EventCard widget
└── screens/
    ├── login_screen.dart         # หน้า Login
    ├── event_list_screen.dart    # หน้ารายการกิจกรรม + tabs
    ├── event_detail_screen.dart  # หน้ารายละเอียดกิจกรรม
    ├── event_form_screen.dart    # หน้าสร้าง/แก้ไขกิจกรรม
    ├── event_invite_screen.dart  # หน้าจัดการผู้เข้าร่วม
    ├── event_checkin_screen.dart # หน้าเช็คชื่อผู้เข้าร่วม
    └── search_screen.dart        # หน้าค้นหา
```

## วิธี Build APK

### 1. ติดตั้ง Flutter
```bash
# ดาวน์โหลดจาก https://flutter.dev
# แล้วเพิ่ม flutter/bin ใน PATH
flutter doctor
```

### 2. ติดตั้ง dependencies
```bash
cd eventra
flutter pub get
```

### 3. Build APK (debug)
```bash
flutter build apk --debug
# ไฟล์อยู่ที่: build/app/outputs/flutter-apk/app-debug.apk
```

### 4. Build APK (release)
```bash
flutter build apk --release
# ไฟล์อยู่ที่: build/app/outputs/flutter-apk/app-release.apk
```

### 5. ติดตั้งบนมือถือ (ต้องเชื่อมต่อ USB + เปิด Developer Mode)
```bash
flutter install
# หรือ
adb install build/app/outputs/flutter-apk/app-release.apk
```

## การเชื่อมต่อ Laravel Backend

ใน `lib/services/api_service.dart`:

```dart
// เปลี่ยน IP ให้ตรงกับ Laravel server
static const String baseUrl = 'http://YOUR_IP:8000/api';

// เมื่อ backend พร้อม ให้เปลี่ยนเป็น false
static const bool useMockData = false;
```

## Laravel API Endpoints ที่ต้องมี

```
POST   /api/login                          → login
POST   /api/logout                         → logout

GET    /api/events                         → รายการกิจกรรมทั้งหมด
GET    /api/events?status=upcoming         → กรองตาม status
GET    /api/events?search=keyword          → ค้นหา
GET    /api/events/{id}                    → รายละเอียดกิจกรรม
POST   /api/events                         → สร้างกิจกรรม
PUT    /api/events/{id}                    → แก้ไขกิจกรรม
DELETE /api/events/{id}                    → ลบกิจกรรม

GET    /api/events/{id}/guests             → รายชื่อผู้เชิญ
POST   /api/events/{id}/guests/{guestId}/invite   → เชิญผู้เข้าร่วม
DELETE /api/events/{id}/guests/{guestId}          → ยกเลิกเชิญ
POST   /api/events/{id}/guests/{guestId}/checkin  → เช็คชื่อ
```

## Database (eventra_db)

ใช้ข้อมูลจาก .env ที่ให้มา:
- DB_HOST: 10.80.7.17
- DB_PORT: 7306
- DB_DATABASE: eventra_db
- DB_USERNAME: Byteforge

## สีหลักของแอป

| ชื่อ | Hex |
|------|-----|
| Primary (แดงเข้ม) | #8B1A1A |
| Accent (ปุ่มเชิญ) | #FF7070 |
| Ongoing (น้ำเงิน) | #4DA6FF |
| Upcoming (เหลือง) | #FFCC44 |
| Done (เขียว) | #66CC88 |
