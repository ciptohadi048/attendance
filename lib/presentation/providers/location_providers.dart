import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/services/location_service.dart';
import '../../domain/entities/gps_status.dart';

final locationServiceProvider = Provider<LocationService>(
  (_) => LocationService(),
);

/// Resolves location permission once (requesting it if needed). The position
/// stream is only started after this completes successfully, so we never
/// subscribe to a stream that would hang waiting for an ungranted permission.
final locationPermissionProvider = FutureProvider.autoDispose<void>((ref) async {
  await ref.watch(locationServiceProvider).ensurePermission();
});

/// Real-time [Position] stream — gated behind [locationPermissionProvider].
/// Drives both the map camera and the GPS status.
final positionStreamProvider = StreamProvider.autoDispose<Position>((ref) async* {
  // Wait until permission is confirmed before subscribing to the OS stream.
  await ref.watch(locationPermissionProvider.future);
  yield* ref.watch(locationServiceProvider).positionStream();
});

/// [GpsStatus] derived from the position stream (single source of truth — the
/// distance shown and the map position always agree).
final gpsStatusProvider = Provider.autoDispose<AsyncValue<GpsStatus>>((ref) {
  final service = ref.watch(locationServiceProvider);
  return ref.watch(positionStreamProvider).whenData(service.toStatus);
});

/// Firebase Storage singleton provider.
final firebaseStorageProvider = Provider<FirebaseStorage>(
  (_) => FirebaseStorage.instance,
);
