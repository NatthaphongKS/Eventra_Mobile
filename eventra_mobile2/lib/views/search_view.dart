import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/event_controller.dart';
import '../widgets/event_card.dart';

class SearchView extends StatelessWidget {
  // 1. ใช้ Get.find เพื่อดึง Controller ตัวเดิมที่โหลดไว้ที่หน้า EventList มาใช้ต่อ
  final EventController controller = Get.find<EventController>();
  final TextEditingController _textController = TextEditingController();

  SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // ส่วนแถบค้นหา (Search Bar)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'ค้นหาอีเว้นท์...',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      // 2. เรียกใช้ฟังก์ชัน searchEvents ที่เรายุบรวมมา
                      onChanged: (value) => controller.searchEvents(value),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      controller.clearSearch(); // 3. ล้างผลการค้นหาก่อนกลับ
                      Get.back();
                    },
                    child: const Text(
                      'ยกเลิก',
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ส่วนแสดงผลลัพธ์
            Expanded(
              child: Obx(() {
                if (controller.isSearching.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 4. เปลี่ยนชื่อตัวแปรจาก results เป็น searchResults ตามที่เขียนไว้ใน Controller
                if (controller.hasSearched.value &&
                    controller.searchResults.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: controller.searchResults.length,
                  itemBuilder: (_, i) => EventCard(
                    event: controller.searchResults[i],
                    onTap: () => Get.toNamed(
                      '/event-details',
                      arguments: controller.searchResults[i],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'ไม่พบกิจกรรมที่ค้นหา',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
