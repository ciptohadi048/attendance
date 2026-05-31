import 'package:flutter_test/flutter_test.dart';
import 'package:tugasgila/core/errors/auth_failure.dart';

void main() {
  // -------------------------------------------------------------------------
  // authErrorMessage — non-Firebase errors
  // -------------------------------------------------------------------------
  // Note: FirebaseAuthException branches require firebase_core initialization.
  // Those are best tested in integration tests. Here we test the fallback path.
  group('authErrorMessage (non-Firebase errors)', () {
    test('generic Exception returns fallback message', () {
      final result = authErrorMessage(Exception('something went wrong'));
      expect(result, 'Terjadi kesalahan. Silakan coba lagi.');
    });

    test('String error returns fallback message', () {
      final result = authErrorMessage('random error');
      expect(result, 'Terjadi kesalahan. Silakan coba lagi.');
    });

    test('TypeError returns fallback message', () {
      final result = authErrorMessage(TypeError());
      expect(result, 'Terjadi kesalahan. Silakan coba lagi.');
    });

    test('FormatException returns fallback message', () {
      final result = authErrorMessage(const FormatException('bad format'));
      expect(result, 'Terjadi kesalahan. Silakan coba lagi.');
    });
  });
}
