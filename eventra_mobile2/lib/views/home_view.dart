import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class HomeView extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Screen"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
              const SizedBox(height: 20),
              const Text("ยินดีต้อนรับ", style: TextStyle(fontSize: 16)),

              // ใช้ Obx เพื่อให้ชื่ออัปเดตอัตโนมัติ
              Obx(
                () => Text(
                  authController.userData['name'] ?? "Guest User",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Obx(
                () => Text(
                  authController.userData['email'] ?? "No Email",
                  style: const TextStyle(color: Colors.grey),
                ),
              ),

              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 50),
                ),
                onPressed: () => authController.logout(),
                child: const Text("Logout (ออกจากระบบ)"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
