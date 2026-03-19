class EmployeeModel {
  final int? id;
  final String? empCompanyId;
  final String? empId;
  final String? empPrefix;
  final String? empFirstname;
  final String? empLastname;
  final String? empNickname;
  final String? empEmail;
  final String? empPhone;
  final int? empPositionId;
  final int? empDepartmentId;
  final int? empTeamId;
  final String? empPermission;
  final String? empDeleteStatus;
  final String? empCreatedAt;
  final String? positionName;
  final String? departmentName;
  final String? teamName;

  EmployeeModel({
    this.id,
    this.empCompanyId,
    this.empId,
    this.empPrefix,
    this.empFirstname,
    this.empLastname,
    this.empNickname,
    this.empEmail,
    this.empPhone,
    this.empPositionId,
    this.empDepartmentId,
    this.empTeamId,
    this.empPermission,
    this.empDeleteStatus,
    this.empCreatedAt,
    this.positionName,
    this.departmentName,
    this.teamName,
  });

  // แปลงจาก JSON Map เป็น Object
  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'],
      empCompanyId: json['emp_company_id'],
      empId: json['emp_id'],
      empPrefix: json['emp_prefix'],
      empFirstname: json['emp_firstname'],
      empLastname: json['emp_lastname'],
      empNickname: json['emp_nickname'],
      empEmail: json['emp_email'],
      empPhone: json['emp_phone'],
      empPositionId: json['emp_position_id'],
      empDepartmentId: json['emp_department_id'],
      empTeamId: json['emp_team_id'],
      empPermission: json['emp_permission'],
      empDeleteStatus: json['emp_delete_status'],
      empCreatedAt: json['emp_created_at'],
      positionName: json['position_name'],
      departmentName: json['department_name'],
      teamName: json['team_name'],
    );
  }

  // แปลงจาก Object กลับเป็น JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'emp_company_id': empCompanyId,
      'emp_id': empId,
      'emp_prefix': empPrefix,
      'emp_firstname': empFirstname,
      'emp_lastname': empLastname,
      'emp_nickname': empNickname,
      'emp_email': empEmail,
      'emp_phone': empPhone,
      'emp_position_id': empPositionId,
      'emp_department_id': empDepartmentId,
      'emp_team_id': empTeamId,
      'emp_permission': empPermission,
      'emp_delete_status': empDeleteStatus,
      'emp_created_at': empCreatedAt,
      'position_name': positionName,
      'department_name': departmentName,
      'team_name': teamName,
    };
  }

  // ฟังก์ชันช่วยดึงชื่อเต็ม
  String get fullName => '$empPrefix$empFirstname $empLastname';
}
