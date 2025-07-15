// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// // import 'selected_location_provider.dart';
// // import 'location_model.dart';

// class AddLocationScreen extends ConsumerStatefulWidget {
//   const AddLocationScreen({super.key});

//   @override
//   ConsumerState<AddLocationScreen> createState() => _AddLocationScreenState();
// }

// class _AddLocationScreenState extends ConsumerState<AddLocationScreen> {
//   GoogleMapController? _mapController;
//   LatLng? _pickedLatLng;
//   TextEditingController _nameController = TextEditingController();

//   void _onTapMap(LatLng pos) {
//     setState(() {
//       _pickedLatLng = pos;
//     });
//   }

//   void _saveLocation() {
//     // if (_pickedLatLng != null && _nameController.text.trim().isNotEmpty) {
//     //   final location = LocationModel(
//     //     id: DateTime.now().millisecondsSinceEpoch.toString(),
//     //     name: _nameController.text.trim(),
//     //     latitude: _pickedLatLng!.latitude,
//     //     longitude: _pickedLatLng!.longitude,
//     //   );
//     //   ref.read(selectedLocationProvider.notifier).state = location;
//     //   Navigator.pop(context);
//     // } else {
//     //   ScaffoldMessenger.of(context).showSnackBar(
//     //     const SnackBar(
//     //       content: Text("Please select a location and enter a name."),
//     //     ),
//     //   );
//     // }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // final selected = ref.watch(selectedLocationProvider);

//     return Scaffold(
//       appBar: AppBar(title: const Text("Add Location")),
//       body: Column(
//         children: [
//           SizedBox(
//             height: 400,
//             child: GoogleMap(
//               initialCameraPosition: const CameraPosition(
//                 target: LatLng(28.6139, 77.2090),
//                 zoom: 13,
//               ),
//               onMapCreated: (controller) => _mapController = controller,
//               onTap: _onTapMap,
//               markers:
//                   _pickedLatLng != null
//                       ? {
//                         Marker(
//                           markerId: const MarkerId("picked"),
//                           position: _pickedLatLng!,
//                         ),
//                       }
//                       : {},
//             ),
//           ),
//           const SizedBox(height: 16),
//           if (_pickedLatLng != null) ...[
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               child: TextField(
//                 controller: _nameController,
//                 decoration: const InputDecoration(
//                   labelText: "Location Name",
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton.icon(
//               onPressed: _saveLocation,
//               icon: const Icon(Icons.save_alt_rounded),
//               label: const Text("Save Location"),
//             ),
//           ] else
//             const Padding(
//               padding: EdgeInsets.only(top: 16),
//               child: Text("Tap on the map to select a location."),
//             ),
//         ],
//       ),
//     );
//   }
// }

import 'package:cartelle/features/location/controller/location_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class AddLocationScreen extends ConsumerStatefulWidget {
  const AddLocationScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddLocationScreenState();
}

class _AddLocationScreenState extends ConsumerState<AddLocationScreen> {
  Set<Circle> circles = {};
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  String _locationName = '';
  double _radius = 100.0;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  void _addRadiusCircle(LatLng center, double radiusInMeters) {
    circles = {
      Circle(
        circleId: CircleId("radius_circle"),
        center: center,
        radius: radiusInMeters,
        fillColor: Colors.blue.withAlpha((0.2 * 255).toInt()),
        strokeColor: Colors.blue,
        strokeWidth: 2,
      ),
    };
    setState(() {});
  }

  Future<void> _initLocation() async {
    final hasPermission = await Geolocator.checkPermission();
    if (hasPermission == LocationPermission.denied ||
        hasPermission == LocationPermission.deniedForever) {
      await Geolocator.requestPermission();
    }

    final pos = await Geolocator.getCurrentPosition();
    _selectedLocation = LatLng(pos.latitude, pos.longitude);
    await _updateLocationName(_selectedLocation!);
    setState(() {
      _loading = false;
    });
  }

  Future<void> _updateLocationName(LatLng latLng) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _locationName =
              "${place.name ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}";
        });
      }
    } catch (e) {
      debugPrint("❌ Error getting address: $e");
    }
  }

  void _onMapTap(LatLng latLng) async {
    setState(() => _selectedLocation = latLng);
    await _updateLocationName(latLng);
  }

  void _onSave() {
    if (_selectedLocation == null) return;
    ref
        .read(locationControllerProvider.notifier)
        .saveLocation(
          latitude: _selectedLocation!.latitude,
          longitude: _selectedLocation!.longitude,
          locationName: _locationName,
          radiusInMeters: _radius,
          context: context,
        );
    debugPrint("✅ Location saved: $_locationName at $_selectedLocation");
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Location", overflow: TextOverflow.ellipsis),
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _selectedLocation!,
                zoom: 16,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId("selected"),
                  position: _selectedLocation!,
                  draggable: true,
                  onDragEnd: _onMapTap,
                ),
              },
              circles: circles,
              onMapCreated: (controller) {
                _addRadiusCircle(_selectedLocation!, 200);
                _mapController = controller; // radius in meters
              },
              // onMapCreated: (controller) => _mapController = controller,
              onTap: _onMapTap,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Location Name",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: TextEditingController(text: _locationName),
                  readOnly: false,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Radius (meters)",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Slider(
                  value: _radius,
                  min: 50,
                  max: 1000,
                  divisions: 19,
                  label: '${_radius.toInt()} m',
                  onChanged: (value) {
                    setState(() {
                      _radius = value;
                      _addRadiusCircle(_selectedLocation!, _radius);
                    });
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _onSave,
                    icon: const Icon(Icons.save),
                    label: const Text("Save Location"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.teal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
