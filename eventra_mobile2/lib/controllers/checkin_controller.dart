import 'package:get/get.dart';
import '../models/checkin_model.dart';
import '../core/app_constants.dart';

class CheckinController extends GetxController {
  final _connect = GetConnect();

  var guests = <CheckinModel>[].obs;
  var isLoading = true.obs;

  // คำนวณสรุปผลการเช็คอิน
  int get checkedInCount => guests.where((g) => g.empCheckinStatus == 1).length;
  int get totalCount => guests.length;
  double get progress => totalCount > 0 ? checkedInCount / totalCount : 0.0;

  // ดึงรายชื่อพนักงานที่ถูกเชิญในกิจกรรมนั้นๆ
  Future<void> loadGuests(int eventId) async {
    try {
      isLoading(true);
      final response = await _connect.get(
        '${AppConstants.baseUrl}/api/event-guests/$eventId',
      );
      if (response.statusCode == 200) {
        List data = response.body;
        guests.value = data.map((e) => CheckinModel.fromJson(e)).toList();
      }
    } catch (e) {
      Get.snackbar("Error", "ไม่สามารถโหลดรายชื่อได้");
    } finally {
      isLoading(false);
    }
  }

  // ฟังก์ชันสลับสถานะเช็คอิน (Toggle)
  Future<void> toggleCheckIn(CheckinModel guest) async {
    int newStatus = guest.empCheckinStatus == 1 ? 0 : 1;

    // Optimistic UI: อัปเดตที่หน้าจอก่อนเพื่อให้แอปดูเร็ว
    int index = guests.indexOf(guest);
    if (index != -1) {
      guests[index] = CheckinModel(
        empId: guest.empId,
        empFullname: guest.empFullname,
        empNickname: guest.empNickname,
        empPosition: guest.empPosition,
        empCheckinStatus: newStatus,
        eveId: guest.eveId,
        empInviteStatus: guest.empInviteStatus,
      );
      guests.refresh();
    }

    // ยิง API บันทึกผล
    try {
      final response = await _connect.post(
        '${AppConstants.baseUrl}/api/event-checkin',
        {'empId': guest.empId, 'eveId': guest.eveId, 'status': newStatus},
      );

      if (response.statusCode != 200) {
        Get.snackbar("แจ้งเตือน", "บันทึกข้อมูลไม่สำเร็จ กรุณาลองใหม่");
        loadGuests(guest.eveId!); // โหลดใหม่ถ้าพัง
      }
    } catch (e) {
      Get.snackbar("Error", "เกิดข้อผิดพลาดในการเชื่อมต่อ");
    }
  }
}
