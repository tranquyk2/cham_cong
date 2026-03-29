import 'package:workmanager/workmanager.dart';
import 'notification_service.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      switch (task) {
        case 'checkEndOfWorkDay':
          await _checkEndOfWorkDay();
          return true;
      }
    } catch (e) {
      // Background task error handled
    }
    return false;
  });
}

Future<void> _checkEndOfWorkDay() async {
  try {
    final notificationService = NotificationService();
    await notificationService.checkTrigger2();
  } catch (e) {
    // Check end of work day error handled
  }
}

class BackgroundTaskService {
  /// Khởi tạo background tasks
  static Future<void> initialize() async {
    try {
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: false,
      );
    } catch (e) {
      // Workmanager init error handled
    }
  }

  /// Lên lịch kiểm tra giờ tan làm
  static Future<void> scheduleEndOfWorkDayCheck() async {
    try {
      // Chạy mỗi 30 phút
      await Workmanager().registerPeriodicTask(
        'checkEndOfWorkDay',
        'checkEndOfWorkDay',
        frequency: const Duration(minutes: 30),
        initialDelay: const Duration(minutes: 5),
      );
    } catch (e) {
      // Schedule task error handled
    }
  }

  /// Hủy tất cả background tasks
  static Future<void> cancelAllTasks() async {
    try {
      await Workmanager().cancelAll();
    } catch (e) {
      // Cancel all tasks error handled
    }
  }

  /// Hủy task cụ thể
  static Future<void> cancelTask(String taskName) async {
    try {
      await Workmanager().cancelByTag(taskName);
    } catch (e) {
      // Cancel task error handled
    }
  }
}
