import 'package:cartelle/core/common/loader.dart';
import 'package:cartelle/core/constants/constants.dart';
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

final mockLocationsProvider = Provider<List<LocationModel>>((ref) {
  return [
    LocationModel(
      locationId: '1',
      locationName: 'Big Bazaar - Sector 21',
      latitude: 28.6139,
      userId: "test",
      radiusInMeters: 32,
      createdAt: DateTime.now(),
      longitude: 77.2090,
    ),
    LocationModel(
      locationId: '2',
      locationName: 'Reliance Fresh - Ring Road',
      latitude: 28.6200,
      userId: "test",
      radiusInMeters: 32,
      createdAt: DateTime.now(),
      longitude: 77.2200,
    ),
    LocationModel(
      locationId: '3',
      locationName: 'D-Mart - Outer Delhi',
      latitude: 28.6300,
      userId: "test",
      radiusInMeters: 32,
      createdAt: DateTime.now(),
      longitude: 77.2000,
    ),
  ];
});

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
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
              body: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: Text(
                      "📍 Your Locations",
                      style: AppTheme.cupcakeLightTheme.textTheme.headlineSmall
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
                        return Card(
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
}
