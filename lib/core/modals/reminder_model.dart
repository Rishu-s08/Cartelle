// ignore_for_file: public_member_api_docs, sort_constructors_first

class ReminderModel {
  final String title;
  final DateTime dateTime;
  final String id;
  final String userId;
  final bool isActive;
  final DateTime? createdAt;
  ReminderModel({
    required this.title,
    required this.dateTime,
    required this.id,
    required this.userId,
    required this.isActive,
    this.createdAt,
  });

  ReminderModel copyWith({
    String? title,
    DateTime? dateTime,
    String? id,
    String? userId,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return ReminderModel(
      title: title ?? this.title,
      dateTime: dateTime ?? this.dateTime,
      id: id ?? this.id,
      userId: userId ?? this.userId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'dateTime': dateTime.millisecondsSinceEpoch,
      'id': id,
      'userId': userId,
      'isActive': isActive,
      'createdAt': createdAt?.millisecondsSinceEpoch,
    };
  }

  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      title: map['title'] as String,
      dateTime: DateTime.fromMillisecondsSinceEpoch(map['dateTime'] as int),
      id: map['id'] as String,
      userId: map['userId'] as String,
      isActive: map['isActive'] as bool,
      createdAt:
          map['createdAt'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
              : null,
    );
  }

  @override
  String toString() {
    return 'ReminderModel(title: $title, dateTime: $dateTime, id: $id, userId: $userId, isActive: $isActive, createdAt: $createdAt)';
  }

  @override
  bool operator ==(covariant ReminderModel other) {
    if (identical(this, other)) return true;

    return other.title == title &&
        other.dateTime == dateTime &&
        other.id == id &&
        other.userId == userId &&
        other.isActive == isActive &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        dateTime.hashCode ^
        id.hashCode ^
        userId.hashCode ^
        isActive.hashCode ^
        createdAt.hashCode;
  }
}
