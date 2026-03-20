class Guest {
  final String id; // ⚠️ เปลี่ยนจาก int เป็น String เพื่อรับ Document ID ของ Firebase
  final String firstName;
  final String lastName;
  final String? email;
  bool isCheckedIn;

  Guest({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.isCheckedIn = false,
  });

  String get fullName => '$firstName $lastName';

  // แปลงข้อมูล Map ที่ได้จาก Firebase ให้เป็น Object Guest
  factory Guest.fromMap(String documentId, Map<String, dynamic> data) {
    return Guest(
      id: documentId, // รับ ID แยกมาจากชื่อ Document โดยตรง
      firstName: data['first_name'] ?? '',
      lastName: data['last_name'] ?? '',
      email: data['email'],
      isCheckedIn: data['is_checked_in'] ?? false,
    );
  }

  // แปลงจาก Object กลับเป็น Map เพื่อเตรียมโยนขึ้นไปบันทึกใน Firebase
  Map<String, dynamic> toMap() {
    return {
      // 💡 สังเกตว่าเราไม่ต้องใส่ 'id' ลงใน Map เพราะใน Firebase ตัว id จะเป็นชื่อไฟล์ (Document) อยู่แล้ว
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'is_checked_in': isCheckedIn,
    };
  }
}