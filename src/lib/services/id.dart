import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Client-minted, lexicographically-sortable ids (ULID) — offline-first plan,
/// phase 4.
///
/// A note gets its identity the moment it's created **locally**, before the
/// daemon ever sees it, so `createNote` becomes "the first push of a note that
/// already exists" rather than the thing that mints identity. ULIDs sort by
/// creation time, which keeps the on-device notes index naturally ordered and
/// makes ids collision-safe across devices without a server round-trip.
///
/// Format: 26 chars of Crockford base32 — 10 for a 48-bit millisecond timestamp
/// (most-significant first) + 16 of randomness.
class Ulid {
  static const _crockford = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';
  static final _rng = Random.secure();

  static String generate() {
    var ts = DateTime.now().millisecondsSinceEpoch;
    final chars = List<String>.filled(26, '0');
    for (var i = 9; i >= 0; i--) {
      chars[i] = _crockford[ts & 0x1f];
      ts >>= 5;
    }
    for (var i = 10; i < 26; i++) {
      chars[i] = _crockford[_rng.nextInt(32)];
    }
    return chars.join();
  }
}

/// Deterministic **bubble** id: md5 hex of the bubble name. Mirrors the daemon's
/// fallback (`hashlib.md5(name.encode()).hexdigest()`) so a client-minted id and
/// the server agree on the same folder, and it's kept md5 (32-char hex) on
/// purpose — visually distinct from the ULID note ids. The name must be the
/// exact string sent as the bubble's `name`, or the hashes won't match.
String bubbleIdFromName(String name) =>
    md5.convert(utf8.encode(name)).toString();

/// A client-minted **engram attempt** id, matching the daemon's `_nanoid()`
/// (`uuid.uuid4().hex`) shape: 32 lowercase hex chars. Sharing the id space lets
/// the client own attempt identity — a queued offline submit replayed on
/// reconnect carries the same id, so the daemon dedupes it instead of recording
/// a duplicate attempt.
String nanoid() {
  final rng = Random.secure();
  final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}
