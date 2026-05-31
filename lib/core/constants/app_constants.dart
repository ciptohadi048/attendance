/// Centralized, immutable configuration values used across the app.
///
/// Keeping these in one place (instead of magic numbers scattered in widgets)
/// makes the GPS rules, Firestore collection names, and storage paths easy to
/// reason about and change in a single edit.
class AppConstants {
  AppConstants._(); // never instantiate – this is a static holder only.

  // ---------------------------------------------------------------------------
  // Branding
  // ---------------------------------------------------------------------------
  static const String appName = 'Factory Attendance';
  static const String appTagline = 'Modern Industrial HRIS';

  // ---------------------------------------------------------------------------
  // Office / GPS validation rules (see Soal Pemahaman #3, #4)
  // ---------------------------------------------------------------------------
  /// Office coordinates 
  static const double officeLatitude = -6.393348480059302;
  static const double officeLongitude = 108.14789434987834;

  /// Allowed clock-in radius around the office, in meters.
  static const double allowedRadiusMeters = 500;

  // ---------------------------------------------------------------------------
  // Firestore collection names (single source of truth for queries)
  // ---------------------------------------------------------------------------
  static const String usersCollection = 'users';
  static const String attendanceCollection = 'attendance';
  static const String passwordResetRequestsCollection = 'password_reset_requests';

  // ---------------------------------------------------------------------------
  // SharedPreferences keys ("Remember Me")
  // ---------------------------------------------------------------------------
  static const String prefRememberMe = 'remember_me';
  static const String prefSavedIdentifier = 'saved_identifier';
  static const String prefThemeMode = 'theme_mode';
  static const String prefLocale = 'app_locale';

  // ---------------------------------------------------------------------------
  // Firebase Storage paths
  // ---------------------------------------------------------------------------
  /// Selfie upload path: /attendance/{userId}/{date}.jpg
  static String selfieStoragePath(String userId, String date) =>
      'attendance/$userId/$date.jpg';

  // ---------------------------------------------------------------------------
  // UI timing
  // ---------------------------------------------------------------------------
  static const Duration splashDuration = Duration(milliseconds: 2000);
}
