import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/checkin_controller.dart';
import '../models/event_model.dart';

class EventCheckinView extends StatelessWidget {
  final CheckinController controller = Get.put(CheckinController());

  @override
  Widget build(BuildContext context) {
    // รับค่า event มาจากหน้า details
    final EventModel event = Get.arguments;

    // โหลดข้อมูลเมื่อเปิดหน้าครั้งแรก
    controller.loadGuests(event.id!);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Event Check-In',
          style: TextStyle(
            color: Colors.blueAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ส่วนแสดงความคืบหน้า (Progress Header)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.evnTitle ?? "กิจกรรม",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'รวมรายชื่อเช็คแล้ว',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${controller.checkedInCount}/${controller.totalCount}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: controller.progress,
                    minHeight: 10,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // รายชื่อพนักงาน
            Expanded(
              child: ListView.separated(
                itemCount: controller.guests.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final guest = controller.guests[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        guest.empNickname?[0] ?? "?",
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ),
                    title: Text(guest.empFullname ?? ""),
                    subtitle: Text(guest.empPosition ?? ""),
                    trailing: InkWell(
                      onTap: () => controller.toggleCheckIn(guest),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: guest.isCheckedIn
                              ? Colors.green
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green, width: 2),
                        ),
                        child: guest.isCheckedIn
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              )
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
