import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import '../services/storage_service.dart';
import '../services/location_service.dart';

class TabSettingsScreen extends StatefulWidget {
  const TabSettingsScreen({super.key});

  @override
  State<TabSettingsScreen> createState() => _TabSettingsScreenState();
}

class _TabSettingsScreenState extends State<TabSettingsScreen> {
  late StorageService _storage;

  double? _companyLat;
  double? _companyLng;
  String? _companyAddress;

  late int _radiusIn;
  late int _radiusOut;
  late String _workStart;
  late String _workEnd;
  late bool _skipWeekend;
  late bool _notificationsEnabled;

  @override
  void initState() {
    super.initState();
    _storage = StorageService();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _companyLat = _storage.getCompanyLat();
      _companyLng = _storage.getCompanyLng();
      _companyAddress = _storage.getCompanyAddress();
      _radiusIn = _storage.getRadiusIn();
      _radiusOut = _storage.getRadiusOut();
      _workStart = _storage.getWorkStart();
      _workEnd = _storage.getWorkEnd();
      _skipWeekend = _storage.getSkipWeekend();
      _notificationsEnabled = _storage.getNotificationsEnabled();
    });
  }

  Future<void> _setCompanyLocation() async {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Lấy vị trí công ty'),
        content: const Text(
          'App sẽ dùng GPS để lấy vị trí hiện tại của bạn làm vị trí công ty. Vui lòng bật GPS và đứng tại công ty.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
              _getLocationAndSave();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _getLocationAndSave() async {
    try {
      // Kiểm tra quyền
      final permission = await LocationService.checkLocationPermission();

      if (permission == LocationPermission.denied) {
        // Xin quyền
        final newPermission = await LocationService.requestLocationPermissionAlways();
        if (newPermission == LocationPermission.denied ||
            newPermission == LocationPermission.deniedForever) {
          if (!mounted) return;
          _showErrorDialog('Quyền bị từ chối', 'Vui lòng cấp quyền vị trí trong Cài đặt');
          return;
        }
      }

      // Lấy vị trí hiện tại
      _showLoadingDialog('Đang lấy vị trí...');

      final position = await LocationService.getCurrentLocation();

      if (!mounted) return;
      Navigator.pop(context); // Đóng loading dialog

      if (position == null) {
        _showErrorDialog('Lỗi', 'Không thể lấy vị trí. Vui lòng thử lại.');
        return;
      }

      // Lưu vị trí
      await LocationService.saveCompanyLocation(position.latitude, position.longitude);

      _loadSettings();

      if (!mounted) return;
      _showSuccessDialog('Thành công', 'Đã lưu vị trí công ty');
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Đóng loading dialog
      _showErrorDialog('Lỗi', 'Không thể lấy vị trí: $e');
    }
  }

  void _showLoadingDialog(String message) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Đang xử lý...'),
        content: Text(message),
      ),
    );
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

  void _showSuccessDialog(String title, String message) {
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

  void _showTimePickerIn() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        color: CupertinoColors.white,
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: CupertinoButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Xong'),
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                use24hFormat: true,
                onDateTimeChanged: (value) {
                  setState(() {
                    _workStart =
                        "${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}";
                  });
                  _storage.setWorkStart(_workStart);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTimePickerOut() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        color: CupertinoColors.white,
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: CupertinoButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Xong'),
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                use24hFormat: true,
                onDateTimeChanged: (value) {
                  setState(() {
                    _workEnd =
                        "${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}";
                  });
                  _storage.setWorkEnd(_workEnd);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWidgetInstructions() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Cách thêm Widget'),
        content: const Text(
          '1. Giữ màn hình home cho đến khi các app rung\n'
          '2. Bấm dấu + góc trên bên trái\n'
          '3. Tìm kiếm "Chấm Công"\n'
          '4. Chọn widget và bấm "Thêm Widget"',
        ),
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Cài đặt'),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            // NHÓM 1 — VỊ TRÍ CÔNG TY
            _buildSectionHeader('VỊ TRỊ CÔNG TY'),
            _buildCupertinoListTile(
              title: 'Lấy vị trí hiện tại làm vị trí công ty',
              onTap: _setCompanyLocation,
            ),
            if (_companyLat != null && _companyLng != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lat: ${_companyLat?.toStringAsFixed(4)}, Lng: ${_companyLng?.toStringAsFixed(4)}',
                      style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
                    ),
                    if (_companyAddress != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _companyAddress!,
                          style:
                              const TextStyle(fontSize: 14, color: Color(0xFF007AFF)),
                        ),
                      ),
                  ],
                ),
              ),
            Container(height: 1, color: const Color(0xFFEEEEEE)),

            // NHÓM 2 — KHOẢNG CÁCH NHẮC NHỞ
            _buildSectionHeader('KHOẢNG CÁCH NHẮC NHỞ'),
            _buildInputTile(
              title: 'Bán kính nhắc chấm VÀO (mét)',
              value: _radiusIn.toString(),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  final val = int.tryParse(value) ?? 100;
                  _storage.setRadiusIn(val);
                  setState(() {
                    _radiusIn = val;
                  });
                }
              },
            ),
            _buildInputTile(
              title: 'Bán kính nhắc chấm RA (mét)',
              value: _radiusOut.toString(),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  final val = int.tryParse(value) ?? 200;
                  _storage.setRadiusOut(val);
                  setState(() {
                    _radiusOut = val;
                  });
                }
              },
            ),

            // NHÓM 3 — GIỜ LÀM VIỆC
            _buildSectionHeader('GIỜ LÀM VIỆC'),
            _buildCupertinoListTile(
              title: 'Giờ vào làm chuẩn',
              subtitle: _workStart,
              onTap: _showTimePickerIn,
            ),
            _buildCupertinoListTile(
              title: 'Giờ tan làm chuẩn',
              subtitle: _workEnd,
              onTap: _showTimePickerOut,
            ),

            // NHÓM 4 — TÙY CHỌN
            _buildSectionHeader('TÙY CHỌN'),
            _buildToggleTile(
              title: 'Bỏ qua cuối tuần',
              value: _skipWeekend,
              onChanged: (value) {
                setState(() {
                  _skipWeekend = value;
                });
                _storage.setSkipWeekend(value);
              },
            ),
            _buildToggleTile(
              title: 'Bật thông báo nhắc chấm công',
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
                _storage.setNotificationsEnabled(value);
              },
            ),

            // NHÓM 5 — HƯỚNG DẪN
            _buildSectionHeader('HƯỚNG DẪN'),
            _buildCupertinoListTile(
              title: 'Cách thêm Widget lên màn hình home',
              onTap: _showWidgetInstructions,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF999999),
        ),
      ),
    );
  }

  Widget _buildCupertinoListTile({
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      onPressed: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: CupertinoColors.black,
            ),
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF999999),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputTile({
    required String title,
    required String value,
    required Function(String) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          SizedBox(
            width: 100,
            child: CupertinoTextField(
              controller: TextEditingController(text: value),
              onChanged: onChanged,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              suffix: const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Text('m'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTile({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
