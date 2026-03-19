import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../core/app_constants.dart';

class AuthController extends GetxController {
  final _connect = GetConnect();
  final box = GetStorage();

  var isLoading = false.obs;
  var userData = {}.obs;

  @override
  void onInit() {
    super.onInit();
    if (box.hasData('user')) {
      userData.value = box.read('user');
    }
  }

  Future<void> login(String email, String password) async {
    // 1. ตรวจสอบค่าว่างเบื้องต้น
    if (email.trim().isEmpty || password.trim().isEmpty) {
      Get.snackbar("แจ้งเตือน", "กรุณากรอกอีเมลและรหัสผ่าน");
      return;
    }

    try {
      isLoading(true);

      final response = await _connect.post(
        AppConstants.loginUrl,
        {'email': email.trim(), 'password': password.trim()},
        headers: {
          'Accept': 'application/json',
          'Content-Type':
              'application/json', // ✅ เพิ่มบรรทัดนี้เพื่อให้ Laravel รู้จัก JSON
        },
      );

      // Log ดูค่าที่ตอบกลับมา (ช่วยให้แก้บัคได้ง่ายขึ้น)
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        // กรณีสำเร็จ
        final user = response.body['user'];
        await box.write('user', user);
        userData.value = user;

        Get.offAllNamed('/home');
        Get.snackbar("สำเร็จ", "ยินดีต้อนรับครับ");
      } else if (response.statusCode == 422) {
        // ✅ กรณี Validation Fail (เช่น ลืมใส่ @ ใน email)
        var errors = response.body['errors'];
        String errorMsg = errors != null
            ? errors.toString()
            : "ข้อมูลไม่ถูกต้องตามเงื่อนไข";
        Get.snackbar("ผิดพลาด (422)", errorMsg);
      } else {
        // กรณีอื่นๆ เช่น 401 (Unauthorized)
        String msg = response.body != null
            ? (response.body['message'] ?? "อีเมลหรือรหัสผ่านผิด")
            : "เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง";
        Get.snackbar("ผิดพลาด", msg);
      }
    } catch (e) {
      print("Catch Error: $e");
      Get.snackbar("Error", "ไม่สามารถติดต่อเซิร์ฟเวอร์ได้ ($e)");
    } finally {
      isLoading(false);
    }
  }

  void logout() {
    box.remove('user');
    userData.value = {};
    Get.offAllNamed('/login');
    Get.snackbar("Logout", "ออกจากระบบเรียบร้อยแล้ว");
  }
}
