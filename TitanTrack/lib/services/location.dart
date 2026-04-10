import 'package:geolocator/geolocator.dart';

class LocationService {
  
  static Future<bool> checkPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission != LocationPermission.deniedForever;
  }

  static Stream<Position> getLiveTracking() {
    const LocationSettings settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Update every 5 meters moved
    );
    return Geolocator.getPositionStream(locationSettings: settings);
  }

  static double calculateDistance(double startLat, double startLng, double endLat, double endLng) {
    // Returns distance in meters
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }
}