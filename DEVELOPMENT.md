# Development Guide - Chấm Công

This document provides guidance for developers working on extending and maintaining the Chấm Công app.

## Architecture Overview

The app follows a layered architecture:

```
Presentation Layer (Screens)
        ↓
Business Logic Layer (Services)
        ↓
Data Layer (Models + Storage)
```

### Layer Breakdown

**Presentation Layer** (`lib/screens/`)
- `tab_checkin.dart`: Check-in/out interface
- `tab_settings.dart`: Configuration and permissions UI
- Handles all user interaction and UI updates

**Business Logic Layer** (`lib/services/`)
- `storage_service.dart`: Data persistence via SharedPreferences
- `location_service.dart`: GPS, geofencing, coordinate calculations
- `notification_service.dart`: Local notifications and trigger logic

**Data Layer** (`lib/models/`)
- `record.dart`: Attendance record model
- Simple data structures with serialization/deserialization

## Key Design Decisions

### 1. No Automatic Check-in
The app **requires manual button presses** to record attendance. This is intentional to:
- Ensure accuracy and prevent accidental recordings
- Give users full control over their records
- Comply with privacy-first philosophy

### 2. Local-First Storage
All data is stored locally using `SharedPreferences`:
- No cloud dependency
- Works offline
- User privacy is maintained
- Sync happens through App Groups to widget only

### 3. Cupertino Widgets (iOS Only)
Uses Flutter's Cupertino package for native iOS look & feel:
- No Material Design components
- Authentic iOS experience
- iOS-only project (could be extended to Android later)

### 4. Background Location Tracking
The app monitors location in the background using:
- `geolocator` package for GPS
- `flutter_local_notifications` for alerts
- `workmanager` for scheduled tasks

## Adding New Features

### Adding a New Notification Trigger

1. **Define the trigger in `notification_service.dart`**:

```dart
Future<void> checkTrigger4(/* parameters */) async {
  final storage = StorageService();
  
  // Check if already sent today
  final today = DateFormat("yyyy-MM-dd").format(DateTime.now());
  if (storage.getTrigger4SentDate() == today) return;
  
  // Business logic...
  
  // Send notification
  await showNotification(
    title: "Chấm Công",
    body: "Your message here",
    id: 4,
  );
  
  await storage.setTrigger4SentDate(today);
}
```

2. **Call the trigger from location/time monitoring logic**
3. **Add corresponding storage methods** for the trigger date
4. **Test on real device** with background app

### Adding a New Setting

1. **Add getter/setter in `storage_service.dart`**:

```dart
Future<void> setNewSetting(String value) async {
  await _prefs.setString('new_setting', value);
}

String getNewSetting() => _prefs.getString('new_setting') ?? 'default';
```

2. **Add UI control in `tab_settings.dart`**:

```dart
_buildToggleTile(
  title: 'New Setting',
  value: _newSetting,
  onChanged: (value) {
    setState(() {
      _newSetting = value;
    });
    _storage.setNewSetting(value.toString());
  },
)
```

3. **Initialize in `_loadSettings()`**:

```dart
void _loadSettings() {
  setState(() {
    // ... existing code ...
    _newSetting = _storage.getNewSetting() == 'true';
  });
}
```

### Updating Widget Display

After any data change, update the widget:

```dart
// In tab_checkin.dart, after check-in/check-out:
_storage.saveRecord(_todayRecord!);
_storage.updateWidgetData();  // ← Call this
```

This syncs data to the iOS widget automatically.

## Testing

### Unit Tests

Create tests in `test/` folder:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:cham_cong/models/record.dart';

void main() {
  group('Record Model', () {
    test('getTotalHours calculates correctly', () {
      final record = Record(
        date: '2026-03-29',
        checkIn: '08:00',
        checkOut: '17:00',
      );
      expect(record.getTotalHours(), '9h 0m');
    });
  });
}
```

Run with:
```bash
flutter test
```

### Manual Testing

1. **Location Testing**: Use Xcode simulator to set GPS coordinates
2. **Notification Testing**: Use Xcode console to trigger notification handlers
3. **Widget Testing**: Run ChamCongWidget scheme separately
4. **Background Testing**: Lock device and wait for background tasks

## Performance Considerations

### Battery Usage
- Location updates filtered by `distanceFilter: 50m` to reduce GPS usage
- Notifications sent only once per day per trigger
- Background tasks use efficient polling intervals

### Storage Optimization
- Remove old records after 90 days:

```dart
void _cleanOldRecords() {
  final cutoff = DateTime.now().subtract(Duration(days: 90));
  for (int i = 0; i < 90; i++) {
    final date = DateTime.now().subtract(Duration(days: i));
    if (date.isBefore(cutoff)) {
      _prefs.remove('record_${DateFormat('yyyy-MM-dd').format(date)}');
    }
  }
}
```

### Memory Management
- Use `late` for lazy initialization
- Dispose streams and listeners properly
- Clear cached data on logout

## Debugging

### Enable Verbose Logging

```bash
flutter run -v
```

### Check Local Storage

```dart
// In Flutter code
final prefs = await SharedPreferences.getInstance();
print(prefs.getKeys()); // List all stored keys
```

### iOS Console

In Xcode, use **Debug** → **View Debugger** to inspect app state.

### Network Inspection

Install Charles Proxy or Wireshark to monitor location and notification requests.

## Common Issues & Solutions

### Issue: Location updates not working
**Solution:**
- Verify iOS permissions allow "Always" location access
- Use real device (simulator GPS is limited)
- Check `Info.plist` has required keys
- Verify App Group ID is set correctly

### Issue: Notifications not triggering
**Solution:**
- Ensure notification permission is granted
- Check notification is outside `trigger_X_sent_date` window
- Verify app is running or in background (iOS allows ~30 seconds)
- Check system notification settings aren't muted

### Issue: Widget not updating
**Solution:**
- Rebuild widget from Flutter app: `updateWidgetData()`
- Verify App Group ID matches in Swift and Flutter
- Remove and re-add widget to home screen
- Restart device if needed

## Release Checklist

Before releasing a new version:

- [ ] Run `flutter analyze` - no errors
- [ ] Run `flutter test` - all tests pass
- [ ] Test on physical iOS device
- [ ] Test widget on iOS 17+ device
- [ ] Update version in `pubspec.yaml`
- [ ] Update `ios/Runner/Info.plist` version
- [ ] Create release build: `flutter build ios --release`
- [ ] Submit to App Store via Xcode

## Resources

- [Flutter Documentation](https://docs.flutter.dev)
- [Cupertino Widgets](https://docs.flutter.dev/development/ui/widgets/cupertino)
- [WidgetKit Guide](https://developer.apple.com/documentation/widgetkit)
- [iOS Background Modes](https://developer.apple.com/documentation/bundleresources/information_property_list/uibackgroundmodes)
- [Geolocator Package](https://pub.dev/packages/geolocator)
- [SharedPreferences](https://pub.dev/packages/shared_preferences)

## Future Enhancements

Potential improvements for future versions:

1. **Cloud Sync** - Sync records to Firebase or custom backend
2. **Team Management** - Support multiple employees
3. **Reporting** - Generate attendance reports (PDF/Excel)
4. **Face ID** - Use biometric authentication for security
5. **Offline Queue** - Queue records when offline, sync later
6. **Custom Rules** - Allow managers to define attendance rules
7. **Late Penalties** - Calculate lateness and deductions
8. **API Integration** - Connect to existing HR systems

---

Happy coding! 🚀
