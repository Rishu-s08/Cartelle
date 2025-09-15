import 'package:flutter/foundation.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final List<String>? locations;
  final List<String>? listIds;
  final DateTime createdAt;
  final bool isAuthenticated;
  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.locations,
    this.listIds,
    required this.createdAt,
    required this.isAuthenticated,
  });

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    List<String>? locations,
    List<String>? listIds,
    DateTime? createdAt,
    bool? isAuthenticated,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      locations: locations ?? this.locations,
      listIds: listIds ?? this.listIds,
      createdAt: createdAt ?? this.createdAt,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'email': email,
      'name': name,
      'locations': locations,
      'listIds': listIds,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isAuthenticated': isAuthenticated,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      locations:
          map['locations'] != null
              ? List<String>.from((map['locations']))
              : null,
      listIds:
          map['listIds'] != null ? List<String>.from((map['listIds'])) : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      isAuthenticated: map['isAuthenticated'] as bool,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, name: $name, locations: $locations, listIds: $listIds, createdAt: $createdAt, isAuthenticated: $isAuthenticated)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.uid == uid &&
        other.email == email &&
        other.name == name &&
        listEquals(other.locations, locations) &&
        listEquals(other.listIds, listIds) &&
        other.createdAt == createdAt &&
        other.isAuthenticated == isAuthenticated;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        email.hashCode ^
        name.hashCode ^
        locations.hashCode ^
        listIds.hashCode ^
        createdAt.hashCode ^
        isAuthenticated.hashCode;
  }
}
