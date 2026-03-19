import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class LoginView extends StatelessWidget {
  // เรียกใช้ Controller (ถ้าเคย put ไว้แล้วจะใช้ find ก็ได้)
  final AuthController authController = Get.put(AuthController());
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Eventra Login Test")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 25),

            // แสดงสถานะปุ่มตามค่า isLoading
            Obx(
              () => authController.isLoading.value
                  ? const CircularProgressIndicator() // กำลังหมุน
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: () {
                        // ส่งค่าจาก Controller ไปที่ฟังก์ชัน login
                        authController.login(emailCtrl.text, passCtrl.text);
                      },
                      child: const Text("Login"),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
