import 'package:firebase_auth/firebase_auth.dart';

/// Translates raw exceptions (mostly [FirebaseAuthException]) into short,
/// user-friendly Indonesian messages.
///
/// Centralizing this means the UI layer never has to know Firebase error codes,
/// and every screen shows consistent wording (rubric B4: user-friendly errors).
String authErrorMessage(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan. Hubungi HRD.';
      case 'user-not-found':
        return 'NIK / email tidak terdaftar.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'NIK / email atau password salah.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti.';
      case 'network-request-failed':
        return 'Tidak ada koneksi internet.';
      case 'email-already-in-use':
        return 'Email sudah terdaftar.';
      case 'weak-password':
        return 'Password terlalu lemah (minimal 6 karakter).';
      default:
        return error.message ?? 'Terjadi kesalahan autentikasi.';
    }
  }
  return 'Terjadi kesalahan. Silakan coba lagi.';
}
