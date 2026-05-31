import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/gps_status.dart';
import '../../providers/location_providers.dart';

class EmployeeLocationScreen extends ConsumerStatefulWidget {
  const EmployeeLocationScreen({super.key});

  @override
  ConsumerState<EmployeeLocationScreen> createState() =>
      _EmployeeLocationScreenState();
}

class _EmployeeLocationScreenState
    extends ConsumerState<EmployeeLocationScreen> {
  GoogleMapController? _mapController;

  static const _office =
      LatLng(AppConstants.officeLatitude, AppConstants.officeLongitude);

  static final _circles = {
    Circle(
      circleId: const CircleId('radius'),
      center: _office,
      radius: AppConstants.allowedRadiusMeters,
      fillColor: AppColors.info.withValues(alpha: 0.1),
      strokeColor: AppColors.info,
      strokeWidth: 2,
    ),
  };

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final permissionAsync = ref.watch(locationPermissionProvider);
    final gpsAsync = ref.watch(gpsStatusProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lokasi Saya'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: permissionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_off_rounded,
                  size: 64, color: AppColors.danger),
              const SizedBox(height: 12),
              Text('Izin lokasi diperlukan',
                  style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('$e',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: AppColors.textMuted),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
        data: (_) {
          final posAsync = ref.watch(positionStreamProvider);
          final status = gpsAsync.value;
          final pos = posAsync.value;

          final markers = <Marker>{
            Marker(
              markerId: const MarkerId('office'),
              position: _office,
              infoWindow: const InfoWindow(title: 'Kantor'),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue),
            ),
            if (pos != null)
              Marker(
                markerId: const MarkerId('me'),
                position: LatLng(pos.latitude, pos.longitude),
                infoWindow: InfoWindow(
                  title: 'Lokasi Saya',
                  snippet: status?.isInArea == true ? 'Dalam Area' : 'Luar Area',
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  status?.isInArea == true
                      ? BitmapDescriptor.hueGreen
                      : BitmapDescriptor.hueOrange,
                ),
              ),
          };

          if (pos != null) {
            _mapController?.animateCamera(
              CameraUpdate.newLatLng(LatLng(pos.latitude, pos.longitude)),
            );
          }

          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: _office,
                  zoom: 15,
                ),
                markers: markers,
                circles: _circles,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                onMapCreated: (c) => _mapController = c,
              ),
              if (status != null)
                Positioned(
                  top: 12,
                  left: 16,
                  right: 16,
                  child: _StatusBanner(status: status),
                ),
              if (pos == null)
                const Positioned(
                  top: 12,
                  left: 16,
                  right: 16,
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        children: [
                          SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2)),
                          SizedBox(width: 12),
                          Text('Mendapatkan lokasi…'),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.status});
  final GpsStatus status;

  @override
  Widget build(BuildContext context) {
    final inArea = status.isInArea;
    final color = inArea ? AppColors.success : AppColors.warning;
    final icon =
        inArea ? Icons.check_circle_rounded : Icons.location_off_rounded;
    final label = inArea ? 'Dalam Area Kantor' : 'Di Luar Area Kantor';
    final dist = '${status.distanceMeters.toStringAsFixed(0)} m dari kantor';

    return Card(
      color: color.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 13)),
                Text(dist,
                    style: TextStyle(
                        color: color.withValues(alpha: 0.8),
                        fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
