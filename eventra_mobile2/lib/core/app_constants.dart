// lib/core/app_constants.dart
class AppConstants {
  // 💡 เปลี่ยน URL ตรงนี้ที่เดียว แอปจะเปลี่ยนตามทั้งระบบ
  static const String baseUrl = 'http://localhost:8000';

  // Endpoints ต่างๆ
  static const String loginUrl = '$baseUrl/login';
  static const String registerUrl = '$baseUrl/register';
  static const String profileUrl = '$baseUrl/api/profile';

  // Settings อื่นๆ (ถ้ามี)
  static const int connectTimeout = 10000; // 10 วินาที
}
