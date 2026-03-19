import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/event_model.dart';
import '../core/app_constants.dart';

class EventController extends GetxController {
  final _connect = GetConnect();
  final box = GetStorage();

  // --- State สำหรับหน้า List ---
  var events = <EventModel>[].obs;
  var isLoading = false.obs;

  // --- State สำหรับหน้า Search ---
  var searchResults = <EventModel>[].obs;
  var isSearching = false.obs;
  var hasSearched = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchEvents();
  }

  // 1. ดึงข้อมูลกิจกรรมทั้งหมด
  Future<void> fetchEvents() async {
    try {
      isLoading(true);
      final response = await _connect.get('${AppConstants.baseUrl}/api/events');
      if (response.statusCode == 200) {
        List data = response.body;
        events.value = data.map((e) => EventModel.fromJson(e)).toList();
      }
    } finally {
      isLoading(false);
    }
  }

  // 2. ฟังก์ชันค้นหากิจกรรม (ยุบรวมจาก SearchController)
  Future<void> searchEvents(String query) async {
    if (query.trim().isEmpty) {
      searchResults.clear();
      hasSearched.value = false;
      return;
    }

    try {
      isSearching(true);
      // ยิง API ค้นหาไปยังระบบเก่า
      final response = await _connect.get(
        '${AppConstants.baseUrl}/api/event-search',
        query: {'q': query.trim()},
      );

      if (response.statusCode == 200) {
        List data = response.body;
        searchResults.value = data.map((e) => EventModel.fromJson(e)).toList();
        hasSearched.value = true;
      }
    } catch (e) {
      print("Search Error: $e");
    } finally {
      isSearching(false);
    }
  }

  // 3. บันทึก หรือ แก้ไขกิจกรรม (CRUD)
  Future<bool> saveOrUpdateEvent({
    int? id,
    required Map<String, dynamic> data,
  }) async {
    try {
      isLoading(true);
      final Map<String, dynamic> body = {
        "evn_title": data['name'],
        "evn_description": data['description'],
        "evn_location": data['location'],
        "evn_date": data['date'],
        "evn_timestart": data['start_time'],
        "evn_timeend": data['end_time'],
        "evn_status": data['status'],
        "evn_category_id": 1,
        "evn_create_by": box.read('user')['id'],
      };

      final response = (id == null)
          ? await _connect.post('${AppConstants.baseUrl}/api/event-save', body)
          : await _connect.post(
              '${AppConstants.baseUrl}/api/event-update/$id',
              body,
            );

      if (response.statusCode == 200) {
        await fetchEvents(); // โหลดข้อมูลใหม่เข้า List หลัก
        return true;
      }
      return false;
    } finally {
      isLoading(false);
    }
  }

  // 4. กรองข้อมูลตามสถานะสำหรับ TabBar
  List<EventModel> filteredEvents(String status) {
    return events.where((e) => e.evnStatus == status).toList();
  }

  // 5. ลบผลการค้นหาเมื่อปิดหน้า Search
  void clearSearch() {
    searchResults.clear();
    hasSearched.value = false;
  }
}
