import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/app_user_model.dart';
import '../../data/models/attendance_record_model.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/attendance_record.dart';
import 'auth_providers.dart';

// ---------------------------------------------------------------------------
// Employee list
// ---------------------------------------------------------------------------

final employeeListProvider = StreamProvider<List<AppUser>>((ref) {
  final fs = ref.watch(firestoreProvider);
  return fs
      .collection(AppConstants.usersCollection)
      .orderBy('name')
      .snapshots()
      .map((snap) => snap.docs.map(AppUserModel.fromFirestore).toList());
});

// ---------------------------------------------------------------------------
// Today's attendance — all employees (admin view)
// ---------------------------------------------------------------------------

final todayAllAttendanceProvider =
    StreamProvider<List<AttendanceRecord>>((ref) {
  final fs = ref.watch(firestoreProvider);
  final today = AttendanceRecord.today();
  return fs
      .collection(AppConstants.attendanceCollection)
      .where('date', isEqualTo: today)
      .orderBy('timestamp', descending: false)
      .snapshots()
      .map((snap) =>
          snap.docs.map(AttendanceRecordModel.fromFirestore).toList());
});

// ---------------------------------------------------------------------------
// Derived real-time stats (drives the dashboard cards)
// ---------------------------------------------------------------------------

class AdminStats {
  const AdminStats({
    required this.hadir,
    required this.telat,
    required this.alpha,
    required this.totalKaryawan,
  });
  final int hadir;
  final int telat;
  final int alpha;
  final int totalKaryawan;
}

final adminStatsProvider = Provider<AsyncValue<AdminStats>>((ref) {
  final attendance = ref.watch(todayAllAttendanceProvider);
  final employees = ref.watch(employeeListProvider);

  // If stream is retrying after an error (loading with no value), keep showing
  // the error rather than flashing the loading spinner in a cycle.
  if (attendance.isLoading && !attendance.hasValue) {
    final prev = ref.read(todayAllAttendanceProvider);
    if (prev.hasError) return AsyncError(prev.error!, prev.stackTrace!);
  }

  return attendance.when(
    skipLoadingOnRefresh: true,
    skipLoadingOnReload: true,
    loading: () => const AsyncLoading(),
    error: (e, st) => AsyncError(e, st),
    data: (records) {
      final clockIns =
          records.where((r) => r.type == AttendanceType.clockIn).toList();
      final hadir = clockIns
          .where((r) => r.status == AttendanceStatus.hadir)
          .length;
      final telat = clockIns
          .where((r) => r.status == AttendanceStatus.telat)
          .length;
      final total = employees.value?.length ?? 0;
      final alpha = (total - clockIns.length).clamp(0, total);
      return AsyncData(AdminStats(
        hadir: hadir,
        telat: telat,
        alpha: alpha,
        totalKaryawan: total,
      ));
    },
  );
});

// ---------------------------------------------------------------------------
// Attendance logs per employee + date range filter
// ---------------------------------------------------------------------------

class AttendanceFilter {
  const AttendanceFilter({
    this.userId,
    this.from,
    this.to,
  });
  final String? userId;
  final DateTime? from;
  final DateTime? to;
}

class AttendanceFilterNotifier extends Notifier<AttendanceFilter> {
  @override
  AttendanceFilter build() => const AttendanceFilter();

  void update(AttendanceFilter filter) => state = filter;
  void clear() => state = const AttendanceFilter();
}

final attendanceFilterProvider =
    NotifierProvider<AttendanceFilterNotifier, AttendanceFilter>(
  AttendanceFilterNotifier.new,
);

