import 'package:geolocator/geolocator.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/gps_status.dart';

/// Why a location read could not be completed — surfaced to the UI so it can
/// show an actionable message (and an "open settings" button) instead of an
/// infinite spinner.
enum LocationError { serviceDisabled, permissionDenied, permissionDeniedForever }

/// Thrown by [LocationService] when a position cannot be obtained.
class LocationException implements Exception {
  const LocationException(this.reason);
  final LocationError reason;

  String get message => switch (reason) {
        LocationError.serviceDisabled =>
          'Layanan lokasi (GPS) tidak aktif. Aktifkan GPS di pengaturan perangkat.',
        LocationError.permissionDenied =>
          'Izin lokasi ditolak. Berikan izin lokasi untuk melanjutkan absensi.',
        LocationError.permissionDeniedForever =>
          'Izin lokasi diblokir permanen. Buka pengaturan aplikasi untuk mengizinkannya.',
      };
}

/// Wraps [Geolocator] with permission handling and produces [GpsStatus] values.
///
/// IMPORTANT: [positionStream] does NOT request permission —
/// `Geolocator.getPositionStream` silently waits forever if
/// permission was never granted. So callers must `await ensurePermission()`
/// first; the streams are only subscribed to once permission is confirmed.
class LocationService {
  /// Ensures location service is on and permission is granted, requesting it
  /// if needed. Throws [LocationException] if it cannot proceed.
  Future<void> ensurePermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationException(LocationError.serviceDisabled);
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(LocationError.permissionDeniedForever);
    }
    if (permission == LocationPermission.denied) {
      throw const LocationException(LocationError.permissionDenied);
    }
  }

  /// One-shot current position (with a timeout so it never hangs).
  Future<Position> currentPosition() async {
    await ensurePermission();
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
  }

  /// One-shot [GpsStatus] — used by the dashboard for a quick pre-check.
  Future<GpsStatus> currentStatus() async => toStatus(await currentPosition());

  /// Real-time [Position] stream. Call [ensurePermission] before subscribing.
  Stream<Position> positionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    );
  }

  GpsStatus toStatus(Position position) {
    final dist = haversineDistance(
      lat1: position.latitude,
      lng1: position.longitude,
      lat2: AppConstants.officeLatitude,
      lng2: AppConstants.officeLongitude,
    );
    return dist <= AppConstants.allowedRadiusMeters
        ? InArea(distanceMeters: dist)
        : OutsideArea(distanceMeters: dist);
  }
}
