import 'package:intl/intl.dart';

/// Whether this record is a clock-in or clock-out event.
enum AttendanceType { clockIn, clockOut }

/// Attendance status used for filtering in the History screen.
enum AttendanceStatus { hadir, telat, izin, alpha }

extension AttendanceStatusLabel on AttendanceStatus {
  String get label => switch (this) {
        AttendanceStatus.hadir => 'Hadir',
        AttendanceStatus.telat => 'Telat',
        AttendanceStatus.izin => 'Izin',
        AttendanceStatus.alpha => 'Alpha',
      };
}

/// Domain entity for one attendance event (clock-in **or** clock-out).
class AttendanceRecord {
  const AttendanceRecord({
    required this.id,
    required this.userId,
    required this.date,
    required this.type,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.distanceFromOffice,
    required this.isInArea,
    this.selfieUrl,
    this.status = AttendanceStatus.hadir,
  });

  final String id;
  final String userId;

  /// ISO date string "YYYY-MM-DD" — used as a Firestore query field.
  final String date;

  final AttendanceType type;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final double distanceFromOffice;
  final bool isInArea;
  final String? selfieUrl;
  final AttendanceStatus status;

  static final _dateFmt = DateFormat('yyyy-MM-dd');

  static String today() => _dateFmt.format(DateTime.now());

  /// Determines the status from clock-in time (shift start = 08:30).
  static AttendanceStatus computeStatus(DateTime clockIn) {
    final cutoff = DateTime(clockIn.year, clockIn.month, clockIn.day, 8, 30);
    return clockIn.isAfter(cutoff) ? AttendanceStatus.telat : AttendanceStatus.hadir;
  }
}
