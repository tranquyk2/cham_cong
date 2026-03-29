import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:permission_handler/permission_handler.dart' as perm;
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStep = 0; // 0: intro, 1: notification, 2: location, 3: done
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: PageView(
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                children: [
                  _buildIntroPage(),
                  _buildNotificationPage(),
                  _buildLocationPage(),
                  _buildDonePage(),
                ],
              ),
            ),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '👋',
          style: TextStyle(fontSize: 80),
        ),
        const SizedBox(height: 24),
        const Text(
          'Chào Mừng bạn đến với',
          style: TextStyle(fontSize: 20, color: Color(0xFF666666)),
        ),
        const SizedBox(height: 8),
        const Text(
          'Chấm Công',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF007AFF),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Ứng dụng nhắc nhở chấm công tự động',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF999999),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'App sẽ giúp bạn:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _FeatureRow('✓ Nhắc nhở chấm vào khi đến công ty'),
              _FeatureRow('✓ Cảnh báo quên chấm ra'),
              _FeatureRow('✓ Thích nghi tích tăng ca'),
              _FeatureRow('✓ Lưu trữ dữ liệu trên điện thoại'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '🔔',
          style: TextStyle(fontSize: 80),
        ),
        const SizedBox(height: 24),
        const Text(
          'Bước 1: Bật Thông Báo',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9C4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'App cần gửi thông báo để nhắc bạn chấm công đúng giờ. Bạn sẽ được hỏi cho phép ở bước tiếp theo.',
              style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Quyền sẽ được cấp cho:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        const _FeatureRow('• Thông báo nhắc chấm công'),
        const _FeatureRow('• Cảnh báo quên chấm ra'),
        const _FeatureRow('• Nhắc nhở vào ca'),
      ],
    );
  }

  Widget _buildLocationPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '📍',
          style: TextStyle(fontSize: 80),
        ),
        const SizedBox(height: 24),
        const Text(
          'Bước 2: Cấp Quyền Vị Trí',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'App cần quyền vị trí "Luôn luôn" để tự động nhắc khi bạn đến hoặc rời công ty, ngay cả khi app đóng.',
              style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Quyền sẽ được dùng để:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        const _FeatureRow('• Phát hiện bạn đến công ty'),
        const _FeatureRow('• Phát hiện bạn rời công ty'),
        const _FeatureRow('• Gửi nhắc nhở tự động'),
      ],
    );
  }

  Widget _buildDonePage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '✅',
          style: TextStyle(fontSize: 80),
        ),
        const SizedBox(height: 24),
        const Text(
          'Hoàn Tất!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'App đã sẵn sàng để giúp bạn trong quá trình chấm công.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF666666),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '💡 Tip:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8),
                Text(
                  'Hãy vào Cài Đặt để thiết lập vị trí công ty và giờ làm việc của bạn.',
                  style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (_currentStep == 0)
            CupertinoButton.filled(
              onPressed: _nextStep,
              child: const Text('Bắt Đầu'),
            ),
          if (_currentStep == 1)
            CupertinoButton.filled(
              onPressed: _isLoading ? null : _requestNotificationPermission,
              child: _isLoading
                  ? const CupertinoActivityIndicator()
                  : const Text('Cấp Quyền Thông Báo'),
            ),
          if (_currentStep == 2)
            CupertinoButton.filled(
              onPressed: _isLoading ? null : _requestLocationPermission,
              child: _isLoading
                  ? const CupertinoActivityIndicator()
                  : const Text('Cấp Quyền Vị Trí'),
            ),
          if (_currentStep == 3)
            CupertinoButton.filled(
              onPressed: _completeOnboarding,
              child: const Text('Vào App'),
            ),
          const SizedBox(height: 12),
          if (_currentStep > 0 && _currentStep < 3)
            CupertinoButton(
              onPressed: _currentStep == 1 ? _nextStep : _previousStep,
              child: Text(_currentStep == 1 ? 'Tiếp Tục' : 'Quay Lại'),
            ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep += 1;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
    }
  }

  Future<void> _requestNotificationPermission() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // On web platform, skip permission request
      if (!Platform.isIOS && !Platform.isAndroid) {
        setState(() {
          _currentStep = 2;
          _isLoading = false;
        });
        return;
      }

      final status = await perm.Permission.notification.request();

      if (!mounted) return;

      if (status.isDenied) {
        _showErrorDialog(
          'Quyền Bị Từ Chối',
          'Vui lòng cấp quyền thông báo để app hoạt động tốt nhất.',
        );
      } else if (status.isPermanentlyDenied) {
        _showErrorDialog(
          'Quyền Bị Từ Chối Vĩnh Viễn',
          'Vui lòng vào Cài Đặt → Chấm Công → Thông Báo để bật.',
        );
        return;
      }

      // Khởi tạo notification service
      final notificationService = NotificationService();
      await notificationService.initialize();

      setState(() {
        _currentStep = 2;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Lỗi', 'Không thể cấp quyền: $e');
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _requestLocationPermission() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // On web platform, skip permission request
      if (!Platform.isIOS && !Platform.isAndroid) {
        setState(() {
          _currentStep = 3;
          _isLoading = false;
        });
        return;
      }

      final status = await perm.Permission.locationAlways.request();

      if (!mounted) return;

      if (status.isDenied) {
        // Thử xin "When In Use" trước
        final whenInUse = await perm.Permission.location.request();
        if (whenInUse.isDenied || whenInUse.isPermanentlyDenied) {
          _showErrorDialog(
            'Quyền Bị Từ Chối',
            'Vui lòng cấp quyền vị trí để app hoạt động.',
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
      } else if (status.isPermanentlyDenied) {
        _showErrorDialog(
          'Quyền Bị Từ Chối Vĩnh Viễn',
          'Vui lòng vào Cài Đặt → Chấm Công → Vị Trí → Chọn "Luôn Luôn".',
        );
        return;
      }

      setState(() {
        _currentStep = 3;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Lỗi', 'Không thể cấp quyền: $e');
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _completeOnboarding() {
    StorageService().setOnboardingComplete(true);

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  void _showErrorDialog(String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String text;

  const _FeatureRow(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
      ),
    );
  }
}
