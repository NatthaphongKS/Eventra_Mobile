class EventModel {
  final int? id;
  final String? evnTitle;
  final int? evnCategoryId;
  final String? evnDescription;
  final DateTime? evnDate;
  final String? evnTimeStart;
  final String? evnTimeEnd;
  final int? evnDuration;
  final String? evnLocation;
  final String? evnFile; // "have" or "not_have"
  final int? evnCreateBy;
  final DateTime? evnCreatedAt;
  final DateTime? evnDeletedAt;
  final int? evnDeletedBy;
  final String? evnStatus; // "done" or "upcoming"

  EventModel({
    this.id,
    this.evnTitle,
    this.evnCategoryId,
    this.evnDescription,
    this.evnDate,
    this.evnTimeStart,
    this.evnTimeEnd,
    this.evnDuration,
    this.evnLocation,
    this.evnFile,
    this.evnCreateBy,
    this.evnCreatedAt,
    this.evnDeletedAt,
    this.evnDeletedBy,
    this.evnStatus,
  });

  // แปลงจาก JSON เป็น Object (พร้อม Parse วันที่อัตโนมัติ)
  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      evnTitle: json['evn_title'],
      evnCategoryId: json['evn_category_id'],
      evnDescription: json['evn_description'],
      evnDate: json['evn_date'] != null
          ? DateTime.parse(json['evn_date'])
          : null,
      evnTimeStart: json['evn_timestart'],
      evnTimeEnd: json['evn_timeend'],
      evnDuration: json['evn_duration'],
      evnLocation: json['evn_location'],
      evnFile: json['evn_file'],
      evnCreateBy: json['evn_create_by'],
      evnCreatedAt: json['evn_created_at'] != null
          ? DateTime.parse(json['evn_created_at'])
          : null,
      evnDeletedAt: json['evn_deleted_at'] != null
          ? DateTime.parse(json['evn_deleted_at'])
          : null,
      evnDeletedBy: json['evn_deleted_by'],
      evnStatus: json['evn_status'],
    );
  }

  // แปลงจาก Object กลับเป็น JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'evn_title': evnTitle,
      'evn_category_id': evnCategoryId,
      'evn_description': evnDescription,
      'evn_date': evnDate?.toIso8601String(),
      'evn_timestart': evnTimeStart,
      'evn_timeend': evnTimeEnd,
      'evn_duration': evnDuration,
      'evn_location': evnLocation,
      'evn_file': evnFile,
      'evn_create_by': evnCreateBy,
      'evn_created_at': evnCreatedAt?.toIso8601String(),
      'evn_deleted_at': evnDeletedAt?.toIso8601String(),
      'evn_deleted_by': evnDeletedBy,
      'evn_status': evnStatus,
    };
  }

  // Helper สำหรับเช็คว่ามีไฟล์แนบไหม
  bool get hasFile => evnFile == 'have';

  // Helper สำหรับจัดรูปแบบเวลาโชว์หน้า UI (เช่น 09:00 - 10:30)
  String get timeRange => '$evnTimeStart - $evnTimeEnd';
}
