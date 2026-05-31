/// Pure, side-effect-free form validators.
///
/// Kept out of the widgets so the same rules can be unit-tested in isolation
/// (supports the optional unit-test bonus) and reused across screens.
class Validators {
  Validators._();

  static final RegExp _emailRegex =
      RegExp(r'^[\w.\-]+@([\w\-]+\.)+[\w\-]{2,}$');

  /// The login field accepts either an email or a numeric NIK.
  static String? identifier(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'NIK atau email wajib diisi';
    final isEmail = v.contains('@');
    if (isEmail) {
      if (!_emailRegex.hasMatch(v)) return 'Format email tidak valid';
    } else {
      // Treat as NIK: digits only, sensible length.
      if (!RegExp(r'^\d{4,20}$').hasMatch(v)) {
        return 'NIK harus berupa angka (4-20 digit)';
      }
    }
    return null;
  }

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email wajib diisi';
    if (!_emailRegex.hasMatch(v)) return 'Format email tidak valid';
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Password wajib diisi';
    if (v.length < 6) return 'Password minimal 6 karakter';
    return null;
  }

  static String? required(String? value, {String field = 'Field'}) {
    if ((value?.trim() ?? '').isEmpty) return '$field wajib diisi';
    return null;
  }
}
