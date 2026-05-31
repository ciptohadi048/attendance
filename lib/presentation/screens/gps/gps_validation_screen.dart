import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/location_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/l10n_extension.dart';
import '../../../domain/entities/attendance_record.dart';
import '../../../domain/entities/gps_status.dart';
import '../../providers/auth_providers.dart';
import '../../providers/location_providers.dart';
import '../../router/app_routes.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/status_badge.dart';

class GpsValidationScreen extends ConsumerStatefulWidget {
  const GpsValidationScreen({super.key, required this.attendanceType});

  final AttendanceType attendanceType;

  @override
  ConsumerState<GpsValidationScreen> createState() =>
      _GpsValidationScreenState();
}

class _GpsValidationScreenState extends ConsumerState<GpsValidationScreen>
    with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  bool? _wasInArea; // for geofence enter/exit detection

  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
    upperBound: 1.15,
    lowerBound: 1.0,
  );

  static const LatLng _office = LatLng(
    AppConstants.officeLatitude,
    AppConstants.officeLongitude,
  );

  @override
  void dispose() {
    _mapController?.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onStatusChanged(GpsStatus? next) {
    if (next == null) return;
    final inArea = next.isInArea;
    if (_wasInArea != null && _wasInArea != inArea && mounted) {
      _pulseController.forward().then((_) => _pulseController.reverse());
      final l10n = context.l10n;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(inArea ? l10n.inArea : l10n.outsideArea),
          backgroundColor: inArea ? AppColors.success : AppColors.danger,
        ),
      );
    }
    _wasInArea = inArea;
  }

  @override
  Widget build(BuildContext context) {
    final permissionAsync = ref.watch(locationPermissionProvider);
    final l10n = context.l10n;

    // Geofence listener (only meaningful once we have status).
    ref.listen(gpsStatusProvider, (_, next) => _onStatusChanged(next.value));

    // Move the map camera as the user moves.
    ref.listen(positionStreamProvider, (_, next) {
      final p = next.value;
      if (p != null) {
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(LatLng(p.latitude, p.longitude)),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.attendanceType == AttendanceType.clockIn
              ? '${l10n.gpsValidation} — ${l10n.clockIn}'
              : '${l10n.gpsValidation} — ${l10n.clockOut}',
        ),
      ),
      body: permissionAsync.when(
        loading: () => _CenteredLoader(text: l10n.checkingLocation),
        error: (e, _) => _PermissionError(
          error: e,
          onRetry: () => ref.invalidate(locationPermissionProvider),
        ),
        data: (_) => _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final posAsync = ref.watch(positionStreamProvider);
    final statusAsync = ref.watch(gpsStatusProvider);
    final l10n = context.l10n;

    return Column(
      children: [
        Expanded(
          flex: 3,
          child: posAsync.when(
            loading: () => _CenteredLoader(text: l10n.checkingLocation),
            error: (e, _) => _PermissionError(
              error: e,
              onRetry: () => ref.invalidate(positionStreamProvider),
            ),
            data: (position) => _Map(
              position: position,
              office: _office,
              onCreated: (c) => _mapController = c,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          color: AppColors.navy800,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: statusAsync.when(
            loading: () => _StatusLoading(text: l10n.checkingLocation),
            error: (e, _) => Text(
              e is LocationException ? e.message : l10n.errorGeneric,
              style: const TextStyle(color: AppColors.danger),
            ),
            data: (status) => _StatusCard(
              status: status,
              position: posAsync.value,
              attendanceType: widget.attendanceType,
              pulseController: _pulseController,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Map
// ---------------------------------------------------------------------------

class _Map extends StatelessWidget {
  const _Map({
    required this.position,
    required this.office,
    required this.onCreated,
  });

  final Position position;
  final LatLng office;
  final void Function(GoogleMapController) onCreated;

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 16,
      ),
      onMapCreated: onCreated,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      markers: {
        Marker(
          markerId: const MarkerId('office'),
          position: office,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
          infoWindow: const InfoWindow(title: 'Kantor'),
        ),
      },
      circles: {
        Circle(
          circleId: const CircleId('radius'),
          center: office,
          radius: AppConstants.allowedRadiusMeters,
          fillColor: AppColors.safetyOrange.withValues(alpha: 0.12),
          strokeColor: AppColors.safetyOrange,
          strokeWidth: 2,
        ),
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Status card
// ---------------------------------------------------------------------------

class _StatusCard extends ConsumerWidget {
  const _StatusCard({
    required this.status,
    required this.position,
    required this.attendanceType,
    required this.pulseController,
  });

  final GpsStatus status;
  final Position? position;
  final AttendanceType attendanceType;
  final AnimationController pulseController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final user = ref.watch(authStateProvider).value;
    final canContinue = status.isInArea && user != null && position != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.place_rounded,
                color: AppColors.safetyOrange, size: 20),
            const SizedBox(width: 6),
            Text(l10n.distanceFromOffice(status.distanceLabel),
                style: theme.textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 12),
        ScaleTransition(
          scale: pulseController,
          child: GpsStatusBadge(status: status),
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          label: '${l10n.proceedToSelfie} — ${attendanceType == AttendanceType.clockIn ? l10n.clockIn : l10n.clockOut}',
          icon: Icons.camera_alt_rounded,
          onPressed: canContinue
              ? () => context.push(
                    AppRoutes.selfieCamera,
                    extra: {
                      'attendanceType': attendanceType,
                      'userId': user.uid,
                      'latitude': position!.latitude,
                      'longitude': position!.longitude,
                      'distanceMeters': status.distanceMeters,
                      'isInArea': status.isInArea,
                    },
                  )
              : null,
        ),
        if (!status.isInArea)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              l10n.outsideAreaWarning,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: AppColors.textMuted),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// State widgets
// ---------------------------------------------------------------------------

class _CenteredLoader extends StatelessWidget {
  const _CenteredLoader({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.navy800,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppColors.safetyOrange),
            ),
            const SizedBox(height: 16),
            Text(text,
                style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _PermissionError extends StatelessWidget {
  const _PermissionError({required this.error, required this.onRetry});
  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isPermanent = error is LocationException &&
        (error as LocationException).reason ==
            LocationError.permissionDeniedForever;
    final message =
        error is LocationException ? (error as LocationException).message : '$error';

    return Container(
      color: AppColors.navy800,
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_off_rounded,
                color: AppColors.danger, size: 52),
            const SizedBox(height: 16),
            Text(
              l10n.gpsValidation,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 24),
            if (isPermanent)
              ElevatedButton.icon(
                onPressed: () => Geolocator.openAppSettings(),
                icon: const Icon(Icons.settings_rounded),
                label: const Text('Buka Pengaturan'),
              )
            else
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.retry),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusLoading extends StatelessWidget {
  const _StatusLoading({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(AppColors.safetyOrange),
          ),
        ),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(color: AppColors.textSecondary)),
      ],
    );
  }
}
