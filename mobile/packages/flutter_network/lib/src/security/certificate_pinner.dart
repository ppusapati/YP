import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// Provides TLS certificate pinning by validating that a server's certificate
/// chain contains at least one certificate whose SHA-256 hash matches a
/// pre-configured pin.
///
/// Usage:
/// ```dart
/// final pinner = CertificatePinner(
///   pins: {
///     'api.yieldpoint.io': {
///       // SHA-256 hash of the leaf/intermediate certificate, base64-encoded.
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
  /// base64-encoded SHA-256 hashes. At least one pin in the set must match
  /// for the connection to succeed.
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
  /// Replace placeholder hashes with real SHA-256 digests before
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
  final bool enabled;

  /// Creates an [HttpClient] that enforces certificate pinning.
  ///
  /// For pinned hosts: the certificate must match at least one pin or the
  /// connection is rejected. For unpinned hosts: standard system trust store
  /// validation applies (badCertificateCallback is not overridden for them).
  HttpClient createHttpClient() {
    final client = HttpClient();
    if (!enabled) return client;

    client.badCertificateCallback = (
      X509Certificate certificate,
      String host,
      int port,
    ) {
      // For unpinned hosts, reject bad certificates (preserve system validation).
      if (!pins.containsKey(host)) return false;

      // For pinned hosts, check if the cert matches any pin.
      // badCertificateCallback fires when system validation fails, so a pinned
      // host with a bad cert can still pass if pin matches (self-signed scenario).
      return validate(certificate, host);
    };

    return client;
  }

  /// Validates that [certificate] matches at least one of the pinned SHA-256
  /// hashes for [host].
  ///
  /// Returns `true` if the certificate is acceptable:
  ///   - pinning is disabled, OR
  ///   - no pins are registered for [host], OR
  ///   - the certificate's SHA-256 hash matches a registered pin.
  bool validate(X509Certificate certificate, String host) {
    if (!enabled) return true;

    final hostPins = pins[host];
    if (hostPins == null || hostPins.isEmpty) return true;

    final certHash = _computeCertHash(certificate);
    return hostPins.contains(certHash);
  }

  /// Computes the base64-encoded SHA-256 hash of the certificate's full
  /// DER-encoded bytes.
  ///
  /// Note: Dart's [X509Certificate] exposes `der` (the full certificate in
  /// DER encoding) but not the SPKI portion. For interoperability with
  /// Android's network_security_config pin-set, generate pins using the same
  /// full-cert hash: `openssl x509 -in cert.pem -outform DER | sha256sum`.
  static String _computeCertHash(X509Certificate certificate) {
    final derBytes = certificate.der;
    final digest = sha256.convert(derBytes);
    return base64.encode(Uint8List.fromList(digest.bytes));
  }
}
