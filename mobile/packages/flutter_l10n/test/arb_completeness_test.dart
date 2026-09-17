import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Every locale carries every key.
///
/// `flutter gen-l10n` only *warns* about untranslated messages, and a warning
/// in a build log is a warning nobody reads. A key present in the template and
/// missing from a translation silently falls back to English, so the app ships
/// looking translated and reads half in English for that screen — which is the
/// shape of bug that survives review because nobody reviewing speaks the
/// language.
void main() {
  final dir = Directory('lib/l10n');
  final arbs = dir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.arb'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  Map<String, dynamic> read(File f) =>
      json.decode(f.readAsStringSync()) as Map<String, dynamic>;

  Set<String> keysOf(Map<String, dynamic> arb) =>
      arb.keys.where((k) => !k.startsWith('@')).toSet();

  test('there is a template and at least one translation', () {
    expect(arbs.length, greaterThan(1),
        reason: 'lib/l10n should hold app_en.arb and one file per locale');
  });

  final template = arbs.firstWhere((f) => f.path.endsWith('app_en.arb'));
  final templateKeys = keysOf(read(template));

  for (final arb in arbs) {
    final name = arb.uri.pathSegments.last;

    test('$name declares its locale', () {
      final locale = read(arb)['@@locale'];
      expect(locale, isNotNull, reason: '$name has no @@locale');
      expect(name, equals('app_$locale.arb'),
          reason: '$name declares @@locale "$locale", which does not match its filename');
    });

    test('$name has every key the template has', () {
      final keys = keysOf(read(arb));
      final missing = templateKeys.difference(keys).toList()..sort();
      expect(missing, isEmpty,
          reason: '$name is missing ${missing.length} key(s): '
              '${missing.take(10).join(', ')}');
    });

    test('$name has no key the template lacks', () {
      final keys = keysOf(read(arb));
      final extra = keys.difference(templateKeys).toList()..sort();
      // An extra key is a key nothing reads — usually a rename applied to one
      // file and not the others, which leaves the old name behind translated.
      expect(extra, isEmpty,
          reason: '$name has ${extra.length} key(s) the template does not: '
              '${extra.take(10).join(', ')}');
    });

    test('$name keeps every placeholder', () {
      final source = read(template);
      final target = read(arb);
      final placeholder = RegExp(r'\{(\w+)\}');

      for (final key in templateKeys) {
        final from = placeholder
            .allMatches(source[key] as String)
            .map((m) => m.group(1)!)
            .toSet();
        if (from.isEmpty) continue;
        final to = placeholder
            .allMatches(target[key] as String? ?? '')
            .map((m) => m.group(1)!)
            .toSet();
        // A dropped placeholder is not cosmetic: gen-l10n generates the method
        // signature from the template, so the argument is passed and never
        // appears — "at least characters required" with the number gone.
        expect(to, equals(from),
            reason: '$name: "$key" should interpolate $from but interpolates $to');
      }
    });
  }
}
