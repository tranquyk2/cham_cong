import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../models/record.dart';
import '../services/storage_service.dart';

class TabCheckInScreen extends StatefulWidget {
  const TabCheckInScreen({super.key});

  @override
  State<TabCheckInScreen> createState() => _TabCheckInScreenState();
}

class _TabCheckInScreenState extends State<TabCheckInScreen> {
  late StorageService _storage;
  Record? _todayRecord;

  @override
  void initState() {
    super.initState();
    _storage = StorageService();
    _loadTodayRecord();
  }

  void _loadTodayRecord() {
    setState(() {
      _todayRecord = _storage.getTodayRecord() ?? Record(date: _getTodayDate());
    });
  }

  String _getTodayDate() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE, d/M/y', 'vi_VN');
    return formatter.format(now);
  }

  void _checkIn() {
    final now = DateTime.now();
    final timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    setState(() {
      _todayRecord!.checkIn = timeStr;
    });

    _storage.saveRecord(_todayRecord!);
    _storage.updateWidgetData();
    
    // Hiện thông báo xác nhận
    _showConfirmationDialog('Chấm công vào', 'Bạn đã chấm công vào lúc $timeStr');
  }

  void _checkOut() {
    final now = DateTime.now();
    final timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    setState(() {
      _todayRecord!.checkOut = timeStr;
    });

    _storage.saveRecord(_todayRecord!);
    _storage.updateWidgetData();
    
    // Hiện thông báo xác nhận
    _showConfirmationDialog('Chấm công ra', 'Bạn đã chấm công ra lúc $timeStr');
  }

  void _showConfirmationDialog(String title, String message) {
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

  String _getStatusColor(String status) {
    if (status == 'working') return '🟢';
    if (status == 'done') return '🔵';
    return '⚫';
  }

  @override
  Widget build(BuildContext context) {
    final status = _todayRecord!.getStatus();

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Chấm Công'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Ngày hôm nay
            Center(
              child: Text(
                _getFormattedDate(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF666666),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Card trạng thái
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _getStatusBackgroundColor(status),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getStatusColor(status),
                    style: const TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getStatusText(status),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_todayRecord!.checkIn != null)
                    Text(
                      'Vào: ${_todayRecord!.checkIn}',
                      style: const TextStyle(fontSize: 16, color: Color(0xFF666666)),
                    ),
                  if (_todayRecord!.checkOut != null)
                    Text(
                      'Ra: ${_todayRecord!.checkOut}',
                      style: const TextStyle(fontSize: 16, color: Color(0xFF666666)),
                    ),
                  if (_todayRecord!.getTotalHours().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Tổng: ${_todayRecord!.getTotalHours()}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF007AFF),
                        ),
                      ),
                    ),
                  if (_todayRecord!.note.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _todayRecord!.note,
                        style: TextStyle(
                          fontSize: 14,
                          color: _getNoteColor(_todayRecord!.note),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Nút chấm công
            if (status == 'none')
              CupertinoButton.filled(
                onPressed: _checkIn,
                child: const Text('CHẤM VÀO'),
              ),
            if (status == 'working')
              CupertinoButton.filled(
                onPressed: _checkOut,
                child: const Text('CHẤM RA'),
              ),

            const SizedBox(height: 32),

            // Danh sách 7 ngày gần nhất
            const Text(
              '7 ngày gần nhất',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildLast7DaysList(),
          ],
        ),
      ),
    );
  }

  Widget _buildLast7DaysList() {
    final records = _storage.getLast7Days();

    if (records.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Chưa có dữ liệu',
            style: TextStyle(color: Color(0xFFCCCCCC)),
          ),
        ),
      );
    }

    return Column(
      children: records.map((record) {
        return _buildRecordRow(record);
      }).toList(),
    );
  }

  Widget _buildRecordRow(Record record) {
    final dateTime = DateTime.parse('${record.date} 00:00:00');
    final formatter = DateFormat('d/M', 'vi_VN');
    final dateStr = formatter.format(dateTime);

    final backgroundColor = _getRowBackgroundColor(record);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            dateStr,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(
              '${record.checkIn ?? '--'} | ${record.checkOut ?? '--'}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            record.getTotalHours().isNotEmpty ? record.getTotalHours() : '--',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Color _getStatusBackgroundColor(String status) {
    switch (status) {
      case 'working':
        return const Color(0xFFE8F5E9);
      case 'done':
        return const Color(0xFFE3F2FD);
      default:
        return const Color(0xFFF5F5F5);
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'working':
        return 'Đang làm việc';
      case 'done':
        return 'Đã ra về';
      default:
        return 'Chưa vào ca';
    }
  }

  Color _getRowBackgroundColor(Record record) {
    if (record.note == 'Quên chấm ra') return const Color(0xFFFFEBEE);
    if (record.note == 'Tăng ca') return const Color(0xFFFFF9C4);
    if (record.checkOut == null) return const Color(0xFFFFEBEE);
    return const Color(0xFFE8F5E9);
  }

  Color _getNoteColor(String note) {
    if (note == 'Quên chấm ra') return const Color(0xFFD32F2F);
    if (note == 'Tăng ca') return const Color(0xFFFFA000);
    return const Color(0xFF1976D2);
  }
}
