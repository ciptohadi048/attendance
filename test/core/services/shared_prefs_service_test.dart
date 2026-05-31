import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tugasgila/core/constants/app_constants.dart';
import 'package:tugasgila/core/services/shared_prefs_service.dart';

void main() {
  late SharedPreferences prefs;
  late SharedPrefsService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    service = SharedPrefsService(prefs);
  });

  // -------------------------------------------------------------------------
  // rememberMe
  // -------------------------------------------------------------------------
  group('SharedPrefsService.rememberMe', () {
    test('defaults to false', () {
      expect(service.rememberMe, isFalse);
    });

    test('returns true after setRememberMe(true)', () async {
      await service.setRememberMe(true, identifier: 'budi@test.com');
      expect(service.rememberMe, isTrue);
    });

    test('returns false after setRememberMe(false)', () async {
      await service.setRememberMe(true, identifier: 'budi@test.com');
      await service.setRememberMe(false);
      expect(service.rememberMe, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // savedIdentifier
  // -------------------------------------------------------------------------
  group('SharedPrefsService.savedIdentifier', () {
    test('defaults to null', () {
      expect(service.savedIdentifier, isNull);
    });

    test('stores identifier when rememberMe is true', () async {
      await service.setRememberMe(true, identifier: '12345678');
      expect(service.savedIdentifier, '12345678');
    });

    test('removes identifier when rememberMe is false', () async {
      await service.setRememberMe(true, identifier: '12345678');
      await service.setRememberMe(false);
      expect(service.savedIdentifier, isNull);
    });

    test('removes identifier when value is true but identifier is null', () async {
      await service.setRememberMe(true, identifier: 'test@x.com');
      await service.setRememberMe(true); // no identifier
      expect(service.savedIdentifier, isNull);
    });

    test('removes identifier when value is true but identifier is empty', () async {
      await service.setRememberMe(true, identifier: 'test@x.com');
      await service.setRememberMe(true, identifier: '');
      expect(service.savedIdentifier, isNull);
    });
  });

  // -------------------------------------------------------------------------
  // themeMode
  // -------------------------------------------------------------------------
  group('SharedPrefsService.themeMode', () {
    test('defaults to "dark"', () {
      expect(service.themeMode, 'dark');
    });

    test('stores and retrieves theme mode', () async {
      await service.setThemeMode('light');
      expect(service.themeMode, 'light');
    });

    test('stores "system" mode', () async {
      await service.setThemeMode('system');
      expect(service.themeMode, 'system');
    });
  });

  // -------------------------------------------------------------------------
  // clear
  // -------------------------------------------------------------------------
  group('SharedPrefsService.clear', () {
    test('removes rememberMe and savedIdentifier', () async {
      await service.setRememberMe(true, identifier: 'budi@test.com');
      await service.clear();
      expect(service.rememberMe, isFalse);
      expect(service.savedIdentifier, isNull);
    });

    test('does not affect themeMode', () async {
      await service.setThemeMode('light');
      await service.setRememberMe(true, identifier: 'x');
      await service.clear();
      expect(service.themeMode, 'light');
    });
  });
}
