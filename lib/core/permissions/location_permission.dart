import 'package:cartelle/core/failure.dart';
import 'package:cartelle/core/typedefs.dart';
import 'package:fpdart/fpdart.dart';
import 'package:permission_handler/permission_handler.dart';

FutureVoid requestLocationPermission() async {
  var status = await Permission.location.status;

  if (status.isDenied || status.isRestricted) {
    status = await Permission.location.request();
  }

  if (status.isGranted) {
    return right(null);
  } else if (status.isPermanentlyDenied) {
    await openAppSettings();
    return left(
      Failure(
        "For accessing location Feature, please enable it in the app settings.",
      ),
    );
  } else {
    return left(
      Failure(
        "For accessing location Feature, please enable it in the app settings.",
      ),
    );
  }
}
