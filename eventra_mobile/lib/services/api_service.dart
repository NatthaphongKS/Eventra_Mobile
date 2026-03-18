import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event.dart';
import '../models/guest.dart';

class ApiService {
  // ─── BASE URL ─────────────────────────────────────────────────────────────
  // สามารถ override ได้ด้วย --dart-define=API_BASE_URL=https://your-api/api
  static const String _baseUrlFromEnv =
      String.fromEnvironment('API_BASE_URL', defaultValue: '');

  // ค่า default สำหรับ local development ตาม platform
  static String get baseUrl {
    if (_baseUrlFromEnv.isNotEmpty) return _baseUrlFromEnv;

    if (kIsWeb) {
      // Flutter Web รันบนเครื่องเดียวกับ backend
      return 'http://127.0.0.1:8000/api';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      // Android Emulator ต้องยิงกลับเครื่อง host ผ่าน 10.0.2.2
      return 'http://10.0.2.2:8000/api';
    }

    // iOS Simulator และ desktop
    return 'http://127.0.0.1:8000/api';
  }

  static String? _token;

  // ─── TOKEN ───────────────────────────────────────────────────────────────

  static Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    return _token;
  }

  static Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // ─── HEADERS (async - โหลด token จาก storage เสมอ) ──────────────────────

  static Future<Map<String, String>> get _headers async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ─── AUTH ────────────────────────────────────────────────────────────────

  /// Login ด้วย email ของพนักงาน
  /// username field = emp_email ในระบบ
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'username': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['token'] != null) {
        await saveToken(data['token']);
        return {'success': true, 'user': data['user']};
      }

      return {
        'success': false,
        'message': data['message'] ?? 'เข้าสู่ระบบไม่สำเร็จ',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'ไม่สามารถเชื่อมต่อ server ได้ กรุณาตรวจสอบการเชื่อมต่อ',
      };
    }
  }

  static Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: await _headers,
      );
    } catch (_) {}
    await clearToken();
  }

  // ─── EVENTS ──────────────────────────────────────────────────────────────

  /// ดึงรายการกิจกรรม กรองตาม status ได้ (upcoming/ongoing/done)
  static Future<List<Event>> getEvents({String? status}) async {
    final query =
        (status != null && status.isNotEmpty) ? '?status=$status' : '';
    final response = await http.get(
      Uri.parse('$baseUrl/events$query'),
      headers: await _headers,
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['data'] ?? [];
      return data.map((e) => Event.fromJson(e)).toList();
    }
    throw Exception('โหลดกิจกรรมไม่สำเร็จ (${response.statusCode})');
  }

  /// ดึงรายละเอียดกิจกรรมตาม id
  static Future<Event> getEvent(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/events/$id'),
      headers: await _headers,
    );
    if (response.statusCode == 200) {
      return Event.fromJson(jsonDecode(response.body)['data']);
    }
    throw Exception('โหลดกิจกรรมไม่สำเร็จ (${response.statusCode})');
  }

  /// สร้างกิจกรรมใหม่
  static Future<Event> createEvent(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/events'),
      headers: await _headers,
      body: jsonEncode(data),
    );
    if (response.statusCode == 201) {
      return Event.fromJson(jsonDecode(response.body)['data']);
    }
    throw Exception('สร้างกิจกรรมไม่สำเร็จ (${response.statusCode})');
  }

  /// แก้ไขกิจกรรม
  static Future<Event> updateEvent(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/events/$id'),
      headers: await _headers,
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return Event.fromJson(jsonDecode(response.body)['data']);
    }
    throw Exception('แก้ไขกิจกรรมไม่สำเร็จ (${response.statusCode})');
  }

  /// ลบกิจกรรม (soft delete)
  static Future<void> deleteEvent(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/events/$id'),
      headers: await _headers,
    );
    if (response.statusCode != 200) {
      throw Exception('ลบกิจกรรมไม่สำเร็จ (${response.statusCode})');
    }
  }

  /// ค้นหากิจกรรมตามชื่อหรือรายละเอียด
  static Future<List<Event>> searchEvents(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/events?search=${Uri.encodeComponent(query)}'),
      headers: await _headers,
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['data'] ?? [];
      return data.map((e) => Event.fromJson(e)).toList();
    }
    throw Exception('ค้นหาไม่สำเร็จ (${response.statusCode})');
  }

  // ─── GUESTS ──────────────────────────────────────────────────────────────

  /// ดึงรายชื่อพนักงานพร้อมสถานะการเชิญและเช็คชื่อของกิจกรรมนั้น
  static Future<List<Guest>> getGuests(int eventId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/events/$eventId/guests'),
      headers: await _headers,
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['data'] ?? [];
      return data.map((g) => Guest.fromJson(g)).toList();
    }
    throw Exception('โหลดรายชื่อผู้เข้าร่วมไม่สำเร็จ (${response.statusCode})');
  }

  /// เชิญพนักงานเข้าร่วมกิจกรรม
  static Future<void> inviteGuest(int eventId, int guestId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/events/$eventId/guests/$guestId/invite'),
      headers: await _headers,
    );
    if (response.statusCode != 200) {
      throw Exception('เชิญไม่สำเร็จ (${response.statusCode})');
    }
  }

  /// ยกเลิกการเชิญพนักงาน
  static Future<void> removeGuest(int eventId, int guestId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/events/$eventId/guests/$guestId'),
      headers: await _headers,
    );
    if (response.statusCode != 200) {
      throw Exception('ยกเลิกการเชิญไม่สำเร็จ (${response.statusCode})');
    }
  }

  /// เช็คชื่อพนักงานเข้าร่วมกิจกรรม
  static Future<void> checkInGuest(
      int eventId, int guestId, bool checked) async {
    final response = await http.post(
      Uri.parse('$baseUrl/events/$eventId/guests/$guestId/checkin'),
      headers: await _headers,
      body: jsonEncode({'checked_in': checked}),
    );
    if (response.statusCode != 200) {
      throw Exception('อัปเดตการเช็คชื่อไม่สำเร็จ (${response.statusCode})');
    }
  }
}
