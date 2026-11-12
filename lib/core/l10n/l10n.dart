import 'package:flutter/widgets.dart';

import 'strings_en.dart';
import 'strings_ms.dart';

/// Lightweight localisation: Bahasa Melayu (primary) and English.
///
/// Lookups fall back to Malay, then to the key itself so a missing string is
/// visible during development instead of crashing.
class L10n {
  const L10n(this.lang);
  final String lang;

  static const supported = ['ms', 'en'];

  String t(String key, [Map<String, Object?> args = const {}]) {
    final table = lang == 'en' ? stringsEn : stringsMs;
    var s = table[key] ?? stringsMs[key] ?? key;
    args.forEach((k, v) => s = s.replaceAll('{$k}', '$v'));
    return s;
  }
}

class L10nScope extends InheritedWidget {
  const L10nScope({super.key, required this.l10n, required super.child});
  final L10n l10n;

  static L10n of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<L10nScope>()?.l10n ??
      const L10n('ms');

  @override
  bool updateShouldNotify(L10nScope oldWidget) => oldWidget.l10n.lang != l10n.lang;
}

extension TrX on BuildContext {
  String tr(String key, [Map<String, Object?> args = const {}]) =>
      L10nScope.of(this).t(key, args);
}
