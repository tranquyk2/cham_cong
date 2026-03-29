import 'package:intl/intl.dart';

class Record {
  String? checkIn;
  String? checkOut;
  String note;
  String date;

  Record({
    this.checkIn,
    this.checkOut,
    this.note = "",
    required this.date,
  });

  /// Tính tổng giờ làm
  String getTotalHours() {
    if (checkIn == null || checkOut == null) return "";

    try {
      final format = DateFormat("HH:mm");
      final inTime = format.parse(checkIn!);
      final outTime = format.parse(checkOut!);

      final difference = outTime.difference(inTime);
      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;

      return "${hours}h ${minutes}m";
    } catch (e) {
      return "";
    }
  }

  /// Chuyển sang JSON để lưu
  Map<String, dynamic> toJson() {
    return {
      'checkIn': checkIn,
      'checkOut': checkOut,
      'note': note,
      'date': date,
    };
  }

  /// Tạo từ JSON
  factory Record.fromJson(Map<String, dynamic> json) {
    return Record(
      checkIn: json['checkIn'],
      checkOut: json['checkOut'],
      note: json['note'] ?? "",
      date: json['date'] ?? "",
    );
  }

  /// Trạng thái: "none" (chưa chấm), "working" (đang làm), "done" (đã về)
  String getStatus() {
    if (checkIn == null) return "none";
    if (checkOut == null) return "working";
    return "done";
  }
}
