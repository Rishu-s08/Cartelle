// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final List<String>? locations;
  final DateTime createdAt;
  final bool isAuthenticated;
  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.locations,
    required this.createdAt,
    required this.isAuthenticated,
  });

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    List<String>? locations,
    DateTime? createdAt,
    bool? isAuthenticated,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      locations: locations ?? this.locations,
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
              ? List<String>.from((map['locations'] as List<String>))
              : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      isAuthenticated: map['isAuthenticated'] as bool,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, name: $name, locations: $locations, createdAt: $createdAt, isAuthenticated: $isAuthenticated)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.uid == uid &&
        other.email == email &&
        other.name == name &&
        listEquals(other.locations, locations) &&
        other.createdAt == createdAt &&
        other.isAuthenticated == isAuthenticated;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        email.hashCode ^
        name.hashCode ^
        locations.hashCode ^
        createdAt.hashCode ^
        isAuthenticated.hashCode;
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
