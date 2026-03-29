import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'storage_service.dart';

class LocationService {
  /// Kiểm tra quyền vị trí
  static Future<LocationPermission> checkLocationPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Xin quyền vị trí "Always"
  static Future<LocationPermission> requestLocationPermissionAlways() async {
    final permission = await Geolocator.requestPermission();
    return permission;
  }

  /// Lấy vị trí hiện tại
  static Future<Position?> getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      return position;
    } catch (e) {
      // Location error handled silently
      return null;
    }
  }

  /// Tính khoảng cách giữa 2 điểm (mét)
  static double calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
  }

  /// Lấy địa chỉ từ tọa độ (reverse geocoding)
  static Future<String> getAddressFromCoordinates(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        return "${place.thoroughfare}, ${place.administrativeArea}";
      }
    } catch (e) {
      // Geocoding error handled silently
    }
    return "Unknown";
  }

  /// Lưu vị trí công ty
  static Future<bool> saveCompanyLocation(double lat, double lng) async {
    try {
      final address = await getAddressFromCoordinates(lat, lng);
      await StorageService().setCompanyLocation(lat, lng);
      await StorageService().setCompanyAddress(address);
      return true;
    } catch (e) {
      // Save location error handled
      return false;
    }
  }

  /// Kiểm tra xem người dùng có trong vùng công ty không
  static bool isInCompanyArea(
    double userLat,
    double userLng,
    double radiusMeters,
  ) {
    final storage = StorageService();
    final companyLat = storage.getCompanyLat();
    final companyLng = storage.getCompanyLng();

    if (companyLat == null || companyLng == null) return false;

    final distance = calculateDistance(userLat, userLng, companyLat, companyLng);
    return distance <= radiusMeters;
  }

  /// Bắt đầu tracking vị trí trong background
  static Future<void> startBackgroundLocationTracking() async {
    try {
      final positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 50, // Cập nhật mỗi 50m
          timeLimit: Duration(seconds: 10),
        ),
      );

      positionStream.listen((position) {
        // Xử lý cập nhật vị trí
        _handleLocationUpdate(position);
      });
    } catch (e) {
      // Location tracking error handled
    }
  }

  static void _handleLocationUpdate(Position position) {
    // Location update handled in background_location_service
  }
}
