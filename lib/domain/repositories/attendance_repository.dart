import 'dart:io';

import '../entities/attendance_record.dart';

abstract interface class AttendanceRepository {
  /// Save a new clock-in or clock-out record to Firestore.
  /// [selfieFile] is uploaded to Firebase Storage when provided.
  Future<AttendanceRecord> save(AttendanceRecord record, {File? selfieFile});

  /// Today's records for [userId] (0, 1, or 2 entries: clock-in + clock-out).
  Future<List<AttendanceRecord>> todayRecords(String userId);

  /// Paginated history for [userId], newest first.
  Stream<List<AttendanceRecord>> historyStream({
    required String userId,
    int limit = 30,
  });
}
