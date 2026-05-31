import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/attendance_record.dart';
import '../../providers/admin_providers.dart';

class AdminMapScreen extends ConsumerStatefulWidget {
  const AdminMapScreen({super.key});

  @override
  ConsumerState<AdminMapScreen> createState() => _AdminMapScreenState();
}

class _AdminMapScreenState extends ConsumerState<AdminMapScreen> {
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

  Set<Marker> _buildMarkers(
    List<AttendanceRecord> records,
    Map<String, String> empMap,
  ) {
    final clockIns =
        records.where((r) => r.type == AttendanceType.clockIn).toList();
    return {
      Marker(
        markerId: const MarkerId('office'),
        position: _office,
        infoWindow: const InfoWindow(title: 'Kantor'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
      for (final r in clockIns)
        Marker(
          markerId: MarkerId(r.id),
          position: LatLng(r.latitude, r.longitude),
          infoWindow: InfoWindow(
            title: empMap[r.userId] ?? 'Karyawan',
            snippet: r.status.label,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            r.status == AttendanceStatus.hadir
                ? BitmapDescriptor.hueGreen
                : BitmapDescriptor.hueOrange,
          ),
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final attendanceAsync = ref.watch(todayAllAttendanceProvider);
    final employeesAsync = ref.watch(employeeListProvider);

    final employees = employeesAsync.value ?? [];
    final empMap = {for (final e in employees) e.uid: e.name};

    // Build markers regardless of loading state so map widget stays alive.
    final records = attendanceAsync.value ?? [];
    final markers = _buildMarkers(records, empMap);
    final clockInCount =
        records.where((r) => r.type == AttendanceType.clockIn).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Peta Clock-In Hari Ini'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          // Map is always present — markers update reactively.
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _office,
              zoom: 15,
            ),
            markers: markers,
            circles: _circles,
            myLocationButtonEnabled: false,
            onMapCreated: (c) => _mapController = c,
          ),

          // Show error banner if stream fails (overlay, doesn't hide map).
          if (attendanceAsync.hasError)
            Positioned(
              top: 8,
              left: 16,
              right: 16,
              child: Card(
                color: AppColors.danger.withValues(alpha: 0.9),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Gagal memuat data: ${attendanceAsync.error}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ),

          // Loading indicator overlay (doesn't recreate map).
          if (attendanceAsync.isLoading)
            const Positioned(
              top: 8,
              right: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),

          // Legend
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _Legend(color: Colors.blue, label: 'Kantor'),
                    _Legend(color: AppColors.success, label: 'Hadir'),
                    _Legend(color: AppColors.warning, label: 'Telat'),
                    Text('$clockInCount clock-in',
                        style: Theme.of(context).textTheme.labelSmall),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
