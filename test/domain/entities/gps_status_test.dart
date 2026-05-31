import 'package:flutter_test/flutter_test.dart';
import 'package:tugasgila/domain/entities/gps_status.dart';

void main() {
  // -------------------------------------------------------------------------
  // haversineDistance
  // -------------------------------------------------------------------------
  group('haversineDistance', () {
    test('returns 0 for same point', () {
      final d = haversineDistance(
        lat1: -6.2, lng1: 106.8,
        lat2: -6.2, lng2: 106.8,
      );
      expect(d, 0.0);
    });

    test('calculates known distance (Jakarta to Bandung ~120-150km)', () {
      // Jakarta: -6.2088, 106.8456
      // Bandung: -6.9175, 107.6191
      final d = haversineDistance(
        lat1: -6.2088, lng1: 106.8456,
        lat2: -6.9175, lng2: 107.6191,
      );
      // Should be approximately 120-150 km
      expect(d, greaterThan(100000)); // > 100 km
      expect(d, lessThan(200000));    // < 200 km
    });

    test('calculates short distance accurately (~100m)', () {
      // Two points roughly 100m apart
      // 0.001 degree latitude ≈ 111m
      final d = haversineDistance(
        lat1: -6.393348, lng1: 108.147894,
        lat2: -6.394348, lng2: 108.147894,
      );
      // ~111m for 0.001 degree lat
      expect(d, greaterThan(100));
      expect(d, lessThan(120));
    });

    test('is symmetric (A→B == B→A)', () {
      final ab = haversineDistance(
        lat1: -6.2, lng1: 106.8,
        lat2: -6.9, lng2: 107.6,
      );
      final ba = haversineDistance(
        lat1: -6.9, lng1: 107.6,
        lat2: -6.2, lng2: 106.8,
      );
      expect(ab, closeTo(ba, 0.001));
    });
  });

  // -------------------------------------------------------------------------
  // GpsStatus.isInArea
  // -------------------------------------------------------------------------
  group('GpsStatus.isInArea', () {
    test('InArea returns true', () {
      const status = InArea(distanceMeters: 100);
      expect(status.isInArea, isTrue);
    });

    test('OutsideArea returns false', () {
      const status = OutsideArea(distanceMeters: 600);
      expect(status.isInArea, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // GpsStatus.distanceLabel
  // -------------------------------------------------------------------------
  group('GpsStatus.distanceLabel', () {
    test('formats meters when < 1000', () {
      const status = InArea(distanceMeters: 234.7);
      expect(status.distanceLabel, '235 m');
    });

    test('formats km when >= 1000', () {
      const status = OutsideArea(distanceMeters: 1500.0);
      expect(status.distanceLabel, '1.50 km');
    });

    test('formats 0 meters', () {
      const status = InArea(distanceMeters: 0);
      expect(status.distanceLabel, '0 m');
    });

    test('formats exactly 1000 as km', () {
      const status = OutsideArea(distanceMeters: 1000.0);
      expect(status.distanceLabel, '1.00 km');
    });

    test('formats 999 as meters', () {
      const status = InArea(distanceMeters: 999.0);
      expect(status.distanceLabel, '999 m');
    });
  });
}
