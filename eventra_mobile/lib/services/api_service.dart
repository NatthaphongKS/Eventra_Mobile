import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event.dart';
import '../models/guest.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  static const bool useMockData = false;

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

  // ─── HEADERS (async) ─────────────────────────────────────────────────────

  static Future<Map<String, String>> get _headers async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ─── AUTH ────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'username': username, 'password': password}),
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
      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อ server ได้'};
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

  static Future<Event> getEvent(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/events/$id'),
      headers: await _headers,
    );
    if (response.statusCode == 200) {
      return Event.fromJson(jsonDecode(response.body)['data']);
    }
    throw Exception('โหลดกิจกรรมไม่สำเร็จ');
  }

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

  static Future<void> deleteEvent(int id) async {
    await http.delete(
      Uri.parse('$baseUrl/events/$id'),
      headers: await _headers,
    );
  }

  static Future<List<Event>> searchEvents(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/events?search=${Uri.encodeComponent(query)}'),
      headers: await _headers,
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['data'] ?? [];
      return data.map((e) => Event.fromJson(e)).toList();
    }
    throw Exception('ค้นหาไม่สำเร็จ');
  }

  // ─── GUESTS ──────────────────────────────────────────────────────────────

  static Future<List<Guest>> getGuests(int eventId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/events/$eventId/guests'),
      headers: await _headers,
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['data'] ?? [];
      return data.map((g) => Guest.fromJson(g)).toList();
    }
    throw Exception('โหลดรายชื่อไม่สำเร็จ');
  }

  static Future<void> inviteGuest(int eventId, int guestId) async {
    await http.post(
      Uri.parse('$baseUrl/events/$eventId/guests/$guestId/invite'),
      headers: await _headers,
    );
  }

  static Future<void> removeGuest(int eventId, int guestId) async {
    await http.delete(
      Uri.parse('$baseUrl/events/$eventId/guests/$guestId'),
      headers: await _headers,
    );
  }

  static Future<void> checkInGuest(
      int eventId, int guestId, bool checked) async {
    await http.post(
      Uri.parse('$baseUrl/events/$eventId/guests/$guestId/checkin'),
      headers: await _headers,
      body: jsonEncode({'checked_in': checked}),
    );
  }
}
