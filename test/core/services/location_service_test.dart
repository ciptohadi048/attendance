import 'package:flutter_test/flutter_test.dart';
import 'package:tugasgila/core/services/location_service.dart';

void main() {
  // -------------------------------------------------------------------------
  // LocationException.message
  // -------------------------------------------------------------------------
  group('LocationException.message', () {
    test('serviceDisabled returns GPS message', () {
      const e = LocationException(LocationError.serviceDisabled);
      expect(e.message, contains('GPS'));
      expect(e.message, contains('tidak aktif'));
    });

    test('permissionDenied returns permission message', () {
      const e = LocationException(LocationError.permissionDenied);
      expect(e.message, contains('Izin lokasi ditolak'));
    });

    test('permissionDeniedForever returns permanent block message', () {
      const e = LocationException(LocationError.permissionDeniedForever);
      expect(e.message, contains('diblokir permanen'));
    });
  });

  // -------------------------------------------------------------------------
  // LocationError enum
  // -------------------------------------------------------------------------
  group('LocationError enum', () {
    test('has 3 values', () {
      expect(LocationError.values.length, 3);
    });

    test('contains expected values', () {
      expect(LocationError.values, contains(LocationError.serviceDisabled));
      expect(LocationError.values, contains(LocationError.permissionDenied));
      expect(LocationError.values, contains(LocationError.permissionDeniedForever));
    });
  });
}
