// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Factory Attendance';

  @override
  String get appTagline => 'Modern Industrial HRIS';

  @override
  String get welcome => 'Welcome';

  @override
  String get loginSubtitle => 'Sign in to start your attendance';

  @override
  String get nikOrEmail => 'NIK or Email';

  @override
  String get nikOrEmailHint => 'Enter NIK or email';

  @override
  String get password => 'Password';

  @override
  String get passwordHint => 'Enter password';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get login => 'Sign In';

  @override
  String get contactHrd => 'Contact HRD if you don\'t have an account yet.';

  @override
  String get forgotPasswordTitle => 'Forgot Password';

  @override
  String get forgotPasswordDesc =>
      'Enter your NIK and name. HRD Admin will reset your password.';

  @override
  String get nik => 'NIK';

  @override
  String get fullName => 'Full name';

  @override
  String get name => 'Name';

  @override
  String get cancel => 'Cancel';

  @override
  String get sendToAdmin => 'Send to Admin';

  @override
  String get nikAndNameRequired => 'NIK and name are required';

  @override
  String get requestSent => 'Request sent. Admin will process it shortly.';

  @override
  String requestFailed(String error) {
    return 'Failed to send request: $error';
  }

  @override
  String get loginFailed => 'Login failed. Try again.';

  @override
  String get todayAttendance => 'Today\'s Attendance';

  @override
  String get clockIn => 'Clock In';

  @override
  String get clockOut => 'Clock Out';

  @override
  String get attendanceComplete => 'Today\'s attendance is complete';

  @override
  String get weeklyStats => 'This Week\'s Stats';

  @override
  String get menu => 'Menu';

  @override
  String get statusHadir => 'Present';

  @override
  String get statusTelat => 'Late';

  @override
  String get statusIzin => 'Permit';

  @override
  String get statusAlpha => 'Absent';

  @override
  String get history => 'History';

  @override
  String get notifications => 'Notifications';

  @override
  String get profile => 'Profile';

  @override
  String get location => 'Location';

  @override
  String get clockInSuccess => 'Clock In Successful';

  @override
  String get clockOutSuccess => 'Clock Out Successful';

  @override
  String get attendanceFailed => 'Attendance Failed';

  @override
  String get backToDashboard => 'Back to Dashboard';

  @override
  String get retry => 'Retry';

  @override
  String get gpsValidation => 'GPS Validation';

  @override
  String get checkingLocation => 'Checking your location...';

  @override
  String get inArea => 'In Area';

  @override
  String get outsideArea => 'Outside Area';

  @override
  String distanceFromOffice(String distance) {
    return '$distance from office';
  }

  @override
  String get proceedToSelfie => 'Proceed to Selfie';

  @override
  String get outsideAreaWarning =>
      'You are outside the office area. Attendance will still be recorded with outside area status.';

  @override
  String get selfieCamera => 'Selfie Camera';

  @override
  String get faceDetected => 'Face Detected';

  @override
  String get noFaceDetected => 'No Face Detected';

  @override
  String get takeSelfie => 'Take Selfie';

  @override
  String get faceVerificationFailed => 'Face Verification Failed';

  @override
  String get attendanceHistory => 'Attendance History';

  @override
  String get attendanceDetail => 'Attendance Detail';

  @override
  String get noRecords => 'No attendance records yet';

  @override
  String get date => 'Date';

  @override
  String get time => 'Time';

  @override
  String get status => 'Status';

  @override
  String get selfie => 'Selfie';

  @override
  String get locationInfo => 'Location Info';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get changePassword => 'Change Password';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get save => 'Save';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirm => 'Are you sure you want to logout?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get department => 'Department';

  @override
  String get position => 'Position';

  @override
  String get phone => 'Phone';

  @override
  String get email => 'Email';

  @override
  String get adminDashboard => 'Admin Dashboard';

  @override
  String get employeeList => 'Employee List';

  @override
  String get employeeDetail => 'Employee Detail';

  @override
  String get createUser => 'Create User';

  @override
  String get attendanceLogs => 'Attendance Logs';

  @override
  String get kpiCharts => 'KPI Charts';

  @override
  String get passwordRequests => 'Password Reset Requests';

  @override
  String get adminMap => 'Employee Map';

  @override
  String get totalEmployees => 'Total Employees';

  @override
  String get presentToday => 'Present Today';

  @override
  String get lateToday => 'Late Today';

  @override
  String get absentToday => 'Absent Today';

  @override
  String get approve => 'Approve';

  @override
  String get reject => 'Reject';

  @override
  String get pending => 'Pending';

  @override
  String get processed => 'Processed';

  @override
  String get export => 'Export';

  @override
  String get filter => 'Filter';

  @override
  String get search => 'Search';

  @override
  String get all => 'All';

  @override
  String get employee => 'Employee';

  @override
  String get admin => 'Admin';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get language => 'Language';

  @override
  String get indonesian => 'Indonesia';

  @override
  String get english => 'English';

  @override
  String get errorGeneric => 'An error occurred';

  @override
  String get errorNetwork => 'Connection failed. Check your internet.';

  @override
  String get errorInvalidCredentials => 'NIK / email or password is incorrect.';

  @override
  String get loading => 'Loading...';

  @override
  String get success => 'Success';

  @override
  String get failed => 'Failed';
}
