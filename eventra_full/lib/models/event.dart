class Event {
  final int id;
  final String name;
  final String description;
  final String location;
  final DateTime date;
  final String startTime;
  final String endTime;
  final int participantCount;
  final String status; // 'upcoming', 'ongoing', 'done'

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.participantCount,
    required this.status,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      date: DateTime.parse(json['date']),
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      participantCount: json['participant_count'] ?? 0,
      status: json['status'] ?? 'upcoming',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': location,
      'date': date.toIso8601String(),
      'start_time': startTime,
      'end_time': endTime,
      'participant_count': participantCount,
      'status': status,
    };
  }

  Event copyWith({
    int? id,
    String? name,
    String? description,
    String? location,
    DateTime? date,
    String? startTime,
    String? endTime,
    int? participantCount,
    String? status,
  }) {
    return Event(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      participantCount: participantCount ?? this.participantCount,
      status: status ?? this.status,
    );
  }
}
