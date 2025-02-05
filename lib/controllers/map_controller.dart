// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:osm_navigator/provider/map_providers.dart';
import 'package:osm_navigator/services/map_services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/show_alert.dart';

class MapControllerHelper {
  List<TextEditingController> controllers = [TextEditingController()];
  final _mapController = MapController();
  final _locationService = MapServices();

  bool isLiked = false;
  bool isSaved = false;

  bool isMenuOpen = false;

  String vehicleType = 'vehicle';

  MapController get mapController => _mapController;

  void addTextField() {
    controllers.add(TextEditingController());
  }

  void removeTextField(int index) {
    if (controllers.length > 1) {
      controllers[index].dispose();
      controllers.removeAt(index);
    }
  }

//--------------------Function to Zoom in -----------------------//
  void zoomIn() {
    _mapController.move(
        _mapController.camera.center, _mapController.camera.zoom + 1);
  }
//--------------------Function to Zoom Out -----------------------//

  void zoomOut() {
    _mapController.move(
        _mapController.camera.center, _mapController.camera.zoom - 1);
  }

  //--------------------Function to Add marker on the map-----------------------//
  void addMarker(
      LatLng position, bool removePreviousMarker, BuildContext context) async {
    if (removePreviousMarker) {
      Provider.of<MarkerProvider>(context, listen: false).removeMarkers();
      Provider.of<RouteProvider>(context, listen: false).clearRoutes();
    }
    Provider.of<MarkerProvider>(context, listen: false).updateMarker(Marker(
        point: position,
        child: Icon(
          Icons.location_on,
          color: Colors.red,
          size: 45,
        )));

    _mapController.move(position, 13);
  }

//--------------------Function to call location func and add marker   -----------------------//

  Future<void> addCurrentLocationMarker(
      bool removePreviousMarker, BuildContext context) async {
    try {
      LatLng location =
          await _locationService.getCurrentLocation(_mapController);
      addMarker(location, removePreviousMarker, context);
      if (location != null) {
        var placeName = await _locationService.getCityName(location, true);
        var placeAddress = await _locationService.getCityName(location, false);

        Provider.of<SelectedLocationsProvider>(context, listen: false)
            .updateLocations(
                placeName, placeAddress, location.latitude, location.longitude);
        addMarker(location, true, context);
      }
    } catch (e) {
      ShowAlert.showAlertDialog(
          context: context, title: 'System Message', message: e.toString());
    }
  }

//--------------------Function to get coordinates of search and add marker  -----------------------//

  Future<void> addSearchMarker(String value, BuildContext context) async {
    try {
      var location = await _locationService.geoCodeDestination(value);

      if (location != null) {
        var placeName = await _locationService.getCityName(location, true);
        var placeAddress = await _locationService.getCityName(location, false);

        Provider.of<SelectedLocationsProvider>(context, listen: false)
            .updateLocations(
                placeName, placeAddress, location.latitude, location.longitude);
        addMarker(location, true, context);
      }
    } catch (e) {
      ShowAlert.showAlertDialog(
          context: context, title: 'System Message', message: e.toString());
    }
  }

  //------------------------------Function to handle when uset taps on the map--------------------//
  void handleMapTap(LatLng point, BuildContext context) async {
    addMarker(point, true, context);
    Provider.of<RouteProvider>(context, listen: false).clearRoutes();
    String placeName = await _locationService.getCityName(point, true);
    String placeAddress = await _locationService.getCityName(point, false);

    Provider.of<SelectedLocationsProvider>(context, listen: false)
        .updateLocations(
            placeName, placeAddress, point.latitude, point.longitude);
  }

  //-------------------------------Function to handle if user taps on directions button----------------//
  void handleDirectionsPress(BuildContext context) async {
    try {
      // Get the current location
      LatLng currentLocation =
          await _locationService.getCurrentLocation(mapController);
      addMarker(currentLocation, false, context);

      // Get the selected destination location from the provider
      final selectedLocationsProvider =
          Provider.of<SelectedLocationsProvider>(context, listen: false);

      if (selectedLocationsProvider.lat == null ||
          selectedLocationsProvider.lon == null) {
        print("Error: Destination location is null.");
        return;
      }

      final double destinationLat = selectedLocationsProvider.lat!;
      final double destinationLng = selectedLocationsProvider.lon!;

      // Fetch route data for all vehicle types
      final allRouteData = await _locationService.fetchAllRoutes(
        destinationLat,
        destinationLng,
        currentLocation.latitude,
        currentLocation.longitude,
      );

      if (allRouteData.isEmpty) {
        ShowAlert.showAlertDialog(
            context: context,
            title: 'System Message',
            message: 'No routes found.');
        print("Error: No routes found.");

        return;
      }

      // Get route provider
      final routeProvider = Provider.of<RouteProvider>(context, listen: false);

      // Update routes safely
      routeProvider.updateCarRoute(
        allRouteData['driving-car']?['route'] ?? [],
        allRouteData['driving-car']?['distance'] ?? 0.0,
        allRouteData['driving-car']?['duration'] ?? 0.0,
      );

      routeProvider.updateBikeRoute(
        allRouteData['cycling-regular']?['route'] ?? [],
        allRouteData['cycling-regular']?['distance'] ?? 0.0,
        allRouteData['cycling-regular']?['duration'] ?? 0.0,
      );

      routeProvider.updateWalkRoute(
        allRouteData['foot-walking']?['route'] ?? [],
        allRouteData['foot-walking']?['distance'] ?? 0.0,
        allRouteData['foot-walking']?['duration'] ?? 0.0,
      );
    } catch (e) {
      print("Error in handleDirectionsPress: $e");
    }
  }

  //-----------------------------Function so user can share location-----------------------

  void shareLocation(BuildContext context) async {
    LatLng currentLocation =
        await _locationService.getCurrentLocation(mapController);
    String message =
        "My current location is: https://www.google.com/maps?q=${currentLocation.latitude},${currentLocation.longitude}";

    final Uri whatsappUri =
        Uri.parse("https://wa.me/?text=${Uri.encodeComponent(message)}");
    final Uri smsUri = Uri.parse("sms:?body=${Uri.encodeComponent(message)}");

    // Show a dialog to let the user choose the app
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Share Location'),
        content: Text('Choose where you want to send the location:'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close the dialog
              if (await canLaunchUrl(whatsappUri)) {
                await launchUrl(whatsappUri);
              } else {
                throw 'Could not launch WhatsApp';
              }
            },
            child: Text('WhatsApp'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close the dialog
              if (await canLaunchUrl(smsUri)) {
                await launchUrl(smsUri);
              } else {
                throw 'Could not launch Messages';
              }
            },
            child: Text('SMS'),
          ),
        ],
      ),
    );
  }

  
}
