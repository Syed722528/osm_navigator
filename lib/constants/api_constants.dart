class ApiConstants {
  // ----------------------API constants add yours either of MapBox OR Open Street------------------//
  // Nominatim Url
  static const String nominatimGetAddressUrl =
      'https://nominatim.openstreetmap.org/reverse?lat={lat}&lon={lon}&format=json&addressdetails=1';

  static const String nominatimGetPointsUrl =
      'https://nominatim.openstreetmap.org/search?q={address}&format=json&addressdetails=1';

  static const String osmKey =
      '5b3ce3597851110001cf624892bc6e84835343b5b2f72d909bb8ee51';

  static const osmBaseUrl =
      'https://api.openrouteservice.org/v2/directions/{vehicle}?api_key=$osmKey&start={startLng},{startLat}&end={endLng},{endLat}';

  static const String osmUrlFetchRouteCar =
      'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$osmKey&start={startLng},{startLat}&end={endLng},{endLat}';
  static const String osmUrlFetchRouteBike =
      'https://api.openrouteservice.org/v2/directions/cycling-regular?api_key=$osmKey&start={startLng},{startLat}&end={endLng},{endLat}';

  static const String osmUrlFetchRouteWalk =
      'https://api.openrouteservice.org/v2/directions/foot-walking?api_key=$osmKey&start={startLng},{startLat}&end={endLng},{endLat}';

// Map Box Urls
  static const mapBoxBaseUrl =
      'https://api.mapbox.com/styles/v1/syed729/cm5fa0zce00ql01saezosf66c/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1Ijoic3llZDcyOSIsImEiOiJjbTVmOXNqb3gzYmQyMmxzZ3llYmhrdm0xIn0.xmJRUPc0miZBttzL_Sj51w';
  static const mapBoxSatUrl =
      'https://api.mapbox.com/styles/v1/syed729/cm6r0h0g1009601sa0e5u8yqd/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1Ijoic3llZDcyOSIsImEiOiJjbTVmOXNqb3gzYmQyMmxzZ3llYmhrdm0xIn0.xmJRUPc0miZBttzL_Sj51w';
  static const mapBoxAccessToken =
      'pk.eyJ1Ijoic3llZDcyOSIsImEiOiJjbTVmOXNqb3gzYmQyMmxzZ3llYmhrdm0xIn0.xmJRUPc0miZBttzL_Sj51w';
  static const mapBoxTileData = 'mapbox.mapbox-terrain-v2';
  static const mapBoxGetPointsUrl =
      'https://api.mapbox.com/geocoding/v5/mapbox.places/{address}.json?access_token=$mapBoxAccessToken';
  static const mapBoxGetAddressUrl =
      'https://api.mapbox.com/geocoding/v5/mapbox.places/{lat},{lon}.json?access_token=$mapBoxAccessToken';
}
