import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class SelectedLocationsProvider extends ChangeNotifier {
  String? _locationData = 'Tap on map or search for a location';
  String? _locationCity = 'Hello Syed';
  double? _lat;
  double? _lon;
  String? get locationData => _locationData;
  String? get locationCity => _locationCity;

  double? get lat => _lat;
  double? get lon => _lon;

  void updateLocations(String newLocationCity, String newlocationData,
      double newLat, double newLon) {
    _locationCity = newLocationCity;
    _locationData = newlocationData;
    _lat = newLat;
    _lon = newLon;
    notifyListeners();
  }
}

class RouteProvider with ChangeNotifier {
  List<LatLng>? _carRoute;
  double? _carDistance = 0;
  double? _carDuration = 0;

  List<LatLng>? _bikeRoute;
  double? _bikeDistance = 0;
  double? _bikeDuration = 0;

  List<LatLng>? _walkRoute;
  double? _walkDistance = 0;
  double? _walkDuration = 0;

  List<LatLng>? get carRoute => _carRoute;
  double? get carDistance => _carDistance;
  double? get carDuration => _carDuration;

  List<LatLng>? get bikeRoute => _bikeRoute;
  double? get bikeDistance => _bikeDistance;
  double? get bikeDuration => _bikeDuration;

  List<LatLng>? get walkRoute => _walkRoute;
  double? get walkDistance => _walkDistance;
  double? get walkDuration => _walkDuration;

  void updateCarRoute(List<LatLng> route, double distance, double duration) {
    _carRoute = route;
    _carDistance = distance;
    _carDuration = duration;
    notifyListeners();
  }

  void updateBikeRoute(List<LatLng> route, double distance, double duration) {
    _bikeRoute = route;
    _bikeDistance = distance;
    _bikeDuration = duration;
    notifyListeners();
  }

  void updateWalkRoute(List<LatLng> route, double distance, double duration) {
    _walkRoute = route;
    _walkDistance = distance;
    _walkDuration = duration;
    notifyListeners();
  }

  void clearRoutes() {
    if (_carRoute != null) {
      _carRoute = null;
    }
    if (_bikeRoute != null) {
      _bikeRoute = null;
    }
    if (_walkRoute != null) {
      _walkRoute = null;
    }

    notifyListeners();
  }
}

class MarkerProvider extends ChangeNotifier {
  final List<Marker> _markers = [];

  List<Marker> get marker => _markers;

  void updateMarker(Marker marker) {
    _markers.add(marker);
    notifyListeners();
  }

  void removeMarkers() {
    _markers.clear();
    notifyListeners();
  }
}

class SelectedRouteProvider extends ChangeNotifier {
  String _vehicleType = 'car';

  String get vehicleType => _vehicleType;

  void updateSelectedRoute(String type) {
    _vehicleType = type;
    notifyListeners();
  }
}


class FloatingActionButtonMenuProvider extends ChangeNotifier{
  bool _isMenuOpen = false;

  bool get isMenuOpen => _isMenuOpen;

  void updateMenuOption(){
    _isMenuOpen =! _isMenuOpen;
    notifyListeners();
  }
}