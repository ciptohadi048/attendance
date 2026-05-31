import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';

/// Convenience extension so widgets can call `context.l10n` instead of
/// `AppLocalizations.of(context)`.
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
