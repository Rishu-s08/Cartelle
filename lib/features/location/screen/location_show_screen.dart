import 'package:cartelle/core/common/loader.dart';
import 'package:cartelle/core/common/snackbar.dart';
import 'package:cartelle/core/constants/route_constants.dart';
import 'package:cartelle/core/errors/error_text.dart';
import 'package:cartelle/core/modals/location_model.dart';
import 'package:cartelle/core/permissions/location_permission.dart';
import 'package:cartelle/features/location/controller/location_controller.dart';
import 'package:cartelle/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationShowScreen extends ConsumerStatefulWidget {
  const LocationShowScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _LocationShowScreenState();
}

class _LocationShowScreenState extends ConsumerState<LocationShowScreen> {
  void navigateToAddLocation(BuildContext context) {
    context.pushNamed(RouteConstants.addLocationRoute);
  }

  void _openMapDialog(BuildContext context, LocationModel location) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(location.locationName),
          content: SizedBox(
            height: 300,
            width: 300,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(location.latitude, location.longitude),

                zoom: 15,
              ),
              circles: {
                Circle(
                  circleId: CircleId('location'),
                  center: LatLng(location.latitude, location.longitude),
                  radius: location.radiusInMeters.toDouble(),
                  fillColor: Colors.blue.withAlpha((0.2 * 255).toInt()),
                  strokeColor: Colors.blue,
                  strokeWidth: 2,
                ),
              },
              markers: {
                Marker(
                  markerId: const MarkerId('selected'),
                  position: LatLng(location.latitude, location.longitude),
                ),
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  bool _hasPermission = false;
  bool _checked = false;
  late List<String> locationIdList;

  @override
  void initState() {
    super.initState();
    final Future<List<LocationModel>> locationsLinkedWithList =
        ref
            .read(locationControllerProvider.notifier)
            .fetchLocationsLinkedToNotes();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final locations = await locationsLinkedWithList;
      locationIdList = locations.map((loc) => loc.locationId).toList();
      final result = await requestLocationPermission();
      result.match(
        (failure) {
          // Show error UI
          setState(() {
            _hasPermission = false;
            _checked = true;
          });
        },
        (_) {
          // Proceed to show location features
          setState(() {
            _hasPermission = true;
            _checked = true;
          });
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_checked) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_hasPermission) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Location permission is required to use this screen."),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: openAppSettings,
              child: const Text("Open App Settings"),
            ),
          ],
        ),
      );
    }

    return ref
        .watch(getUserLocationProvider)
        .when(
          data: (data) {
            return Scaffold(
              // appBar: AppBar(title: const Text("Your Locations")),
              body:
                  data.isEmpty
                      ? const Center(child: Text("No locations found"))
                      : Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0,
                            ),
                            child: Text(
                              "📍 Your Locations",
                              style: AppTheme
                                  .cupcakeLightTheme
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF444444),
                                    letterSpacing: 0.5,
                                  ),
                            ),
                          ),

                          Expanded(
                            child: ListView.builder(
                              itemCount: data.length,
                              itemBuilder: (context, index) {
                                final loc = data[index];
                                return Dismissible(
                                  key: Key(loc.locationId),
                                  direction: DismissDirection.endToStart,
                                  dismissThresholds: {
                                    DismissDirection.endToStart:
                                        0.4, // needs 40% swipe before deleting
                                  },
                                  movementDuration: const Duration(
                                    milliseconds: 400,
                                  ), // slower animation
                                  resizeDuration: const Duration(
                                    milliseconds: 300,
                                  ), // smooth shrinking // swipe left to delete
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    color: Colors.red,
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                  ),
                                  confirmDismiss: (direction) async {
                                    bool isInUse = locationIdList.contains(
                                      loc.locationId,
                                    );
                                    if (isInUse) {
                                      return await showDialog(
                                        context: context,
                                        builder:
                                            (ctx) => AlertDialog(
                                              title: const Text(
                                                "Location in use",
                                              ),
                                              content: const Text(
                                                "This location cannot be deleted, as it is linked to one of the shopping lists.",
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.of(
                                                        ctx,
                                                      ).pop(false),
                                                  child: const Text("OK!"),
                                                ),
                                                // TextButton(
                                                //   onPressed:
                                                //       () => Navigator.of(ctx).pop(true),
                                                //   child: const Text("Remove"),
                                                // ),
                                              ],
                                            ),
                                      );
                                    }
                                    return true; // allow delete
                                  },
                                  onDismissed: (direction) {
                                    deleteLocation(loc.locationId);
                                    showSnackbar(
                                      context,
                                      "${loc.locationName} deleted",
                                    );
                                  },
                                  child: Card(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    child: ListTile(
                                      leading: const Icon(Icons.location_on),
                                      title: Text(loc.locationName),

                                      subtitle: Text(
                                        'Lat: ${loc.latitude},\nLng: ${loc.longitude}',
                                      ),
                                      trailing: const Icon(Icons.map),
                                      onTap: () => _openMapDialog(context, loc),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
              floatingActionButton: FloatingActionButton(
                heroTag: 'unique_fab_add_location',
                onPressed: () => navigateToAddLocation(context),
                tooltip: 'Add Location',
                elevation: 16,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Icons.add_location_alt_rounded),
              ),
            );
          },
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => Loader(),
        );
  }

  void deleteLocation(location) {
    ref
        .read(locationControllerProvider.notifier)
        .deleteLocation(location, context);
  }
}
