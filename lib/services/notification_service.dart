import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'storage_service.dart';
import 'location_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  /// Khởi tạo
  Future<void> initialize() async {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const iOSSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(iOS: iOSSettings);
    await _flutterLocalNotificationsPlugin.initialize(settings);
  }

  /// Xin quyền thông báo
  Future<bool> requestNotificationPermission() async {
    final result = await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    return result ?? false;
  }

  /// Gửi thông báo
  Future<void> showNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {
    const iOSDetails = DarwinNotificationDetails();

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      NotificationDetails(iOS: iOSDetails),
    );
  }

  /// TRIGGER 1: Đến gần công ty
  Future<void> checkTrigger1(double userLat, double userLng) async {
    final storage = StorageService();

    // Kiểm tra đã gửi hôm nay chưa
    final today = DateFormat("yyyy-MM-dd").format(DateTime.now());
    final lastSent = storage.getTrigger1SentDate();
    if (lastSent == today) return;

    // Kiểm tra đã chấm vào chưa
    final record = storage.getTodayRecord();
    if (record != null && record.checkIn != null) return;

    // Kiểm tra cuối tuần
    if (storage.getSkipWeekend()) {
      final now = DateTime.now();
      if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
        return;
      }
    }

    // Kiểm tra trong vùng công ty
    if (!LocationService.isInCompanyArea(
        userLat, userLng, storage.getRadiusIn().toDouble())) {
      return;
    }

    if (!storage.getNotificationsEnabled()) return;

    await showNotification(
      title: "Chấm Công",
      body: "Bạn đã đến công ty, nhớ chấm công vào nhé! 👋",
      id: 1,
    );

    await storage.setTrigger1SentDate(today);
  }

  /// TRIGGER 2: Đúng giờ tan làm + chưa chấm ra
  Future<void> checkTrigger2() async {
    final storage = StorageService();
    final record = storage.getTodayRecord();

    if (record == null || record.checkIn == null || record.checkOut != null) {
      return;
    }

    final today = DateFormat("yyyy-MM-dd").format(DateTime.now());
    final lastSent = storage.getTrigger2SentDate();
    if (lastSent == today) return;

    final now = DateTime.now();
    final workEnd = storage.getWorkEnd();

    // Kiểm tra xem đã đúng giờ tan làm chưa
    final workEndTime = DateFormat("HH:mm").parse(workEnd);
    if (now.isBefore(workEndTime)) return;

    if (!storage.getNotificationsEnabled()) return;

    // TODO: Kiểm tra vị trí để biết là tăng ca hay quên chấm ra
    // Tạm thời gửi thông báo tăng ca
    await showNotification(
      title: "Chấm Công",
      body: "Đã đến giờ tan làm. Bạn vẫn đang ở công ty — đang tăng ca? Nhớ chấm ra khi về nhé! ⏰",
      id: 2,
    );

    await storage.setTrigger2SentDate(today);
  }

  /// TRIGGER 3: Ra khỏi vùng công ty + chưa chấm ra
  Future<void> checkTrigger3(double userLat, double userLng) async {
    final storage = StorageService();
    final record = storage.getTodayRecord();

    if (record == null || record.checkIn == null || record.checkOut != null) {
      return;
    }

    final today = DateFormat("yyyy-MM-dd").format(DateTime.now());
    final lastSent = storage.getTrigger3SentDate();
    if (lastSent == today) return;

    // Kiểm tra đã ra ngoài vùng công ty chưa
    if (LocationService.isInCompanyArea(
        userLat, userLng, storage.getRadiusOut().toDouble())) {
      return;
    }

    if (!storage.getNotificationsEnabled()) return;

    await showNotification(
      title: "Chấm Công",
      body: "Bạn vừa rời công ty mà chưa chấm ra! Bấm để mở app chấm ngay. 🚨",
      id: 3,
    );

    await storage.setTrigger3SentDate(today);
  }
}
