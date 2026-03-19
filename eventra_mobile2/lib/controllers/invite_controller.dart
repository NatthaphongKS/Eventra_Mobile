import 'package:get/get.dart';
import '../models/checkin_model.dart';
import '../core/app_constants.dart';

class InviteController extends GetxController {
  final _connect = GetConnect();

  var guests = <CheckinModel>[].obs;
  var isLoading = true.obs;
  var isSaving = false.obs;

  // กรองข้อมูลแยกตาม Tab
  List<CheckinModel> get allGuests => guests;
  List<CheckinModel> get invitedGuests =>
      guests.where((g) => g.empInviteStatus != 'not_invite').toList();
  List<CheckinModel> get notInvitedGuests =>
      guests.where((g) => g.empInviteStatus == 'not_invite').toList();

  Future<void> loadGuests(int eventId) async {
    try {
      isLoading(true);
      // ยิงไปที่ Endpoint ที่ดึงรายชื่อพนักงานพร้อมสถานะการเชิญ
      final response = await _connect.get(
        '${AppConstants.baseUrl}/api/event-guests/$eventId',
      );
      if (response.statusCode == 200) {
        List data = response.body;
        guests.value = data.map((e) => CheckinModel.fromJson(e)).toList();
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> inviteEmployee(CheckinModel guest) async {
    // 💡 ส่งไปที่ API ระบบเก่า (Legacy)
    final response = await _connect.post(
      '${AppConstants.baseUrl}/api/event-invite',
      {
        'empId': guest.empId,
        'eveId': guest.eveId,
        'status': 'pending', // เริ่มต้นที่รอการตอบรับ
      },
    );

    if (response.statusCode == 200) {
      _updateLocalStatus(guest, 'pending');
    }
  }

  Future<void> removeInvitation(CheckinModel guest) async {
    final response = await _connect.post(
      '${AppConstants.baseUrl}/api/event-uninvite',
      {'empId': guest.empId, 'eveId': guest.eveId},
    );

    if (response.statusCode == 200) {
      _updateLocalStatus(guest, 'not_invite');
    }
  }

  // อัปเดตสถานะในตัวแปร List ทันทีเพื่อให้ UI เปลี่ยน
  void _updateLocalStatus(CheckinModel guest, String status) {
    int index = guests.indexOf(guest);
    if (index != -1) {
      // สร้าง Object ใหม่เพื่อ trigger GetX .obs
      guests[index] = CheckinModel(
        empId: guest.empId,
        empFullname: guest.empFullname,
        empNickname: guest.empNickname,
        empInviteStatus: status,
        empCheckinStatus: guest.empCheckinStatus,
        // ... ฟิลด์อื่นๆ
      );
      guests.refresh();
    }
  }
}
