import 'package:flutter/material.dart';

class CheckinModel {
  final int? empId;
  final String? empFullId;
  final String? empCompanyId;
  final String? empFullname;
  final String? empNickname;
  final String? empTeam;
  final String? empDepartment;
  final String? empPosition;
  final int? eveId;
  final String? eveTitle;
  final String? empInviteStatus;
  final int? empCheckinStatus;

  CheckinModel({
    this.empId,
    this.empFullId,
    this.empCompanyId,
    this.empFullname,
    this.empNickname,
    this.empTeam,
    this.empDepartment,
    this.empPosition,
    this.eveId,
    this.eveTitle,
    this.empInviteStatus,
    this.empCheckinStatus,
  });

  // แปลงจาก JSON Map เป็น Object
  factory CheckinModel.fromJson(Map<String, dynamic> json) {
    return CheckinModel(
      empId: json['empId'],
      empFullId: json['empFullId'],
      empCompanyId: json['empCompanyId'],
      empFullname: json['empFullname'],
      empNickname: json['empNickname'],
      empTeam: json['empTeam'],
      empDepartment: json['empDepartment'],
      empPosition: json['empPosition'],
      eveId: json['eveId'],
      eveTitle: json['eveTitle'],
      empInviteStatus: json['empInviteStatus'],
      empCheckinStatus: json['empCheckinStatus'],
    );
  }

  // แปลงกลับเป็น JSON สำหรับยิง API ตอน Update Status
  Map<String, dynamic> toJson() {
    return {
      'empId': empId,
      'eveId': eveId,
      'empCheckinStatus': empCheckinStatus,
    };
  }

  // --- 💡 Usage-Driven Getters (เพิ่มเพื่อให้หน้า UI เขียนโค้ดง่ายขึ้น) ---

  // 1. เช็คว่าเช็คอินหรือยัง (Return เป็น bool)
  bool get isCheckedIn => empCheckinStatus == 1;

  // 2. จัดการสีตามสถานะการเช็คอิน
  Color get checkinColor => isCheckedIn ? Colors.green : Colors.grey;

  // 3. แปลสถานะการเชิญเป็นภาษาไทย
  String get inviteStatusLabel {
    switch (empInviteStatus) {
      case 'accepted':
        return 'ตอบรับแล้ว';
      case 'denied':
        return 'ปฏิเสธ';
      case 'pending':
        return 'รอการตอบรับ';
      case 'not_invite':
        return 'ไม่ได้เชิญ';
      default:
        return 'ไม่ระบุ';
    }
  }

  // 4. สีของสถานะการเชิญ
  Color get inviteStatusColor {
    switch (empInviteStatus) {
      case 'accepted':
        return Colors.blue;
      case 'denied':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
