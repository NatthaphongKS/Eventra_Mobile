import '../models/event.dart';
import '../models/guest.dart';

class MockData {
  static List<Event> get events => [
        Event(
          id: 1,
          name: 'งานสัมมนาวิชาการ IT',
          description: 'งานสัมมนาเกี่ยวกับเทคโนโลยีสารสนเทศและนวัตกรรม',
          location: 'คณะวิทยาการสารสนเทศ',
          date: DateTime(2026, 2, 14),
          startTime: '12:00',
          endTime: '14:00',
          participantCount: 34,
          status: 'ongoing',
        ),
        Event(
          id: 2,
          name: 'Workshop Flutter Development',
          description: 'เวิร์กช็อปสอนการพัฒนาแอปด้วย Flutter',
          location: 'ห้อง LAB 301',
          date: DateTime(2026, 3, 5),
          startTime: '09:00',
          endTime: '17:00',
          participantCount: 50,
          status: 'upcoming',
        ),
        Event(
          id: 3,
          name: 'กีฬาสี ประจำปี 2569',
          description: 'งานกีฬาสีประจำปีของคณะ',
          location: 'สนามกีฬากลาง',
          date: DateTime(2026, 1, 20),
          startTime: '08:00',
          endTime: '18:00',
          participantCount: 120,
          status: 'done',
        ),
        Event(
          id: 4,
          name: 'Open House 2026',
          description: 'งาน Open House แนะนำหลักสูตร',
          location: 'อาคารเรียนรวม',
          date: DateTime(2026, 4, 10),
          startTime: '10:00',
          endTime: '16:00',
          participantCount: 200,
          status: 'upcoming',
        ),
        Event(
          id: 5,
          name: 'แข่งขันเขียนโปรแกรม',
          description: 'การแข่งขัน Competitive Programming ระดับมหาวิทยาลัย',
          location: 'ห้อง LAB 101',
          date: DateTime(2026, 2, 28),
          startTime: '13:00',
          endTime: '17:00',
          participantCount: 40,
          status: 'ongoing',
        ),
        Event(
          id: 6,
          name: 'ปฐมนิเทศนิสิตใหม่',
          description: 'งานปฐมนิเทศนิสิตใหม่ประจำปีการศึกษา 2569',
          location: 'หอประชุมใหญ่',
          date: DateTime(2025, 11, 15),
          startTime: '08:30',
          endTime: '12:00',
          participantCount: 350,
          status: 'done',
        ),
      ];

  static List<Guest> get guests => [
        Guest(
            id: 1,
            firstName: 'สมชาย',
            lastName: 'ใจดี',
            email: 'somchai@example.com',
            isInvited: true),
        Guest(
            id: 2,
            firstName: 'สมหญิง',
            lastName: 'รักสวย',
            email: 'somying@example.com',
            isInvited: true),
        Guest(
            id: 3,
            firstName: 'วิชัย',
            lastName: 'มานะ',
            email: 'wichai@example.com',
            isInvited: false),
        Guest(
            id: 4,
            firstName: 'อรุณ',
            lastName: 'สว่าง',
            email: 'arun@example.com',
            isInvited: true),
        Guest(
            id: 5,
            firstName: 'นภา',
            lastName: 'ฟ้าใส',
            email: 'napa@example.com',
            isInvited: false),
        Guest(
            id: 6,
            firstName: 'ธนา',
            lastName: 'มีโชค',
            email: 'tana@example.com',
            isInvited: true),
        Guest(
            id: 7,
            firstName: 'รัตนา',
            lastName: 'แก้วใส',
            email: 'rattana@example.com',
            isInvited: false),
        Guest(
            id: 8,
            firstName: 'พิชัย',
            lastName: 'เจริญ',
            email: 'pichai@example.com',
            isInvited: true),
        Guest(
            id: 9,
            firstName: 'กัญญา',
            lastName: 'สดใส',
            email: 'kanya@example.com',
            isInvited: false),
        Guest(
            id: 10,
            firstName: 'ประยุทธ',
            lastName: 'แน่วแน่',
            email: 'prayut@example.com',
            isInvited: true),
        Guest(
            id: 11,
            firstName: 'วรรณา',
            lastName: 'งามตา',
            email: 'wanna@example.com',
            isInvited: true),
        Guest(
            id: 12,
            firstName: 'สุรชัย',
            lastName: 'ยิ้มแย้ม',
            email: 'surachai@example.com',
            isInvited: false),
      ];

  // Simulated check-in data: guestId -> isCheckedIn
  static Map<int, bool> checkInStatus = {
    1: true,
    2: false,
    3: false,
    4: true,
    5: false,
    6: false,
    7: false,
    8: false,
    9: false,
    10: false,
    11: false,
    12: false,
  };
}
