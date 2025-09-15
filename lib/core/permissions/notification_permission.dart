import 'package:cartelle/core/common/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestNotificationPermissions(BuildContext context) async {
  await Permission.notification.request();
  if (await Permission.notification.isGranted) {
    print('Notification permissions granted');
  } else {
    print('Notification permissions nopt granted');
    if (context.mounted) {
      showSnackbar(
        context,
        "Notification permissions are needed for the core features of the app. Please enable them in the settings.",
        duration: Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Open Settings',
          onPressed: () async {
            await openAppSettings();
          },
        ),
      );
    }
  }
}

final _plugin = FlutterLocalNotificationsPlugin();

Future<void> requestExactAlarmPermission() async {
  final bool? granted =
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestExactAlarmsPermission();

  print("Exact alarm granted: $granted");
}
