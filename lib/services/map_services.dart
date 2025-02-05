import 'dart:convert';

import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'package:latlong2/latlong.dart';
import 'package:osm_navigator/utils/permission_handler.dart';

import '../constants/api_constants.dart';

class MapServices {
//------------------------------Function to get current Location in Geo Points-----------------------//

  Future<LatLng> getCurrentLocation(MapController mapController) async {
    try {
      bool requestPermission =
          await PermissionHandler.isLocationPermissionGranted();

      if (requestPermission) {
        Position position = await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(accuracy: LocationAccuracy.best),
        );
        return LatLng(position.latitude, position.longitude);
      } else {
        throw Exception('Location Services denied');
      }
    } catch (e) {
      throw Exception('Error getting location: $e');
    }
  }

//-----------------------------Function to get Location name from Geo Points-------------------------------//
  Future<String> getCityName(LatLng point, bool onlyCityName) async {
    final url = Uri.parse(ApiConstants.nominatimGetAddressUrl
        .replaceFirst('{lat}', '${point.latitude}')
        .replaceFirst('{lon}', '${point.longitude}'));

    try {
      final response = await http.get(
        url,
        headers: {'Accept-Language': 'en'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Extract address keys in priority order
        final List<String> priorityKeys = ['city', 'town', 'village'];
        dynamic address = data['address'];

        if (address != null) {
          if (onlyCityName) {
            for (var key in priorityKeys) {
              if (address.containsKey(key)) {
                return address[key];
              }
            }
          } else {
            return '${address['road'] ?? ''}, ${address['suburb'] ?? ''}, ${address['city'] ?? address['town'] ?? address['village'] ?? ''}, ${address['state'] ?? ''}, ${address['country'] ?? ''}'
                .replaceAll(RegExp(r',\s+,'), ',') // Remove extra commas
                .trim();
          }
        }
        return 'Unknown City'; // Fallback if no city/town/village found
      } else {
        throw Exception('Failed to fetch city name: ${response.statusCode}');
      }
    } catch (e) {
      return 'Unable to determine city';
    }
  }

  //----------------------------------- Function to get Geo Points form Address-----------------------------//

  Future<LatLng?> geoCodeDestination(String address) async {
    final url = Uri.parse(
        ApiConstants.nominatimGetPointsUrl.replaceFirst('{address}', address));

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);

          return LatLng(lat, lon);
        } else {
          throw Exception('No data found for given address');
        }
      } else {
        throw Exception(
            'Failed to get Location. Status code ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Unable to fetch data at this moment');
    }
  }

  //-----------------------------Fetch routes between two Geo Points----------------------------//

  Future<Map<String, dynamic>> fetchRoute(double startLat, double startLng,
      double endLat, double endLng, String vehicle) async {
    final url = Uri.parse(ApiConstants.osmUrlFetchRouteCar
        .replaceFirst('{startLng}', '$startLng')
        .replaceFirst('{startLat}', '$startLat')
        .replaceFirst('{endLng}', '$endLng')
        .replaceFirst('{endLat}', '$endLat'));

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final geometry = data['features'][0]['geometry']['coordinates'];
      final properties = data['features'][0]['properties'];

      return {
        'route': geometry
            .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
            .toList(),
        'distance': properties['segments'][0]['distance'],
        'duration': properties['segments'][0]['duration']
      };
    } else {
      throw Exception('Failed to load route');
    }
  }

  Future<Map<String, Map<String, dynamic>>> fetchAllRoutes(
      double startLat, double startLng, double endLat, double endLng) async {
    const vehicles = ['driving-car', 'cycling-regular', 'foot-walking'];
    final Map<String, Map<String, dynamic>> allRoutes = {};

    final futures = vehicles.map((vehicle) async {
      try {
        final url = Uri.parse(ApiConstants.osmBaseUrl
            .replaceFirst('{startLng}', '$startLng')
            .replaceFirst('{startLat}', '$startLat')
            .replaceFirst('{endLng}', '$endLng')
            .replaceFirst('{endLat}', '$endLat')
            .replaceFirst('{vehicle}', vehicle));

        final response = await http.get(url);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['features']?.isEmpty ?? true) return;

          final geometry = data['features'][0]['geometry']['coordinates'];
          final properties = data['features'][0]['properties'];

          allRoutes[vehicle] = {
            'route': geometry
                .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
                .toList(),
            'distance': (properties['segments']?[0]['distance'] ?? 0.0)/1000,
            'duration': (properties['segments']?[0]['duration'] ?? 0.0)/3600,
          };
        }
      } catch (e) {
        print('Failed to load route for $vehicle: $e');
      }
    });

    await Future.wait(futures);

    return allRoutes;
  }


}
