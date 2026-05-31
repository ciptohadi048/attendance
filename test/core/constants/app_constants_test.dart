import 'package:flutter_test/flutter_test.dart';
import 'package:tugasgila/core/constants/app_constants.dart';

void main() {
  // -------------------------------------------------------------------------
  // AppConstants.selfieStoragePath
  // -------------------------------------------------------------------------
  group('AppConstants.selfieStoragePath', () {
    test('generates correct path', () {
      final path = AppConstants.selfieStoragePath('user123', '2026-05-30');
      expect(path, 'attendance/user123/2026-05-30.jpg');
    });

    test('handles special characters in userId', () {
      final path = AppConstants.selfieStoragePath('abc-def_123', '2026-01-01');
      expect(path, 'attendance/abc-def_123/2026-01-01.jpg');
    });
  });

  // -------------------------------------------------------------------------
  // AppConstants values sanity checks
  // -------------------------------------------------------------------------
  group('AppConstants values', () {
    test('office coordinates are valid lat/lng', () {
      expect(AppConstants.officeLatitude, inInclusiveRange(-90, 90));
      expect(AppConstants.officeLongitude, inInclusiveRange(-180, 180));
    });

    test('allowed radius is positive', () {
      expect(AppConstants.allowedRadiusMeters, greaterThan(0));
    });

    test('allowed radius is 500m', () {
      expect(AppConstants.allowedRadiusMeters, 500);
    });
  });
}
