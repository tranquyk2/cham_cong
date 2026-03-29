# Chấm Công - iOS Attendance App

A Flutter-based attendance tracking app for iOS with location-based reminders and automatic notifications.

## Features

- ✅ **Manual Check-in/Check-out**: Users must manually press buttons to record attendance
- 📍 **Location-based Reminders**: Automatic notifications when arriving at or leaving the office
- 🔔 **Smart Notifications**: Remind users if they forget to check out or are working overtime
- 📱 **iOS Widget**: Home screen widget for quick access (iOS 17+)
- 💾 **Local Storage**: All data stored locally on device using SharedPreferences
- 🔒 **Privacy Focused**: No cloud storage, no tracking without user action
- 🎨 **Native iOS UI**: Uses Cupertino widgets for authentic iOS experience

## Prerequisites

- **macOS** (Required for building iOS apps)
- **Flutter SDK** (v3.11.4 or later)
- **Xcode** (14.0 or later)
- **CocoaPods** package manager
- iOS 15.0+ target device/simulator

## Installation & Setup

### 1. Clone and Install Dependencies

```bash
cd cham_cong
flutter pub get
```

### 2. Configure iOS Build

```bash
cd ios
pod install
cd ..
```

### 3. Set Bundle Identifier

Edit `ios/Runner.xcodeproj/project.pbxproj` or open in Xcode:
```
PRODUCT_BUNDLE_IDENTIFIER = com.yourname.chamcong
```

### 4. Enable Development Team (Required)

In Xcode:
1. Open `ios/Runner.xcodeproj`
2. Select "Runner" project → Signing & Capabilities
3. Select a Development Team

## Build & Run

### Development (Simulator)

```bash
flutter run -v
```

Or directly from iOS:
```bash
open ios/Runner.xcworkspace
# Then run from Xcode (Cmd + R)
```

### Release Build

```bash
flutter build ios --release
```

Then:
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select "Generic iOS Device" or your device
3. Product → Archive
4. Distribute App

## Permissions

The app requires the following permissions (requested on first use):

- **Location (Always)**: For location-based check-in/out reminders
- **Notifications**: For attendance reminders

**Important**: On iOS, the app must have `NSLocationAlwaysAndWhenInUseUsageDescription` in Info.plist to request "Always" location access.

## Project Structure

```
lib/
├── main.dart                  # App entry point with CupertinoApp
├── models/
│   └── record.dart           # Attendance record data model
├── screens/
│   ├── tab_checkin.dart      # Check-in/out tab UI
│   └── tab_settings.dart     # Settings and configuration
├── services/
│   ├── storage_service.dart  # Local data persistence
│   ├── location_service.dart # GPS and geofencing
│   └── notification_service.dart  # Local notifications

ios/
├── Runner/
│   ├── Info.plist           # iOS configuration & permissions
│   └── ...
└── ChamCongWidget/          # iOS Widget Extension (WidgetKit)
```

## Usage

### Check-in/Check-out

1. Open the app
2. Tap "CHẤM VÀO" (Check In) button
3. Later, tap "CHẤM RA" (Check Out) button
4. View attendance history at the bottom

### Settings

Configure in the Settings tab:

- **Location**: Set company location using GPS
- **Radius**: Adjust notification trigger radius (in/out)
- **Work Hours**: Set standard work start/end times
- **Options**: Toggle weekend skip, notification settings
- **Widget**: Instructions for adding home screen widget

## Notification Triggers

The app sends 3 types of notifications:

1. **Arriving at Office**: When user enters company radius without checking in
2. **Leaving Office**: When user leaves company radius without checking out
3. **End of Shift**: At configured end time if still checked in (overtime alert)

Notifications are only sent once per day per trigger type (spam prevention).

## Data Storage

All data is stored locally in `SharedPreferences`:

- Attendance records: `record_YYYY-MM-DD`
- Settings: company location, work hours, preferences
- Widget data: synced via App Group to home screen widget

## iOS Widget (Optional)

To add an iOS Widget to your home screen:

1. Long-press home screen → Edit
2. Tap + button (top-left)
3. Search "Chấm Công"
4. Select widget size (Small or Medium)
5. Tap "Add Widget"

The widget shows your current attendance status and is updated automatically.

## Building the iOS Widget Extension

The widget is built with Swift + WidgetKit and packaged in a separate extension:

```bash
# The ChamCongWidget extension is in ios/ChamCongWidget/
# It's automatically included in the iOS build
```

To modify:
1. Open `ios/Runner.xcworkspace`
2. Select "ChamCongWidget" target
3. Edit `ChamCongWidget.swift`

## Troubleshooting

### Build Errors

**"Provisioning profile" error**
- Ensure development team is selected in Xcode
- Run: `flutter clean && flutter pub get`

**"Pod install" fails**
- Update CocoaPods: `sudo gem install cocoapods`
- Remove lock files: `rm -rf ios/Pods ios/Podfile.lock`
- Retry: `cd ios && pod install`

### Location Not Working

- Enable Location in iOS Settings → Chấm Công → Location
- Ensure "Always" is selected for background tracking
- Simulator may not have accurate GPS - use real device to test

### Widget Not Showing

- iOS 16 and below: Widgets not supported (falls back to app)
- iOS 17+: Ensure Location permission is "Always Allow"
- Refresh widget: Remove and re-add from home screen

## Future Enhancements

- [ ] Cloud backup & sync
- [ ] Multi-user support for family/team
- [ ] Weekly report export (PDF/Excel)
- [ ] Face recognition for check-in
- [ ] Offline mode improvements
- [ ] Custom work schedules

## License

MIT License - See LICENSE file for details

## Support

For issues or feature requests, please create an issue on the project repository.

---

**Note**: This is an iOS-only app. Building requires macOS and Xcode. Web and Android versions can be added in the future by removing Cupertino-specific widgets.
