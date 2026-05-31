import 'dart:math' as math;

/// Result of a GPS validation check.
///
/// Carries the actual distance so the UI can display "234m from office"
/// whether the user is inside or outside the allowed radius.
sealed class GpsStatus {
  const GpsStatus({required this.distanceMeters});

  final double distanceMeters;

  /// True only when the user is within [AppConstants.allowedRadiusMeters].
  bool get isInArea => this is InArea;

  String get distanceLabel {
    if (distanceMeters < 1000) {
      return '${distanceMeters.toStringAsFixed(0)} m';
    }
    return '${(distanceMeters / 1000).toStringAsFixed(2)} km';
  }
}

final class InArea extends GpsStatus {
  const InArea({required super.distanceMeters});
}

final class OutsideArea extends GpsStatus {
  const OutsideArea({required super.distanceMeters});
}

/// Haversine formula — pure Dart, no external package needed.
///
/// Calculates the great-circle distance between two coordinates on Earth.
/// Named after the haversine function (half-versine) of the central angle.
/// Accuracy: < 0.5% for distances under 100 km, which is more than sufficient
/// for a 500 m office radius check.
///
/// Formula:
///   a = sin²(Δlat/2) + cos(lat₁)·cos(lat₂)·sin²(Δlng/2)
///   c = 2·atan2(√a, √(1−a))
///   d = R·c    where R = 6 371 000 m (mean Earth radius)
double haversineDistance({
  required double lat1,
  required double lng1,
  required double lat2,
  required double lng2,
}) {
  const earthRadiusMeters = 6371000.0;
  final dLat = _toRad(lat2 - lat1);
  final dLng = _toRad(lng2 - lng1);
  final a = math.pow(math.sin(dLat / 2), 2) +
      math.cos(_toRad(lat1)) *
          math.cos(_toRad(lat2)) *
          math.pow(math.sin(dLng / 2), 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return earthRadiusMeters * c;
}

double _toRad(double deg) => deg * (math.pi / 180.0);
