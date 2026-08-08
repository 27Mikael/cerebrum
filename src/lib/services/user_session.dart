import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized read/write access to locally-persisted session data.
///
/// Keeping every SharedPreferences key in ONE place avoids typos like
/// `'cerebrum_user_id'` vs `'cerebrumUserId'` scattered across the app,
/// and gives every other file a typed API instead of raw prefs calls.
///
/// Auth model: the daemon now issues a per-user **bearer token** on
/// `POST /user/login`. The token is the credential the daemon trusts (it's
/// mandatory in cloud mode, accepted in local mode too), so it lives in
/// [FlutterSecureStorage] — NOT SharedPreferences, which is plaintext on disk.
/// Non-secret display data (id, username, email) stays in SharedPreferences.
class UserSession {
  UserSession._();

  static const _keyUserId = 'cerebrum_user_id';
  static const _keyUsername = 'cerebrum_username';
  static const _keyEmail = 'cerebrum_email';
  static const _keyHasSeenOnboarding = 'cerebrum_has_seen_onboarding';

  // Secure-storage keys. The bearer token is per-account; the daemon key is a
  // per-device local-mode secret (it gates the tunnel, not a user), so it is
  // NOT cleared on logout — only on a full resetAll.
  static const _keyToken = 'cerebrum_token';
  static const _keyDaemonKey = 'daemon_api_key';
  static const _secure = FlutterSecureStorage();

  /// Persist the account + token returned by [UserApi.login] (which the
  /// signup flow also calls right after creating the account).
  static Future<void> saveSession({
    required String id,
    required String username,
    required String token,
    String? email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(_keyUserId, id),
      prefs.setString(_keyUsername, username),
      if (email != null) prefs.setString(_keyEmail, email),
    ]);
    await _secure.write(key: _keyToken, value: token);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  /// The bearer token, or null if not logged in. Read by [ApiConfig.headers].
  static Future<String?> getToken() async {
    return _secure.read(key: _keyToken);
  }

  /// The local-mode daemon key. Read by [ApiConfig.headers], set in the
  /// Connection settings panel. Empty string clears it.
  static Future<void> saveDaemonKey(String key) async {
    if (key.isEmpty) {
      await _secure.delete(key: _keyDaemonKey);
      return;
    }
    await _secure.write(key: _keyDaemonKey, value: key);
  }

  static Future<String?> getDaemonKey() async {
    return _secure.read(key: _keyDaemonKey);
  }

  /// Logged in iff we hold a token (the daemon won't accept us without one).
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasSeenOnboarding) ?? false;
  }

  static Future<void> markOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasSeenOnboarding, true);
  }

  /// Clears the account + token only -- use for "log out" / "switch account".
  /// Onboarding-seen stays true, so a logged-out user goes straight back to
  /// LoginScreen, not through onboarding again.
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_keyUserId),
      prefs.remove(_keyUsername),
      prefs.remove(_keyEmail),
    ]);
    await _secure.delete(key: _keyToken);
  }

  /// Clears the account AND the onboarding flag -- full reset for testing,
  /// so restarting the app replays onboarding -> login from scratch.
  static Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_keyUserId),
      prefs.remove(_keyUsername),
      prefs.remove(_keyEmail),
      prefs.remove(_keyHasSeenOnboarding),
    ]);
    await _secure.delete(key: _keyToken);
    await _secure.delete(key: _keyDaemonKey);
  }
}
