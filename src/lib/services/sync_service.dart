import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:cerebrum_app/api/sync_api.dart';

/// Offline-capable note sync (gap 1 / stream C) — the client half.
///
/// Uses shared_preferences (the app's only local store) for:
///   * this device's stable **replica id** — its slot in every version vector;
///   * a per-note **version vector** `{replicaId: counter}`;
///   * an **outbox** of note pushes queued while the daemon is unreachable.
///
/// On save we bump our slot, stamp the note, enqueue it, and try to push. On
/// success we adopt the server's merged vector and drop the outbox entry; on
/// failure (offline) it stays queued and [drainOutbox] retries later. The
/// server merges concurrent edits page-wise (LWW) and unions ink, so a queued
/// push can't clobber edits made elsewhere in the meantime.
///
/// SCOPE: the app has no local note database, so notes themselves still live
/// server-side — this delivers resilient, conflict-safe *pushes* (queue offline,
/// merge on reconnect), not full offline note *reading/editing*. That needs a
/// local note store (a follow-up).
class SyncService {
  static const _kReplicaId = 'cerebrum_replica_id';
  static const _kVectorPrefix = 'cerebrum_vv_'; // + noteId
  static const _kOutbox = 'cerebrum_sync_outbox';

  /// This device's stable replica id (minted once, survives restarts).
  static Future<String> replicaId() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_kReplicaId);
    if (id == null) {
      id = _mintId();
      await prefs.setString(_kReplicaId, id);
    }
    return id;
  }

  static String _mintId() {
    final now = DateTime.now().microsecondsSinceEpoch;
    return 'dev-${now.toRadixString(16)}';
  }

  static Future<Map<String, int>> _getVector(String noteId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_kVectorPrefix$noteId');
    if (raw == null) return {};
    final m = jsonDecode(raw) as Map<String, dynamic>;
    return m.map((k, v) => MapEntry(k, (v as num).toInt()));
  }

  static Future<void> _setVector(String noteId, Map<String, int> v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_kVectorPrefix$noteId', jsonEncode(v));
  }

  static Map<String, int> _asVector(Object? raw) {
    if (raw is Map) {
      return raw.map((k, v) => MapEntry(k as String, (v as num).toInt()));
    }
    return {};
  }

  /// Save a note through sync: bump our vector slot, stamp
  /// `note['metadata']['version_vector']`, enqueue, and attempt to push.
  /// Returns the server response (incl. `conflicted_pages`) on success, or
  /// null if it was queued for later (offline / hub unreachable).
  static Future<Map<String, dynamic>?> pushNote(
    String bubbleId,
    String noteId,
    Map<String, dynamic> note,
  ) async {
    final rid = await replicaId();
    final vector = await _getVector(noteId);
    vector[rid] = (vector[rid] ?? 0) + 1;

    final meta = Map<String, dynamic>.from(
      (note['metadata'] as Map?) ?? const {},
    );
    meta['version_vector'] = vector;
    note['metadata'] = meta;
    await _setVector(noteId, vector);

    await _enqueue(bubbleId, noteId, note);
    try {
      final result = await SyncApi.push(bubbleId, noteId, note);
      await _setVector(noteId, _asVector(result['server_vector']));
      await _dequeue(bubbleId, noteId);
      return result;
    } catch (_) {
      // offline / hub down — leave it queued for drainOutbox().
      return null;
    }
  }

  /// Retry every queued push (call on app start / when connectivity returns).
  static Future<void> drainOutbox() async {
    final items = await _outbox();
    for (final item in List<Map<String, dynamic>>.from(items)) {
      try {
        final result = await SyncApi.push(
          item['bubbleId'] as String,
          item['noteId'] as String,
          Map<String, dynamic>.from(item['note'] as Map),
        );
        await _setVector(item['noteId'] as String, _asVector(result['server_vector']));
        await _dequeue(item['bubbleId'] as String, item['noteId'] as String);
      } catch (_) {
        break; // still offline — keep the rest queued
      }
    }
  }

  /// How many pushes are waiting (for a "pending sync" indicator).
  static Future<int> pendingCount() async => (await _outbox()).length;

  // -- outbox (a JSON list in shared_preferences) ------------------------
  static Future<List<Map<String, dynamic>>> _outbox() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kOutbox);
    if (raw == null) return [];
    return List<Map<String, dynamic>>.from(
      (jsonDecode(raw) as List).map((e) => Map<String, dynamic>.from(e as Map)),
    );
  }

  static Future<void> _saveOutbox(List<Map<String, dynamic>> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kOutbox, jsonEncode(items));
  }

  static Future<void> _enqueue(
    String bubbleId,
    String noteId,
    Map<String, dynamic> note,
  ) async {
    final items = await _outbox();
    // one pending push per note — replace any earlier queued version
    items.removeWhere((i) => i['bubbleId'] == bubbleId && i['noteId'] == noteId);
    items.add({'bubbleId': bubbleId, 'noteId': noteId, 'note': note});
    await _saveOutbox(items);
  }

  static Future<void> _dequeue(String bubbleId, String noteId) async {
    final items = await _outbox();
    items.removeWhere((i) => i['bubbleId'] == bubbleId && i['noteId'] == noteId);
    await _saveOutbox(items);
  }
}
