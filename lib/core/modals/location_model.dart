class LocationModel {
  final String locationId;
  final String locationName;
  final double latitude;
  final double longitude;
  final String userId;
  final double radiusInMeters;
  final String? typeOfLocation; // grocery, restaurant, etc.
  final DateTime createdAt;
  LocationModel({
    required this.locationId,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.userId,
    required this.radiusInMeters,
    this.typeOfLocation,
    required this.createdAt,
  });

  LocationModel copyWith({
    String? locationId,
    String? locationName,
    double? latitude,
    double? longitude,
    String? userId,
    double? radiusInMeters,
    String? typeOfLocation,
    DateTime? createdAt,
  }) {
    return LocationModel(
      locationId: locationId ?? this.locationId,
      locationName: locationName ?? this.locationName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      userId: userId ?? this.userId,
      radiusInMeters: radiusInMeters ?? this.radiusInMeters,
      typeOfLocation: typeOfLocation ?? this.typeOfLocation,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'locationId': locationId,
      'locationName': locationName,
      'latitude': latitude,
      'longitude': longitude,
      'userId': userId,
      'radiusInMeters': radiusInMeters,
      'typeOfLocation': typeOfLocation,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      locationId: map['locationId'] as String,
      locationName: map['locationName'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      userId: map['userId'] as String,
      radiusInMeters: map['radiusInMeters'] as double,
      typeOfLocation:
          map['typeOfLocation'] != null
              ? map['typeOfLocation'] as String
              : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }
  @override
  String toString() {
    return 'LocationModel(locationId: $locationId, locationName: $locationName, latitude: $latitude, longitude: $longitude, userId: $userId, radiusInMeters: $radiusInMeters, typeOfLocation: $typeOfLocation, createdAt: $createdAt)';
  }

  @override
  bool operator ==(covariant LocationModel other) {
    if (identical(this, other)) return true;

    return other.locationId == locationId &&
        other.locationName == locationName &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.userId == userId &&
        other.radiusInMeters == radiusInMeters &&
        other.typeOfLocation == typeOfLocation &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return locationId.hashCode ^
        locationName.hashCode ^
        latitude.hashCode ^
        longitude.hashCode ^
        userId.hashCode ^
        radiusInMeters.hashCode ^
        typeOfLocation.hashCode ^
        createdAt.hashCode;
  }
}
