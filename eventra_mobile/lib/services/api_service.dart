import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event.dart';
import '../models/guest.dart';
import '../data/mock_data.dart';

class ApiService {
  static const String baseUrl = 'https://eventra.kasecode.com/api';
  static const bool useMockData = true;

  static String? _token;

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

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // ─── AUTH ────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    if (useMockData) {
      // Mock login: any non-empty credentials succeed
      await Future.delayed(const Duration(seconds: 1));
      if (username.isNotEmpty && password.isNotEmpty) {
        await saveToken('mock_token_12345');
        return {
          'success': true,
          'user': {'name': username}
        };
      }
      return {'success': false, 'message': 'Invalid credentials'};
    }

    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: _headers,
      body: jsonEncode({'username': username, 'password': password}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['token'] != null) {
      await saveToken(data['token']);
      return {'success': true, 'user': data['user']};
    }
    return {'success': false, 'message': data['message'] ?? 'Login failed'};
  }

  static Future<void> logout() async {
    if (!useMockData) {
      try {
        await http.post(Uri.parse('$baseUrl/logout'), headers: _headers);
      } catch (_) {}
    }
    await clearToken();
  }

  // ─── EVENTS ──────────────────────────────────────────────────────────────

  static Future<List<Event>> getEvents({String? status}) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (status != null && status.isNotEmpty) {
        return MockData.events.where((e) => e.status == status).toList();
      }
      return MockData.events;
    }

    final query = status != null ? '?status=$status' : '';
    final response = await http.get(
      Uri.parse('$baseUrl/events$query'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['data'];
      return data.map((e) => Event.fromJson(e)).toList();
    }
    throw Exception('Failed to load events');
  }

  static Future<Event> getEvent(int id) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return MockData.events.firstWhere((e) => e.id == id);
    }
    final response = await http.get(
      Uri.parse('$baseUrl/events/$id'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return Event.fromJson(jsonDecode(response.body)['data']);
    }
    throw Exception('Failed to load event');
  }

  static Future<Event> createEvent(Map<String, dynamic> data) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      final newEvent = Event(
        id: MockData.events.length + 1,
        name: data['name'],
        description: data['description'] ?? '',
        location: data['location'] ?? '',
        date: DateTime.parse(data['date']),
        startTime: data['start_time'] ?? '',
        endTime: data['end_time'] ?? '',
        participantCount: 0,
        status: 'upcoming',
      );
      MockData.events.add(newEvent);
      return newEvent;
    }
    final response = await http.post(
      Uri.parse('$baseUrl/events'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (response.statusCode == 201) {
      return Event.fromJson(jsonDecode(response.body)['data']);
    }
    throw Exception('Failed to create event');
  }

  static Future<Event> updateEvent(int id, Map<String, dynamic> data) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      final index = MockData.events.indexWhere((e) => e.id == id);
      if (index != -1) {
        final updated = MockData.events[index].copyWith(
          name: data['name'],
          description: data['description'],
          location: data['location'],
          status: data['status'],
        );
        MockData.events[index] = updated;
        return updated;
      }
      throw Exception('Event not found');
    }
    final response = await http.put(
      Uri.parse('$baseUrl/events/$id'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return Event.fromJson(jsonDecode(response.body)['data']);
    }
    throw Exception('Failed to update event');
  }

  static Future<void> deleteEvent(int id) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      MockData.events.removeWhere((e) => e.id == id);
      return;
    }
    await http.delete(Uri.parse('$baseUrl/events/$id'), headers: _headers);
  }

  static Future<List<Event>> searchEvents(String query) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return MockData.events
          .where((e) =>
              e.name.toLowerCase().contains(query.toLowerCase()) ||
              e.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    final response = await http.get(
      Uri.parse('$baseUrl/events?search=$query'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['data'];
      return data.map((e) => Event.fromJson(e)).toList();
    }
    throw Exception('Search failed');
  }

  // ─── GUESTS ──────────────────────────────────────────────────────────────

  static Future<List<Guest>> getGuests(int eventId) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 400));
      return MockData.guests.map((g) {
        g.isCheckedIn = MockData.checkInStatus[g.id] ?? false;
        return g;
      }).toList();
    }
    final response = await http.get(
      Uri.parse('$baseUrl/events/$eventId/guests'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['data'];
      return data.map((g) => Guest.fromJson(g)).toList();
    }
    throw Exception('Failed to load guests');
  }

  static Future<void> inviteGuest(int eventId, int guestId) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final guest = MockData.guests.firstWhere((g) => g.id == guestId);
      guest.isInvited = true;
      return;
    }
    await http.post(
      Uri.parse('$baseUrl/events/$eventId/guests/$guestId/invite'),
      headers: _headers,
    );
  }

  static Future<void> removeGuest(int eventId, int guestId) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final guest = MockData.guests.firstWhere((g) => g.id == guestId);
      guest.isInvited = false;
      return;
    }
    await http.delete(
      Uri.parse('$baseUrl/events/$eventId/guests/$guestId'),
      headers: _headers,
    );
  }

  static Future<void> checkInGuest(
      int eventId, int guestId, bool checked) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      MockData.checkInStatus[guestId] = checked;
      return;
    }
    await http.post(
      Uri.parse('$baseUrl/events/$eventId/guests/$guestId/checkin'),
      headers: _headers,
      body: jsonEncode({'checked_in': checked}),
    );
  }
}
