import 'package:cartelle/core/constants/firebase_constants.dart';
import 'package:cartelle/core/failure.dart';
import 'package:cartelle/core/modals/location_model.dart';
import 'package:cartelle/core/providers/firebase_providers.dart';
import 'package:cartelle/core/typedefs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

final locationRepositoryProvider = Provider((ref) {
  return LocationRepository(firestore: ref.read(firebaseFirestoreProvider));
});

class LocationRepository {
  final FirebaseFirestore _firestore;
  LocationRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  CollectionReference get _locations =>
      _firestore.collection(FirebaseConstants.locationsCollection);
  CollectionReference get _user =>
      _firestore.collection(FirebaseConstants.usersCollection);

  FutureVoid saveLocation({
    required double latitude,
    required double longitude,
    required String userId,
    required String locationName,
    required double radiusInMeters,
  }) async {
    try {
      final location = LocationModel(
        locationId: Uuid().v4(),
        locationName: locationName,
        latitude: latitude,
        longitude: longitude,
        userId: userId,
        radiusInMeters: radiusInMeters,
        createdAt: DateTime.now(),
      );
      await _locations.doc(location.locationId).set(location.toMap());
      await _user.doc(userId).update({
        'loctions': FieldValue.arrayUnion([location.locationId]),
      });
      return right(null);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<LocationModel>> getUserLocations(String userId) {
    return _locations
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (event) =>
              event.docs
                  .map(
                    (doc) => LocationModel.fromMap(
                      doc.data() as Map<String, dynamic>,
                    ),
                  )
                  .toList(),
        );
  }
}
