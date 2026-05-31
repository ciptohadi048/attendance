class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String admin = '/admin';

  // GPS → Selfie → Result flow
  static const String gpsValidation = '/gps-validation';
  static const String selfieCamera = '/selfie-camera';
  static const String faceSuccess = '/face-success';
  static const String faceFailed = '/face-failed';

  // Day 8
  static const String attendanceHistory = '/history';
  static const String attendanceDetail = '/history/detail';
  static const String profile = '/profile';

  // Day 9
  static const String editProfile = '/profile/edit';
  static const String changePassword = '/profile/change-password';
  static const String notifications = '/notifications';

  // Admin sub-screens
  static const String adminEmployeeList = '/admin/employees';
  static const String adminEmployeeDetail = '/admin/employees/detail';
  static const String adminKpiCharts = '/admin/kpi';
  static const String adminAttendanceLogs = '/admin/logs';
  static const String adminMap = '/admin/map';
  static const String adminCreateUser = '/admin/create-user';
  static const String adminPasswordRequests = '/admin/password-requests';

  // Employee location view
  static const String employeeLocation = '/location';
}
