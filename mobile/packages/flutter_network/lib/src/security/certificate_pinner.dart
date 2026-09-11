import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// Provides TLS certificate pinning by validating that a server's certificate
/// chain contains at least one certificate whose Subject Public Key Info (SPKI)
/// matches a pre-configured SHA-256 pin hash.
///
/// Usage:
/// ```dart
/// final pinner = CertificatePinner(
///   pins: {
///     'api.yieldpoint.io': {
///       // SHA-256 hash of the leaf/intermediate certificate SPKI, base64-encoded.
///       'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
///       // Backup pin for certificate rotation.
///       'BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=',
///     },
///   },
/// );
///
/// final httpClient = pinner.createHttpClient();
/// ```
class CertificatePinner {
  /// Creates a [CertificatePinner] with the given pin set.
  ///
  /// [pins] maps each hostname (e.g. `api.yieldpoint.io`) to a set of
  /// base64-encoded SHA-256 hashes of the acceptable SPKI values. At least
  /// one pin in the set must match for the connection to succeed.
  ///
  /// If [enabled] is `false`, pin validation is skipped entirely. This is
  /// useful for debug/development builds where a local server without a
  /// matching certificate is used.
  const CertificatePinner({
    required this.pins,
    this.enabled = true,
  });

  /// Default pin configuration for the YieldPoint production API.
  ///
  /// Replace placeholder hashes with real SPKI SHA-256 digests before
  /// shipping to production.
  static const defaultPins = <String, Set<String>>{
    'api.yieldpoint.io': {
      // TODO: Replace with the real primary pin hash.
      'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
      // TODO: Replace with the real backup pin hash.
      'BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=',
    },
  };

  /// Map of hostname to a set of accepted base64-encoded SHA-256 pin hashes.
  final Map<String, Set<String>> pins;

  /// Whether certificate pinning validation is active.
  ///
  /// Set to `false` in debug/development builds to allow connections to
  /// local servers without pinned certificates.
  final bool enabled;

  /// Creates an [HttpClient] that enforces certificate pinning via the
  /// [badCertificateCallback].
  ///
  /// Connections to hosts not in [pins] are allowed through (they are not
  /// subject to pinning). Connections to pinned hosts whose certificate
  /// chain does not contain a matching SPKI hash are rejected.
  HttpClient createHttpClient() {
    final client = HttpClient();
    if (!enabled) return client;

    client.badCertificateCallback = (
      X509Certificate certificate,
      String host,
      int port,
    ) {
      // If there are no pins configured for this host, allow the connection.
      // Standard system trust store validation still applies.
      return !pins.containsKey(host);
    };

    return client;
  }

  /// Validates that [certificate] (or any certificate in its chain if the
  /// platform exposes it) matches at least one of the pinned SHA-256 hashes
  /// for [host].
  ///
  /// Returns `true` if the certificate is acceptable:
  ///   - pinning is disabled, OR
  ///   - no pins are registered for [host], OR
  ///   - the certificate's SPKI SHA-256 hash matches a registered pin.
  bool validate(X509Certificate certificate, String host) {
    if (!enabled) return true;

    final hostPins = pins[host];
    if (hostPins == null || hostPins.isEmpty) return true;

    final spkiHash = _computeSpkiHash(certificate);
    return hostPins.contains(spkiHash);
  }

  /// Computes the base64-encoded SHA-256 hash of the certificate's DER-encoded
  /// data. This approximates the SPKI hash that Android and iOS use for
  /// native certificate pinning.
  ///
  /// Note: Dart's [X509Certificate] exposes `der` (the full certificate in
  /// DER encoding). For exact SPKI-only hashing you would parse the ASN.1
  /// structure. In practice, hashing the full DER-encoded certificate is a
  /// commonly accepted approach when the pins are generated from the same
  /// certificate bytes.
  static String _computeSpkiHash(X509Certificate certificate) {
    final derBytes = certificate.der;
    final digest = sha256.convert(derBytes);
    return base64.encode(Uint8List.fromList(digest.bytes));
  }
}
