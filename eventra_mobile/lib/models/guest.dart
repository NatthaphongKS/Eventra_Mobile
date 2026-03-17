class Guest {
  final int id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? avatarUrl;
  bool isInvited;
  bool isCheckedIn;

  Guest({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.avatarUrl,
    this.isInvited = false,
    this.isCheckedIn = false,
  });

  String get fullName => '$firstName $lastName';

  factory Guest.fromJson(Map<String, dynamic> json) {
    return Guest(
      id: json['id'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'],
      avatarUrl: json['avatar_url'],
      isInvited: json['is_invited'] ?? false,
      isCheckedIn: json['is_checked_in'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'avatar_url': avatarUrl,
      'is_invited': isInvited,
      'is_checked_in': isCheckedIn,
    };
  }
}
