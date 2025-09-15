import 'package:cartelle/core/constants/firebase_constants.dart';
import 'package:cartelle/core/failure.dart';
import 'package:cartelle/core/modals/location_model.dart';
import 'package:cartelle/core/providers/firebase_providers.dart';
import 'package:cartelle/core/typedefs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
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
  CollectionReference get _lists =>
      _firestore.collection(FirebaseConstants.listsCollection);

  FutureEither<LocationModel> saveLocation({
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
        'locations': FieldValue.arrayUnion([location.locationId]),
      });

      return right(location);
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

  Future<List<String>> getRegisteredGeofenceIds(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    final data = doc.data();
    if (data == null || !data.containsKey('geofencesLocations')) return [];

    return List<String>.from(data['geofencesLocations']);
  }

  // Future<List<Map<String, dynamic>>> fetchSavedLocations(String uid) async {
  //   final snapshot =
  //       await FirebaseFirestore.instance
  //           .collection('users')
  //           .doc(uid)
  //           .collection('locations')
  //           .get();

  //   return snapshot.docs.map((doc) => doc.data()).toList();
  // }

  //   Future<void> syncGeofencesOnStartup(String uid) async {
  //     final firestoreIds = await getRegisteredGeofenceIds(uid);
  //     final savedLocations = await fetchSavedLocations(uid);
  //     final List<String> newlyAdded = [];
  //     for (final loc in savedLocations) {
  //       final id = loc['locationId'] as String;
  //       // Check if geofence is currently active on device
  //       final geofence = await bg.BackgroundGeolocation.getGeofence(id);
  //       if (geofence == null) {
  //         // Add geofence if not already active
  //         await bg.BackgroundGeolocation.addGeofence(
  //           bg.Geofence(
  //             identifier: id,
  //             latitude: loc['latitude'],
  //             longitude: loc['longitude'],
  //             radius: loc['radiusInMeters'],
  //             notifyOnEntry: true,
  //             notifyOnExit: true,
  //           ),
  //         );
  //         newlyAdded.add(id);
  //         print("Added geofence: $id");
  //       } else {
  //         print("Already active: $id");
  //       }
  //     }
  //     // Update Firestore only if there are any newly added geofences
  //     if (newlyAdded.isNotEmpty) {
  //       final updatedIds = {...firestoreIds, ...newlyAdded}.toList();
  //       await _user.doc(uid).update({'geofencesLocation': updatedIds});
  //     }
  //   }
  // }

  Future<void> syncGeofencesOnStartup(String uid) async {
    // 1. Get locations linked to notes for this user
    final linkedLocations = await fetchLocationsLinkedToNotes(uid);

    // 2. Clear all existing geofences on device
    await bg.BackgroundGeolocation.removeGeofences();

    // 3. Add only the linked locations
    for (final loc in linkedLocations) {
      await bg.BackgroundGeolocation.addGeofence(
        bg.Geofence(
          identifier: loc.locationId,
          latitude: loc.latitude,
          longitude: loc.longitude,
          radius: loc.radiusInMeters,
          notifyOnEntry: true,
          notifyOnExit: true,
        ),
      );
      print("Added geofence for linked location: ${loc.locationName}");
    }

    print(
      "Geofence sync complete. Total registered: ${linkedLocations.length}",
    );
  }

  /// Helper: Fetch only locations that are linked to notes
  Future<List<LocationModel>> fetchLocationsLinkedToNotes(String uid) async {
    // Get all notes for the user that have a locationId field set
    final notesSnap =
        await _lists
            .where('userId', isEqualTo: uid)
            .where('locationId', isNotEqualTo: null)
            .get();

    final linkedLocationIds =
        notesSnap.docs
            .map((doc) => doc['locationId'] as String)
            .toSet(); // avoid duplicates

    if (linkedLocationIds.isEmpty) return [];

    // Fetch those locations from locationsCollection
    final locSnap =
        await _locations
            .where('locationId', whereIn: linkedLocationIds.toList())
            .get();

    return locSnap.docs
        .map((doc) => LocationModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  FutureVoid deleteLocation(String locationId, String userId) async {
    try {
      await _locations.doc(locationId).delete();
      await _user.doc(userId).update({
        'locationId': FieldValue.arrayRemove([locationId]),
      });
      return right(null);
    } catch (e) {
      return left(Failure("Failed to delete location"));
    }
  }
}
