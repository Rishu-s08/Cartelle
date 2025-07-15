import 'package:cartelle/core/common/snackbar.dart';
import 'package:cartelle/core/modals/location_model.dart';
import 'package:cartelle/features/auth/controller/auth_controller.dart';
import 'package:cartelle/features/location/repository/location_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final locationControllerProvider =
    StateNotifierProvider<LocationController, bool>((ref) {
      return LocationController(
        locationRepository: ref.watch(locationRepositoryProvider),
        ref: ref,
      );
    });

final getUserLocationProvider = StreamProvider((ref) {
  return ref.read(locationControllerProvider.notifier).getUserLocations();
});

class LocationController extends StateNotifier<bool> {
  final LocationRepository _locationRepository;
  final Ref _ref;
  LocationController({
    required LocationRepository locationRepository,
    required Ref ref,
  }) : _locationRepository = locationRepository,
       _ref = ref,
       super(false);

  void saveLocation({
    required double latitude,
    required double longitude,
    required String locationName,
    required double radiusInMeters,
    required BuildContext context,
  }) async {
    state = true;
    final userId = _ref.read(userProvider)!.uid;

    final res = await _locationRepository.saveLocation(
      latitude: latitude,
      longitude: longitude,
      userId: userId,
      locationName: locationName,
      radiusInMeters: radiusInMeters,
    );
    state = false;
    res.fold((l) => showSnackbar(context, l.message), (r) {
      showSnackbar(context, "Location saved successfully!");
    });
  }

  Stream<List<LocationModel>> getUserLocations() {
    final userId = _ref.read(userProvider)!.uid;
    return _locationRepository.getUserLocations(userId);
  }
}
