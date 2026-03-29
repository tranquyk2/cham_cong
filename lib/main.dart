import 'package:flutter/cupertino.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'services/background_task_service.dart';
import 'services/background_location_service.dart';
import 'screens/onboarding_screen.dart';
import 'screens/tab_checkin.dart';
import 'screens/tab_settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo storage
  await StorageService.init();
  
  // Khởi tạo notification
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  // Khởi tạo background tasks
  await BackgroundTaskService.initialize();
  
  // Khởi tạo intl
  await initializeDateFormatting('vi_VN');
  
  runApp(const ChamCongApp());
}

class ChamCongApp extends StatefulWidget {
  const ChamCongApp({super.key});

  @override
  State<ChamCongApp> createState() => _ChamCongAppState();
}

class _ChamCongAppState extends State<ChamCongApp> with WidgetsBindingObserver {
  late StorageService _storage;

  @override
  void initState() {
    super.initState();
    _storage = StorageService();
    WidgetsBinding.instance.addObserver(this);
    _startBackgroundServices();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App vừa quay lại foreground
      _startBackgroundServices();
    } else if (state == AppLifecycleState.paused) {
      // App vừa đi vào background
      // Services sẽ tiếp tục chạy
    }
  }

  void _startBackgroundServices() {
    // Bắt đầu location tracking
    BackgroundLocationService.startLocationMonitoring();
    
    // Bắt đầu background tasks
    BackgroundTaskService.scheduleEndOfWorkDayCheck();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Chấm Công',
      theme: const CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: Color(0xFF007AFF),
      ),
      localizationsDelegates: const [
        DefaultCupertinoLocalizations.delegate,
      ],
      home: _storage.isOnboardingComplete() 
        ? const MainTabScreen()
        : const OnboardingScreen(),
      routes: {
        '/home': (context) => const MainTabScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
      },
    );
  }
}

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.clock),
            label: 'Chấm Công',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            label: 'Cài đặt',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return CupertinoTabView(
              builder: (context) => const TabCheckInScreen(),
            );
          case 1:
            return CupertinoTabView(
              builder: (context) => const TabSettingsScreen(),
            );
          default:
            return Container();
        }
      },
    );
  }
}
