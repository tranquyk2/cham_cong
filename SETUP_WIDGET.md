# How to Set Up iOS Widget Extension in Xcode

Since Widget Extensions need to be created via Xcode, follow these steps to properly integrate the widget:

## Step 1: Open Xcode Project

```bash
open ios/Runner.xcworkspace
```

## Step 2: Create Widget Extension Target

1. In Xcode, go to **File** → **New** → **Target**
2. Search for "Widget" and select **Widget Extension**
3. Configure as follows:
   - **Product Name**: `ChamCongWidget`
   - **Team**: Select your team
   - **Language**: Swift
   - **Include Configuration Intent**: Uncheck
   - **Include Live Activity**: Uncheck

4. Click **Finish**

## Step 3: Set App Groups

### Main App (Runner target):

1. Select **Runner** → **Signing & Capabilities**
2. Click **+ Capability**
3. Add **App Groups**
4. Add group: `group.com.yourname.chamcong`

### Widget Extension (ChamCongWidget target):

1. Select **ChamCongWidget** → **Signing & Capabilities**
2. Click **+ Capability**
3. Add **App Groups**
4. Add same group: `group.com.yourname.chamcong`

## Step 4: Replace Widget Code

1. In the ChamCongWidget target folder, open `ChamCongWidget.swift`
2. Replace the entire content with the code from `ios/ChamCongWidget/ChamCongWidget.swift`
3. Update `group.com.yourname.chamcong` with your actual bundle ID in both places

## Step 5: Update Main App Code

In `lib/services/storage_service.dart`, update widget data calls:

```dart
// In updateWidgetData() method
Future<void> updateWidgetData() async {
  // ... existing code ...
  
  // This will be read by the widget via App Group
  await _prefs.setString('widget_status', status);
  await _prefs.setString('widget_check_in', checkIn);
  await _prefs.setString('widget_check_out', checkOut);
  await _prefs.setString('widget_total', total);
  await _prefs.setString('widget_note', note);
}
```

## Step 6: Reload Widget in Flutter Code

After check-in/check-out, update the widget:

```dart
import 'package:home_widget/home_widget.dart';

// After saving record...
await _storage.updateWidgetData();

// For iOS 17+, also reload the widget
if (Platform.isIOS) {
  try {
    await HomeWidget.setAppGroupId('group.com.yourname.chamcong');
    // Widget will refresh on next timeline update
  } catch (e) {
    print('Error updating widget: $e');
  }
}
```

## Step 7: Build and Test

```bash
flutter clean
flutter pub get
flutter run
```

Or build from Xcode:
1. Select **ChamCongWidget** scheme
2. Select target device
3. Run (Cmd + R)

## Testing the Widget

1. Long-press home screen → **Edit**
2. Tap **+** button
3. Search "Chấm Công"
4. Select widget size and tap "Add Widget"

## Troubleshooting

### Widget not showing in Widget Library
- Build ChamCongWidget scheme separately
- Restart Xcode
- Make sure bundle ID is set correctly
- Verify App Groups are added to both targets

### Data not syncing with app
- Verify both targets use the same App Group ID
- Check UserDefaults reading code in Swift
- Ensure Flutter code is calling `updateWidgetData()`

### Widget crashes at runtime
- Check console logs in Xcode (Cmd + Shift + Y)
- Verify `group.com.yourname.chamcong` bundle ID is correct
- Make sure widget can read from UserDefaults

## iOS 17+ Interactive Widget

For iOS 17+, you can add interactive buttons. Modify your `ChamCongWidget.swift`:

```swift
@main
struct ChamCongWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ChamCongWidgetProvider()) { entry in
            ChamCongWidgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemSmall, .systemMedium])
        // Add for iOS 17+:
        .deferredSceneValue(\.dynamicIsland, scope: .widget) { _ in
            // Widget will appear on Dynamic Island
        }
    }
}
```

For AppIntent-based interactivity (requires iOS 17+), create:

```swift
import AppIntents

struct CheckInIntent: AppIntent {
    static var title: LocalizedStringResource = "Check In"
    
    func perform() async throws -> some IntentResult {
        // Call app via URL scheme to trigger check-in
        if let url = URL(string: "chamcong://checkin") {
            await UIApplication.shared.open(url)
        }
        return .result()
    }
}
```

## References

- [Apple Widget Documentation](https://developer.apple.com/documentation/widgetkit)
- [App Groups](https://developer.apple.com/documentation/security/configuring_app_groups)
- [UserDefaults](https://developer.apple.com/documentation/foundation/userdefaults)

---

**Note**: The widget extension must be built in Xcode and cannot be created purely from Flutter's command line.
