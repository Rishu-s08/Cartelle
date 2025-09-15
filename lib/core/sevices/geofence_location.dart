import 'package:cartelle/core/sevices/notification_service.dart';
import 'package:cartelle/features/location/controller/location_controller.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GeofenceLocation {
  final WidgetRef ref;

  GeofenceLocation({required this.ref});

  Future<void> initGeofences() async {
    // 1. Configure plugin
    await bg.BackgroundGeolocation.ready(
      bg.Config(
        desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
        distanceFilter: 50,
        stopOnTerminate: false, // App killed? Keep tracking
        startOnBoot: true, // Reboot? Start tracking
        enableHeadless: true, // Needed for background trigger
        debug: false,
        heartbeatInterval: 5200,
        logLevel: bg.Config.LOG_LEVEL_VERBOSE,
      ),
    );

    // 3. Start the plugin if not already started
    final state = await bg.BackgroundGeolocation.state;
    if (!state.enabled) {
      await bg.BackgroundGeolocation.start();
    }

    // 2. Sync with Firestore (add missing geofences etc.)
    ref.read(locationControllerProvider.notifier).syncGeofencesOnStartup();

    // 4. Setup event listener for foreground triggers
    setupGeofenceListener();
  }

  void setupGeofenceListener() {
    bg.BackgroundGeolocation.onGeofence((bg.GeofenceEvent event) {
      print('inside onGeofence not headless');
      if (event.action == 'ENTER') {
        print('inside event.action == ENTER not headless');
        NotificationService.showNotification(
          title: 'You’ve entered a location!',
          body: 'You just entered ${event.identifier}',
        );
      }
    });
  }
}

/// Handles background geofence events when app is killed or in background
@pragma('vm:entry-point')
void backgroundGeofenceHeadlessTask(bg.HeadlessEvent headlessEvent) async {
  if (headlessEvent.name == bg.Event.BOOT ||
      headlessEvent.name == bg.Event.HEARTBEAT) {
    final container = ProviderContainer();
    await container
        .read(locationControllerProvider.notifier)
        .syncGeofencesOnStartup();
  }
  if (headlessEvent.name == bg.Event.GEOFENCE) {
    print('inside headless task');
    print(headlessEvent.event);
    final event = headlessEvent.event as bg.GeofenceEvent;

    if (event.action == 'ENTER') {
      print('inside event.action == ENTER');

      final notificationService = NotificationService();
      await notificationService.initialize();
      await NotificationService.showNotification(
        title: 'Entered ${event.identifier}',
        body: 'Triggered while app was killed',
      );
    }
  }
}
