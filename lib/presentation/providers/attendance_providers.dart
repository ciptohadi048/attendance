import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/services/notification_service.dart';
import '../../data/datasources/attendance_remote_datasource.dart';
import '../../data/repositories/attendance_repository_impl.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/repositories/attendance_repository.dart';
import 'auth_providers.dart';
import 'location_providers.dart';

// ---------------------------------------------------------------------------
// Infrastructure wiring
// ---------------------------------------------------------------------------

final attendanceRemoteDataSourceProvider =
    Provider<AttendanceRemoteDataSource>((ref) {
  return AttendanceRemoteDataSource(
    firestore: ref.watch(firestoreProvider),
    storage: ref.watch(firebaseStorageProvider),
  );
});

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepositoryImpl(
    ref.watch(attendanceRemoteDataSourceProvider),
  );
});

// ---------------------------------------------------------------------------
// Today's attendance state — drives the dashboard clock-in/out button.
// ---------------------------------------------------------------------------

/// Loads today's clock-in and clock-out records once per session.
final todayAttendanceProvider =
    FutureProvider.autoDispose<List<AttendanceRecord>>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return [];
  return ref.watch(attendanceRepositoryProvider).todayRecords(user.uid);
});

// ---------------------------------------------------------------------------
// History stream — drives the Attendance History screen.
// ---------------------------------------------------------------------------

final attendanceHistoryProvider = StreamProvider.autoDispose
    .family<List<AttendanceRecord>, String>((ref, userId) {
  return ref.watch(attendanceRepositoryProvider).historyStream(
        userId: userId,
        limit: 60,
      );
});

// ---------------------------------------------------------------------------
// Attendance action controller — handles the save + upload.
// ---------------------------------------------------------------------------

class AttendanceController extends Notifier<AsyncValue<AttendanceRecord?>> {
  @override
  AsyncValue<AttendanceRecord?> build() => const AsyncData(null);

  AttendanceRepository get _repo => ref.read(attendanceRepositoryProvider);

  Future<AttendanceRecord?> clockIn({
    required String userId,
    required double latitude,
    required double longitude,
    required double distanceMeters,
    required bool isInArea,
    File? selfieFile,
  }) async {
    state = const AsyncLoading();
    final now = DateTime.now();
    final record = AttendanceRecord(
      id: '',
      userId: userId,
      date: AttendanceRecord.today(),
      type: AttendanceType.clockIn,
      timestamp: now,
      latitude: latitude,
      longitude: longitude,
      distanceFromOffice: distanceMeters,
      isInArea: isInArea,
      status: AttendanceRecord.computeStatus(now),
    );

    final result = await AsyncValue.guard(
      () => _repo.save(record, selfieFile: selfieFile),
    );
    state = result;

    // Trigger notification based on result.
    if (result.hasValue && result.value != null) {
      final timeStr = DateFormat('HH:mm').format(now);
      await NotificationService.instance.showClockInSuccess(time: timeStr);
    } else if (result.hasError) {
      await NotificationService.instance.showAttendanceFailure(
        reason: 'Gagal menyimpan absen masuk. Silakan coba lagi.',
      );
    }

    // Invalidate today's cache so the dashboard reflects the new record.
    ref.invalidate(todayAttendanceProvider);
    return result.value;
  }

  Future<AttendanceRecord?> clockOut({
    required String userId,
    required double latitude,
    required double longitude,
    required double distanceMeters,
    required bool isInArea,
    File? selfieFile,
  }) async {
    state = const AsyncLoading();
    final now = DateTime.now();
    final record = AttendanceRecord(
      id: '',
      userId: userId,
      date: AttendanceRecord.today(),
      type: AttendanceType.clockOut,
      timestamp: now,
      latitude: latitude,
      longitude: longitude,
      distanceFromOffice: distanceMeters,
      isInArea: isInArea,
      status: AttendanceStatus.hadir,
    );

    final result = await AsyncValue.guard(
      () => _repo.save(record, selfieFile: selfieFile),
    );
    state = result;

    // Trigger notification based on result.
    if (result.hasValue && result.value != null) {
      final timeStr = DateFormat('HH:mm').format(now);
      await NotificationService.instance.showClockOutSuccess(time: timeStr);
    } else if (result.hasError) {
      await NotificationService.instance.showAttendanceFailure(
        reason: 'Gagal menyimpan absen pulang. Silakan coba lagi.',
      );
    }

    ref.invalidate(todayAttendanceProvider);
    return result.value;
  }
}

final attendanceControllerProvider =
    NotifierProvider<AttendanceController, AsyncValue<AttendanceRecord?>>(
  AttendanceController.new,
);
