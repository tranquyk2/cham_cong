import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/record.dart';

class StorageService {
  static const String _companyLatKey = 'company_lat';
  static const String _companyLngKey = 'company_lng';
  static const String _companyAddressKey = 'company_address';
  static const String _radiusInKey = 'radius_in';
  static const String _radiusOutKey = 'radius_out';
  static const String _workStartKey = 'work_start';
  static const String _workEndKey = 'work_end';
  static const String _skipWeekendKey = 'skip_weekend';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _trigger1SentDateKey = 'trigger1_sent_date';
  static const String _trigger2SentDateKey = 'trigger2_sent_date';
  static const String _trigger3SentDateKey = 'trigger3_sent_date';
  static const String _onboardingCompleteKey = 'onboarding_complete';

  static late SharedPreferences _prefs;

  /// Khởi tạo StorageService
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ======== Company Location ========
  Future<void> setCompanyLocation(double lat, double lng) async {
    await _prefs.setDouble(_companyLatKey, lat);
    await _prefs.setDouble(_companyLngKey, lng);
  }

  double? getCompanyLat() => _prefs.getDouble(_companyLatKey);
  double? getCompanyLng() => _prefs.getDouble(_companyLngKey);

  bool hasCompanyLocation() {
    return _prefs.containsKey(_companyLatKey) && _prefs.containsKey(_companyLngKey);
  }

  Future<void> setCompanyAddress(String address) async {
    await _prefs.setString(_companyAddressKey, address);
  }

  String? getCompanyAddress() => _prefs.getString(_companyAddressKey);

  // ======== Radius Settings ========
  Future<void> setRadiusIn(int meters) async {
    await _prefs.setInt(_radiusInKey, meters);
  }

  int getRadiusIn() => _prefs.getInt(_radiusInKey) ?? 100;

  Future<void> setRadiusOut(int meters) async {
    await _prefs.setInt(_radiusOutKey, meters);
  }

  int getRadiusOut() => _prefs.getInt(_radiusOutKey) ?? 200;

  // ======== Work Hours ========
  Future<void> setWorkStart(String time) async {
    await _prefs.setString(_workStartKey, time);
  }

  String getWorkStart() => _prefs.getString(_workStartKey) ?? "08:00";

  Future<void> setWorkEnd(String time) async {
    await _prefs.setString(_workEndKey, time);
  }

  String getWorkEnd() => _prefs.getString(_workEndKey) ?? "17:30";

  // ======== Options ========
  Future<void> setSkipWeekend(bool value) async {
    await _prefs.setBool(_skipWeekendKey, value);
  }

  bool getSkipWeekend() => _prefs.getBool(_skipWeekendKey) ?? true;

  Future<void> setNotificationsEnabled(bool value) async {
    await _prefs.setBool(_notificationsEnabledKey, value);
  }

  bool getNotificationsEnabled() => _prefs.getBool(_notificationsEnabledKey) ?? true;

  // ======== Trigger Dates (chống spam) ========
  Future<void> setTrigger1SentDate(String date) async {
    await _prefs.setString(_trigger1SentDateKey, date);
  }

  String? getTrigger1SentDate() => _prefs.getString(_trigger1SentDateKey);

  Future<void> setTrigger2SentDate(String date) async {
    await _prefs.setString(_trigger2SentDateKey, date);
  }

  String? getTrigger2SentDate() => _prefs.getString(_trigger2SentDateKey);

  Future<void> setTrigger3SentDate(String date) async {
    await _prefs.setString(_trigger3SentDateKey, date);
  }

  String? getTrigger3SentDate() => _prefs.getString(_trigger3SentDateKey);

  // ======== Onboarding ========
  Future<void> setOnboardingComplete(bool value) async {
    await _prefs.setBool(_onboardingCompleteKey, value);
  }

  bool isOnboardingComplete() => _prefs.getBool(_onboardingCompleteKey) ?? false;

  // ======== Record Data ========
  Future<void> saveRecord(Record record) async {
    final key = 'record_${record.date}';
    await _prefs.setString(key, jsonEncode(record.toJson()));
  }

  Record? getRecord(String date) {
    final key = 'record_$date';
    final jsonStr = _prefs.getString(key);
    if (jsonStr == null) return null;
    return Record.fromJson(jsonDecode(jsonStr));
  }

  /// Lấy record hôm nay
  Record? getTodayRecord() {
    final today = DateTime.now();
    final dateStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    return getRecord(dateStr);
  }

  /// Lấy 7 ngày gần nhất
  List<Record> getLast7Days() {
    final records = <Record>[];
    for (int i = 0; i < 7; i++) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      final record = getRecord(dateStr);
      if (record != null) {
        records.add(record);
      }
    }
    return records;
  }

  /// Cập nhật widget UserDefaults
  Future<void> updateWidgetData() async {
    final today = getTodayRecord();
    final status = today?.getStatus() ?? "none";
    final checkIn = today?.checkIn ?? "";
    final checkOut = today?.checkOut ?? "";
    final total = today?.getTotalHours() ?? "";
    final note = today?.note ?? "";

    // Lưu vào UserDefaults (sẽ được widget đọc)
    await _prefs.setString('widget_status', status);
    await _prefs.setString('widget_check_in', checkIn);
    await _prefs.setString('widget_check_out', checkOut);
    await _prefs.setString('widget_total', total);
    await _prefs.setString('widget_note', note);
    await _prefs.setString('widget_date', DateTime.now().toIso8601String());
  }
}
