import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_providers.dart';

/// Holds the active [Locale] and persists changes to SharedPreferences so
/// the user's language choice survives restarts.
class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final stored = ref.read(sharedPrefsServiceProvider).locale;
    return Locale(stored);
  }

  Future<void> setLocale(String languageCode) async {
    state = Locale(languageCode);
    await ref.read(sharedPrefsServiceProvider).setLocale(languageCode);
  }

  Future<void> toggle() async {
    final next = state.languageCode == 'id' ? 'en' : 'id';
    await setLocale(next);
  }
}

final localeProvider =
    NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);
