import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/entities/attendance_record.dart';
import '../providers/auth_providers.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/admin_map_screen.dart';
import '../screens/admin/attendance_logs_screen.dart';
import '../screens/admin/create_user_screen.dart';
import '../screens/admin/employee_detail_screen.dart';
import '../screens/admin/employee_list_screen.dart';
import '../screens/admin/kpi_charts_screen.dart';
import '../screens/admin/password_requests_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/camera/face_failed_screen.dart';
import '../screens/camera/face_success_screen.dart';
import '../screens/camera/selfie_camera_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/gps/gps_validation_screen.dart';
import '../screens/history/attendance_detail_screen.dart';
import '../screens/history/attendance_history_screen.dart';
import '../screens/location/employee_location_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/profile/change_password_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/splash/splash_screen.dart';
import 'app_routes.dart';

class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen(authStateProvider, (_, _) => notifyListeners());
  }
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _AuthRefreshNotifier(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refresh,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      if (loc == AppRoutes.splash) return null;

      final authState = ref.read(authStateProvider);

      // Only redirect to splash during initial load (i.e. the user hasn't
      // reached the login page yet). If the user IS on the login page and
      // auth briefly goes to loading (because Firebase Auth's state-change
      // stream fires asyncMap to fetch the Firestore profile), we must stay
      // put — otherwise the router bounces the user to splash mid-sign-in
      // and the login button appears to spin forever.
      final loggingIn = loc == AppRoutes.login;
      if (authState.isLoading && !loggingIn) return AppRoutes.splash;
      if (authState.isLoading) return null;

      final user = authState.value;

      if (user == null) return loggingIn ? null : AppRoutes.login;
      if (loggingIn) return user.isAdmin ? AppRoutes.admin : AppRoutes.dashboard;
      if (loc.startsWith(AppRoutes.admin) && !user.isAdmin) {
        return AppRoutes.dashboard;
      }
      // Admins landing on the employee dashboard (e.g. from the clock-in
      // success screen's "Kembali ke Dashboard") belong on the admin shell.
      if (loc == AppRoutes.dashboard && user.isAdmin) {
        return AppRoutes.admin;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, _) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (_, _) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.admin,
        builder: (_, _) => const AdminDashboardScreen(),
      ),

      // GPS → Selfie → Result flow
      GoRoute(
        path: AppRoutes.gpsValidation,
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final type = extra['attendanceType'] as AttendanceType? ??
              AttendanceType.clockIn;
          return GpsValidationScreen(attendanceType: type);
        },
      ),
      GoRoute(
        path: AppRoutes.selfieCamera,
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return SelfieCameraScreen(
            attendanceType: extra['attendanceType'] as AttendanceType? ??
                AttendanceType.clockIn,
            userId: extra['userId'] as String? ?? '',
            latitude: (extra['latitude'] as num?)?.toDouble() ?? 0,
            longitude: (extra['longitude'] as num?)?.toDouble() ?? 0,
            distanceMeters: (extra['distanceMeters'] as num?)?.toDouble() ?? 0,
            isInArea: extra['isInArea'] as bool? ?? false,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.faceSuccess,
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return FaceSuccessScreen(
            attendanceType: extra['attendanceType'] as AttendanceType? ??
                AttendanceType.clockIn,
            selfieFile: extra['selfieFile'] as dynamic,
            record: extra['record'] as AttendanceRecord?,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.faceFailed,
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return FaceFailedScreen(
            attendanceType: extra['attendanceType'] as AttendanceType? ??
                AttendanceType.clockIn,
            retryArgs: extra,
          );
        },
      ),

      // Day 8 — History & Profile
      GoRoute(
        path: AppRoutes.attendanceHistory,
        builder: (_, _) => const AttendanceHistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.attendanceDetail,
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return AttendanceDetailScreen(
            record: extra['record'] as AttendanceRecord,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (_, _) => const ProfileScreen(),
      ),

      // Day 9 — Notifications, edit profile & change password
      GoRoute(
        path: AppRoutes.notifications,
        builder: (_, _) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (_, _) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.changePassword,
        builder: (_, _) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.employeeLocation,
        builder: (_, _) => const EmployeeLocationScreen(),
      ),

      // Admin sub-screens
      GoRoute(
        path: AppRoutes.adminEmployeeList,
        builder: (_, _) => const EmployeeListScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminEmployeeDetail,
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return EmployeeDetailScreen(user: extra['user'] as AppUser);
        },
      ),
      GoRoute(
        path: AppRoutes.adminKpiCharts,
        builder: (_, _) => const KpiChartsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminAttendanceLogs,
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return AttendanceLogsScreen(
            presetUserId: extra?['userId'] as String?,
            presetUserName: extra?['userName'] as String?,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.adminMap,
        builder: (_, _) => const AdminMapScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminCreateUser,
        builder: (_, _) => const CreateUserScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminPasswordRequests,
        builder: (_, _) => const PasswordRequestsScreen(),
      ),
    ],
  );
});
