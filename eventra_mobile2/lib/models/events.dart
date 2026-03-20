class Event {
  final String id;
  final String name;
  final String description;
  final String location;
  final String date;
  final String time;
  final String status; // อันนี้คือสถานะดิบจากฐานข้อมูล

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.date,
    required this.time,
    required this.status,
  });

  // 🌟 ฟังก์ชันคำนวณสถานะแบบ Real-time
  String get currentStatus {
    try {
      // 1. ดึงวันที่ (ตัวอย่าง format: "20/3/2567")
      List<String> dateParts = date.split('/');
      int day = int.parse(dateParts[0]);
      int month = int.parse(dateParts[1]);
      int year = int.parse(dateParts[2]) - 543; // แปลงพ.ศ. เป็น ค.ศ.

      DateTime eventStart;
      DateTime eventEnd;

      // 2. ดึงเวลา (รองรับทั้งแบบ "12:00" และ "12:00 - 14:00")
      if (time.contains('-')) {
        var timeParts = time.split('-');
        var startParts = timeParts[0].trim().split(':');
        var endParts = timeParts[1].trim().split(':');
        
        eventStart = DateTime(year, month, day, int.parse(startParts[0]), int.parse(startParts[1]));
        eventEnd = DateTime(year, month, day, int.parse(endParts[0]), int.parse(endParts[1]));
      } else {
        var timeParts = time.trim().split(':');
        eventStart = DateTime(year, month, day, int.parse(timeParts[0]), int.parse(timeParts[1]));
        eventEnd = eventStart.add(const Duration(hours: 3)); // ถ้าไม่มีเวลาจบ สมมติให้บวกไป 3 ชั่วโมง
      }

      DateTime now = DateTime.now(); // ดึงเวลาปัจจุบัน

      // 3. เทียบเวลาและคืนค่าสถานะที่ถูกต้อง
      if (now.isBefore(eventStart)) {
        return 'upcoming';
      } else if (now.isAfter(eventEnd)) {
        return 'done';
      } else {
        return 'ongoing'; // อยู่ระหว่างเวลาเริ่มและจบ
      }
    } catch (e) {
      // ถ้า Error (เช่น ใส่ข้อมูลมาผิด format) ให้ใช้ค่า status เดิมจากฐานข้อมูลกันแอปเด้ง
      return status;
    }
  }

  factory Event.fromMap(String id, Map<String, dynamic> data) {
    return Event(
      id: id,
      name: data['name'] ?? 'ไม่มีชื่อกิจกรรม',
      description: data['description'] ?? 'ไม่มีรายละเอียด',
      location: data['location'] ?? 'ไม่ระบุสถานที่',
      date: data['date'] ?? 'ไม่ระบุวันที่',
      time: data['time'] ?? 'ไม่ระบุเวลา',
      status: data['status'] ?? 'upcoming',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'location': location,
      'date': date,
      'time': time,
      'status': status,
    };
  }
}