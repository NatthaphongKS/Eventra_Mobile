import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/event_model.dart';

class EventDetailsView extends StatelessWidget {
  const EventDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    // รับข้อมูล EventModel ที่ส่งมาจากหน้า Dashboard หรือ List
    final EventModel event = Get.arguments;

    return Scaffold(
      appBar: AppBar(title: const Text("รายละเอียดกิจกรรม"), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ส่วนหัว: แสดงไอคอนหรือรูปภาพประกอบ
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Icon(
                Icons.event_note,
                size: 80,
                color: Colors.blue.shade400,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ชื่อกิจกรรมและป้ายสถานะ
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          event.evnTitle ?? "ไม่มีชื่อกิจกรรม",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildStatusBadge(event.evnStatus),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // รายละเอียดข้อมูล (ใช้ Helper Method ด้านล่าง)
                  _buildDetailItem(
                    Icons.location_on_outlined,
                    "สถานที่",
                    event.evnLocation ?? "ไม่ระบุ",
                  ),
                  _buildDetailItem(
                    Icons.calendar_today_outlined,
                    "วันที่กิจกรรม",
                    event.evnDate.toString().split(' ')[0],
                  ),
                  _buildDetailItem(
                    Icons.access_time,
                    "เวลา",
                    "${event.evnTimeStart} - ${event.evnTimeEnd}",
                  ),
                  _buildDetailItem(
                    Icons.hourglass_bottom,
                    "ระยะเวลา",
                    "${event.evnDuration} นาที",
                  ),

                  const Divider(height: 40),

                  // คำอธิบายเพิ่มเติม
                  const Text(
                    "รายละเอียดเพิ่มเติม",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    event.evnDescription ?? "ไม่มีรายละเอียด",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade800,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ปุ่ม Action: ไปหน้าเช็คอิน (โชว์เฉพาะงานที่ยังไม่เสร็จ)
                  if (event.evnStatus != 'done')
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            Get.toNamed('/checkin', arguments: event),
                        icon: const Icon(Icons.how_to_reg),
                        label: const Text(
                          "จัดการการเช็คอินพนักงาน",
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget ช่วยจัดรูปแบบแถวข้อมูล
  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget ป้ายสถานะ
  Widget _buildStatusBadge(String? status) {
    bool isDone = status == 'done';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDone ? Colors.green.shade100 : Colors.orange.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isDone ? "เสร็จสิ้น" : "รอดำเนินการ",
        style: TextStyle(
          color: isDone ? Colors.green.shade700 : Colors.orange.shade800,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
