import 'dart:io';

import '../../domain/entities/attendance_record.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_remote_datasource.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  AttendanceRepositoryImpl(this._remote);
  final AttendanceRemoteDataSource _remote;

  @override
  Future<AttendanceRecord> save(AttendanceRecord record, {File? selfieFile}) =>
      _remote.save(record, selfieFile: selfieFile);

  @override
  Future<List<AttendanceRecord>> todayRecords(String userId) =>
      _remote.todayRecords(userId);

  @override
  Stream<List<AttendanceRecord>> historyStream({
    required String userId,
    int limit = 30,
  }) =>
      _remote.historyStream(userId: userId, limit: limit);
}
