import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

/// Thin wrapper around [SharedPreferences] for the "Remember Me" feature.
///
/// Wrapping the raw key/value store in a typed service keeps preference keys in
/// one place and lets the rest of the app depend on intent ("did the user ask
/// to be remembered?") rather than string keys.
class SharedPrefsService {
  SharedPrefsService(this._prefs);

  final SharedPreferences _prefs;

  bool get rememberMe => _prefs.getBool(AppConstants.prefRememberMe) ?? false;

  String? get savedIdentifier =>
      _prefs.getString(AppConstants.prefSavedIdentifier);

  /// Persist the "remember me" choice. When enabled we keep the login
  /// identifier (NIK/email) to pre-fill the field next launch; when disabled we
  /// clear it so nothing lingers.
  Future<void> setRememberMe(bool value, {String? identifier}) async {
    await _prefs.setBool(AppConstants.prefRememberMe, value);
    if (value && identifier != null && identifier.isNotEmpty) {
      await _prefs.setString(AppConstants.prefSavedIdentifier, identifier);
    } else {
      await _prefs.remove(AppConstants.prefSavedIdentifier);
    }
  }

  Future<void> clear() async {
    await _prefs.remove(AppConstants.prefRememberMe);
    await _prefs.remove(AppConstants.prefSavedIdentifier);
  }

  // --- Theme mode (dark-mode toggle, persisted) ---

  /// Stored as 'dark' | 'light' | 'system'. Defaults to dark (the primary
  /// industrial look).
  String get themeMode => _prefs.getString(AppConstants.prefThemeMode) ?? 'dark';

  Future<void> setThemeMode(String mode) =>
      _prefs.setString(AppConstants.prefThemeMode, mode);

  // --- Locale (language switcher, persisted) ---

  /// Stored as 'id' | 'en'. Defaults to 'id' (Indonesian).
  String get locale => _prefs.getString(AppConstants.prefLocale) ?? 'id';

  Future<void> setLocale(String languageCode) =>
      _prefs.setString(AppConstants.prefLocale, languageCode);
}
