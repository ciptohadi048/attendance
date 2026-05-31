import 'package:flutter_test/flutter_test.dart';
import 'package:tugasgila/presentation/providers/admin_providers.dart';

void main() {
  // -------------------------------------------------------------------------
  // DailyKpi.rate
  // -------------------------------------------------------------------------
  group('DailyKpi.rate', () {
    test('calculates rate correctly', () {
      final kpi = DailyKpi(
        date: DateTime(2026, 5, 30),
        hadir: 8,
        telat: 2,
        alpha: 5,
        total: 15,
      );
      expect(kpi.rate, closeTo(0.6667, 0.001));
    });

    test('returns 0 when total is 0 (division by zero guard)', () {
      final kpi = DailyKpi(
        date: DateTime(2026, 5, 30),
        hadir: 0,
        telat: 0,
        alpha: 0,
        total: 0,
      );
      expect(kpi.rate, 0.0);
    });

    test('returns 1.0 when all present', () {
      final kpi = DailyKpi(
        date: DateTime(2026, 5, 30),
        hadir: 7,
        telat: 3,
        alpha: 0,
        total: 10,
      );
      expect(kpi.rate, 1.0);
    });

    test('returns 0.0 when nobody present', () {
      final kpi = DailyKpi(
        date: DateTime(2026, 5, 30),
        hadir: 0,
        telat: 0,
        alpha: 10,
        total: 10,
      );
      expect(kpi.rate, 0.0);
    });
  });

  // -------------------------------------------------------------------------
  // PasswordResetRequest
  // -------------------------------------------------------------------------
  group('PasswordResetRequest', () {
    test('isPending returns true for pending status', () {
      final req = PasswordResetRequest(
        userId: 'u1',
        userName: 'Budi',
        email: 'budi@test.com',
        nik: '12345678',
        requestedAt: DateTime(2026, 5, 30),
        status: 'pending',
      );
      expect(req.isPending, isTrue);
    });

    test('isPending returns false for approved status', () {
      final req = PasswordResetRequest(
        userId: 'u1',
        userName: 'Budi',
        email: 'budi@test.com',
        nik: '12345678',
        requestedAt: DateTime(2026, 5, 30),
        status: 'approved',
      );
      expect(req.isPending, isFalse);
    });

    test('isPending returns false for rejected status', () {
      final req = PasswordResetRequest(
        userId: 'u1',
        userName: 'Budi',
        email: 'budi@test.com',
        nik: '12345678',
        requestedAt: DateTime(2026, 5, 30),
        status: 'rejected',
      );
      expect(req.isPending, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // AdminStats
  // -------------------------------------------------------------------------
  group('AdminStats', () {
    test('stores values correctly', () {
      const stats = AdminStats(
        hadir: 10,
        telat: 3,
        alpha: 2,
        totalKaryawan: 15,
      );
      expect(stats.hadir, 10);
      expect(stats.telat, 3);
      expect(stats.alpha, 2);
      expect(stats.totalKaryawan, 15);
    });
  });

  // -------------------------------------------------------------------------
  // AttendanceFilter
  // -------------------------------------------------------------------------
  group('AttendanceFilter', () {
    test('default constructor has all null fields', () {
      const filter = AttendanceFilter();
      expect(filter.userId, isNull);
      expect(filter.from, isNull);
      expect(filter.to, isNull);
    });

    test('stores provided values', () {
      final filter = AttendanceFilter(
        userId: 'user1',
        from: DateTime(2026, 5, 1),
        to: DateTime(2026, 5, 30),
      );
      expect(filter.userId, 'user1');
      expect(filter.from, DateTime(2026, 5, 1));
      expect(filter.to, DateTime(2026, 5, 30));
    });
  });
}
