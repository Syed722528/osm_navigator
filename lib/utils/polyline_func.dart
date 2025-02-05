import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

double calculateDistance(LatLng start, LatLng end) {
  return Geolocator.distanceBetween(
    start.latitude, start.longitude, end.latitude, end.longitude
  ) / 1000; // in km
}

double estimateTime(double distance, double speed) {
  return distance / speed; // time in hours
}