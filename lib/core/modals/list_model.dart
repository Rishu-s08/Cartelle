import 'package:flutter/foundation.dart';

class ListModel {
  final String id;
  final String listName;
  final List<String> listItems;
  final String location;
  final DateTime createdAt;
  final String userId;
  final String locationId;
  final Map<String, bool> completedItems;
  ListModel({
    required this.id,
    required this.listName,
    required this.listItems,
    required this.location,
    required this.createdAt,
    required this.userId,
    required this.locationId,
    required this.completedItems,
  });

  ListModel copyWith({
    String? id,
    String? listName,
    List<String>? listItems,
    String? location,
    DateTime? createdAt,
    String? userId,
    String? locationId,
    Map<String, bool>? completedItems,
  }) {
    return ListModel(
      id: id ?? this.id,
      listName: listName ?? this.listName,
      listItems:
          listItems != null ? List.from(listItems) : List.from(this.listItems),
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      locationId: locationId ?? this.locationId,
      completedItems:
          completedItems != null
              ? Map.from(completedItems)
              : Map.from(this.completedItems),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'listName': listName,
      'listItems': listItems,
      'location': location,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'userId': userId,
      'locationId': locationId,
      'completedItems': completedItems,
    };
  }

  factory ListModel.fromMap(Map<String, dynamic> map) {
    return ListModel(
      id: map['id'] as String,
      listName: map['listName'] as String,
      listItems: List<String>.from((map['listItems'])),
      location: map['location'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      userId: map['userId'] as String,
      locationId: map['locationId'] as String,
      completedItems: Map<String, bool>.from((map['completedItems'])),
    );
  }
  @override
  String toString() {
    return 'ListModel(id: $id, listName: $listName, listItems: $listItems, location: $location, createdAt: $createdAt, userId: $userId, locationId: $locationId, completedItems: $completedItems)';
  }

  @override
  bool operator ==(covariant ListModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.listName == listName &&
        listEquals(other.listItems, listItems) &&
        other.location == location &&
        other.createdAt == createdAt &&
        other.userId == userId &&
        other.locationId == locationId &&
        mapEquals(other.completedItems, completedItems);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        listName.hashCode ^
        listItems.hashCode ^
        location.hashCode ^
        createdAt.hashCode ^
        userId.hashCode ^
        locationId.hashCode ^
        completedItems.hashCode;
  }
}
