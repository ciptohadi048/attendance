import 'package:flutter_test/flutter_test.dart';
import 'package:tugasgila/domain/entities/attendance_record.dart';

void main() {
  // -------------------------------------------------------------------------
  // AttendanceRecord.computeStatus
  // -------------------------------------------------------------------------
  group('AttendanceRecord.computeStatus', () {
    test('returns hadir when clock-in at exactly 08:30', () {
      final time = DateTime(2026, 5, 30, 8, 30, 0);
      expect(AttendanceRecord.computeStatus(time), AttendanceStatus.hadir);
    });

    test('returns hadir when clock-in before 08:30', () {
      final time = DateTime(2026, 5, 30, 7, 45, 0);
      expect(AttendanceRecord.computeStatus(time), AttendanceStatus.hadir);
    });

    test('returns telat when clock-in after 08:30', () {
      final time = DateTime(2026, 5, 30, 8, 31, 0);
      expect(AttendanceRecord.computeStatus(time), AttendanceStatus.telat);
    });

    test('returns telat when clock-in at 09:00', () {
      final time = DateTime(2026, 5, 30, 9, 0, 0);
      expect(AttendanceRecord.computeStatus(time), AttendanceStatus.telat);
    });

    test('returns hadir for early morning (06:00)', () {
      final time = DateTime(2026, 5, 30, 6, 0, 0);
      expect(AttendanceRecord.computeStatus(time), AttendanceStatus.hadir);
    });

    test('returns telat for afternoon clock-in', () {
      final time = DateTime(2026, 5, 30, 14, 0, 0);
      expect(AttendanceRecord.computeStatus(time), AttendanceStatus.telat);
    });
  });

  // -------------------------------------------------------------------------
  // AttendanceRecord.today
  // -------------------------------------------------------------------------
  group('AttendanceRecord.today', () {
    test('returns date in yyyy-MM-dd format', () {
      final result = AttendanceRecord.today();
      expect(result, matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
    });
  });

  // -------------------------------------------------------------------------
  // AttendanceStatusLabel extension
  // -------------------------------------------------------------------------
  group('AttendanceStatusLabel', () {
    test('hadir label is "Hadir"', () {
      expect(AttendanceStatus.hadir.label, 'Hadir');
    });

    test('telat label is "Telat"', () {
      expect(AttendanceStatus.telat.label, 'Telat');
    });

    test('izin label is "Izin"', () {
      expect(AttendanceStatus.izin.label, 'Izin');
    });

    test('alpha label is "Alpha"', () {
      expect(AttendanceStatus.alpha.label, 'Alpha');
    });
  });
}
