import 'package:flutter_test/flutter_test.dart';
import 'package:tugasgila/core/utils/validators.dart';

void main() {
  group('Validators.identifier', () {
    test('rejects empty input', () {
      expect(Validators.identifier(''), isNotNull);
      expect(Validators.identifier(null), isNotNull);
    });

    test('accepts a valid email', () {
      expect(Validators.identifier('budi@pabrik.com'), isNull);
    });

    test('rejects a malformed email', () {
      expect(Validators.identifier('budi@@pabrik'), isNotNull);
    });

    test('accepts a numeric NIK', () {
      expect(Validators.identifier('12345678'), isNull);
    });

    test('rejects a NIK that is too short', () {
      expect(Validators.identifier('12'), isNotNull);
    });

    test('rejects a NIK with letters', () {
      expect(Validators.identifier('12ab56'), isNotNull);
    });
  });

  group('Validators.password', () {
    test('rejects empty', () {
      expect(Validators.password(''), isNotNull);
    });

    test('rejects fewer than 6 characters', () {
      expect(Validators.password('123'), isNotNull);
    });

    test('accepts 6 or more characters', () {
      expect(Validators.password('secret1'), isNull);
    });
  });

  group('Validators.email', () {
    test('accepts a valid email', () {
      expect(Validators.email('hrd@pabrik.co.id'), isNull);
    });

    test('rejects input without a domain', () {
      expect(Validators.email('hrd@'), isNotNull);
    });
  });
}
