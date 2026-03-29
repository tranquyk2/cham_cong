import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'location_service.dart';
import 'notification_service.dart';

class BackgroundLocationService {
  static StreamSubscription<Position>? _positionStreamSubscription;

  /// Bắt đầu monitoring vị trí
  static Future<void> startLocationMonitoring() async {
    try {
      // Kiểm tra quyền
      final permission = await LocationService.checkLocationPermission();
      if (permission != LocationPermission.always && 
          permission != LocationPermission.whileInUse) {
        return;
      }

      // Lấy stream vị trí
      final positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 50, // Cập nhật khi di chuyển 50m
          timeLimit: Duration(seconds: 10),
        ),
      );

      // Lắng nghe cập nhật vị trí
      _positionStreamSubscription = positionStream.listen((Position position) async {
        await _handleLocationUpdate(position);
      });
    } catch (e) {
      // Location monitoring error
    }
  }

  /// Xử lý khi vị trí cập nhật
  static Future<void> _handleLocationUpdate(Position position) async {
    try {
      final notificationService = NotificationService();
      final userLat = position.latitude;
      final userLng = position.longitude;

      // Trigger 1: Đến gần công ty
      await notificationService.checkTrigger1(userLat, userLng);

      // Trigger 3: Ra khỏi công ty
      await notificationService.checkTrigger3(userLat, userLng);
    } catch (e) {
      // Handle location update error
    }
  }

  /// Dừng monitoring vị trí
  static Future<void> stopLocationMonitoring() async {
    try {
      await _positionStreamSubscription?.cancel();
      _positionStreamSubscription = null;
    } catch (e) {
      // Handle stop error
    }
  }

  /// Một lần kiểm tra vị trí hiện tại
  static Future<void> checkCurrentLocation() async {
    try {
      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        await _handleLocationUpdate(position);
      }
    } catch (e) {
      // Handle check location error
    }
  }
}

