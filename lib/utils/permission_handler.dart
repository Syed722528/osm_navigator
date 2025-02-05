import 'package:geolocator/geolocator.dart';
 //--------------Add more permission as per requirement-------------------------//
class PermissionHandler {
  static Future<bool> isLocationPermissionGranted() async {
    // Requesting location permission
    var status = await Geolocator.requestPermission();

    if (status == LocationPermission.whileInUse ||
        status == LocationPermission.always) {
      return true; // Permission granted
    } else {
      return false; // Permission denied or restricted
    }
  }
}