final filteredAttendanceProvider =
    StreamProvider<List<AttendanceRecord>>((ref) {
  final fs = ref.watch(firestoreProvider);
  final filter = ref.watch(attendanceFilterProvider);

  Query<Map<String, dynamic>> q =
      fs.collection(AppConstants.attendanceCollection);

  if (filter.userId != null) {
    q = q.where('userId', isEqualTo: filter.userId);
  }
  if (filter.from != null) {
    q = q.where('timestamp',
        isGreaterThanOrEqualTo: Timestamp.fromDate(filter.from!));
  }
  if (filter.to != null) {
    final end = DateTime(
        filter.to!.year, filter.to!.month, filter.to!.day, 23, 59, 59);
    q = q.where('timestamp',
        isLessThanOrEqualTo: Timestamp.fromDate(end));
  }

  return q
      .orderBy('timestamp', descending: true)
      .limit(200)
      .snapshots()
      .map((snap) =>
          snap.docs.map(AttendanceRecordModel.fromFirestore).toList());
});

// ---------------------------------------------------------------------------
// Weekly KPI data (last 7 days)
// ---------------------------------------------------------------------------

class DailyKpi {
  const DailyKpi({
    required this.date,
    required this.hadir,
    required this.telat,
    required this.alpha,
    required this.total,
  });
  final DateTime date;
  final int hadir;
  final int telat;
  final int alpha;
  final int total;
  double get rate => total == 0 ? 0 : (hadir + telat) / total;
}

final weeklyKpiProvider = FutureProvider<List<DailyKpi>>((ref) async {
  final fs = ref.watch(firestoreProvider);
  final totalEmployees =
      (await fs.collection(AppConstants.usersCollection).count().get())
          .count ?? 0;

  final now = DateTime.now();
  final days = List.generate(7, (i) {
    final d = now.subtract(Duration(days: 6 - i));
    return DateTime(d.year, d.month, d.day);
  });

  final results = <DailyKpi>[];
  for (final day in days) {
    final dateStr =
        '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    final snap = await fs
        .collection(AppConstants.attendanceCollection)
        .where('date', isEqualTo: dateStr)
        .where('type', isEqualTo: 'clockIn')
        .get();
    final records =
        snap.docs.map(AttendanceRecordModel.fromFirestore).toList();
    final hadir =
        records.where((r) => r.status == AttendanceStatus.hadir).length;
    final telat =
        records.where((r) => r.status == AttendanceStatus.telat).length;
    final alpha = (totalEmployees - records.length).clamp(0, totalEmployees);
    results.add(DailyKpi(
      date: day,
      hadir: hadir,
      telat: telat,
      alpha: alpha,
      total: totalEmployees,
    ));
  }
  return results;
});

// ---------------------------------------------------------------------------
// Password reset requests (employee → admin)
// ---------------------------------------------------------------------------

class PasswordResetRequest {
  const PasswordResetRequest({
    required this.userId,
    required this.userName,
    required this.email,
    required this.nik,
    required this.requestedAt,
    required this.status,
  });
  final String userId;
  final String userName;
  final String email;
  final String nik;
  final DateTime requestedAt;
  final String status;

  bool get isPending => status == 'pending';

  factory PasswordResetRequest.fromMap(String id, Map<String, dynamic> data) {
    return PasswordResetRequest(
      userId: id,
      userName: data['userName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      nik: data['nik'] as String? ?? '',
      requestedAt:
          (data['requestedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] as String? ?? 'pending',
    );
  }
}

final passwordResetRequestsProvider =
    StreamProvider<List<PasswordResetRequest>>((ref) {
  final fs = ref.watch(firestoreProvider);
  return fs
      .collection(AppConstants.passwordResetRequestsCollection)
      .where('status', isEqualTo: 'pending')
      .snapshots()
      .map((snap) {
        final list = snap.docs
            .map((d) => PasswordResetRequest.fromMap(d.id, d.data()))
            .toList();
        list.sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
        return list;
      });
});

// ---------------------------------------------------------------------------
// Hourly distribution (today's clock-ins grouped by hour)
// ---------------------------------------------------------------------------

final hourlyDistributionProvider =
    Provider<AsyncValue<Map<int, int>>>((ref) {
  return ref.watch(todayAllAttendanceProvider).whenData((records) {
    final clockIns =
        records.where((r) => r.type == AttendanceType.clockIn);
    final map = <int, int>{};
    for (final r in clockIns) {
      final h = r.timestamp.hour;
      map[h] = (map[h] ?? 0) + 1;
    }
    return map;
  });
});
