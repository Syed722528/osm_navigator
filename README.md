# Flutter MapBox Navigation App

A feature-rich Flutter application integrating MapBox and OpenStreetMap for location services and navigation.

## Features

- Live location tracking
- Location search functionality
- Tap-to-select location on map
- Reverse geocoding for address details
- Multi-mode navigation (Car, Bike, Walking)
- Save favorite locations
- State management using Provider

## Prerequisites

- Flutter SDK
- Android Studio / Xcode
- MapBox API key
- OpenStreetMap API key

## Installation

1. Clone the repository
```bash
git clone https://github.com/yourusername/flutter-mapbox-app.git
```

2. Navigate to project directory
```bash
cd flutter-mapbox-app
```

3. Install dependencies
```bash
flutter pub get
```

4. Add API keys:
- Create `lib/constants/api_constants.dart`
- Add your API keys:
```dart
class ApiConstants {
  static const String mapBoxApiKey = 'YOUR_MAPBOX_API_KEY';
  static const String openStreetApiKey = 'YOUR_OPENSTREET_API_KEY';
}
```

## Platform Specific Setup

### Android
1. Add MapBox token in `android/app/src/main/res/values/strings.xml`:
```xml
<string name="mapbox_access_token">YOUR_MAPBOX_API_KEY</string>
```

### iOS
1. Add MapBox token in `ios/Runner/Info.plist`:
```xml
<key>MGLMapboxAccessToken</key>
<string>YOUR_MAPBOX_API_KEY</string>
```

## Usage

Run the app:
```bash
flutter run
```

## Dependencies

- mapbox_gl
- provider
- geolocator
- http

## License

[MIT](LICENSE)

## Contact

Syed Hassan - [@ysyedHassan](https://www.linkedin.com/in/syed-hassan-abrar-11713a1b0/)
Project Link: [https://github.com/yourusername/flutter-mapbox-app](https://github.com/Syed722528/osm_navigator.git)