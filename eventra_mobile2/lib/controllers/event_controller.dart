import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/event_model.dart';
import '../core/app_constants.dart';

class EventController extends GetxController {
  final _connect = GetConnect();
  final box = GetStorage();

  var events = <EventModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchEvents();
  }

  // ดึงข้อมูลกิจกรรมทั้งหมด
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

  // บันทึก หรือ แก้ไขกิจกรรม (ส่งเป็น evn_xxx เพื่อระบบเก่า)
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
        await fetchEvents(); // โหลดข้อมูลใหม่
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      isLoading(false);
    }
  }

  // กรองข้อมูลตาม Tab
  List<EventModel> filteredEvents(String status) {
    return events.where((e) => e.evnStatus == status).toList();
  }
}
