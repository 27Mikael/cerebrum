import 'package:flutter/foundation.dart';

enum VimMode { normal, insert }

/// Tracks whether the editor is in vim-style normal (navigation) mode or
/// insert (typing) mode. Every hjkl-style handler checks this before
/// deciding whether to intercept a keystroke or let it fall through to
/// ordinary text input — that check is the entire difference between
/// "vim-like" and "can't type the letter j".

class VimModeController extends ValueNotifier<VimMode> {
  VimModeController([VimMode initial = VimMode.normal]) : super(initial);

  bool _isEnabled = true;
  bool get isEnabled => _isEnabled;

  // Two-key sequence tracking (dd, gg, ...). AppFlowyEditor's
  // CommandShortcutEvent only matches a single key label per command —
  // it has no concept of "press this key twice". So sequences like dd/gg
  // can't be expressed as a command string ('d d' is parsed as one
  // literal, invalid, key label and crashes the keybinding lookup on
  // every keystroke). Tracking the pending first press ourselves, from
  // a CharacterShortcutEvent, is the actual way to do this.
  String? _pendingSequenceKey;
  DateTime? _pendingSequenceAt;

  void setEnabled(bool enabled) {
    if (_isEnabled == enabled) return;

    _isEnabled = enabled;

    // Optional: always return to insert mode when disabling Vim
    if (!enabled) {
      value = VimMode.insert;
    }

    notifyListeners();
  }

  bool get isNormal => _isEnabled && value == VimMode.normal;
  bool get isInsert => !_isEnabled || value == VimMode.insert;

  void enterNormalMode() {
    if (!_isEnabled) return;
    value = VimMode.normal;
  }

  void enterInsertMode() {
    value = VimMode.insert;
  }

  /// Call this every time [key] is pressed in normal mode. Returns true
  /// the *second* time the same [key] is seen within [timeout] of the
  /// first (completing a "dd"/"gg"-style sequence); returns false and
  /// records this press as the pending first key otherwise.
  ///
  /// Pressing a different key clears any pending sequence, same as vim
  /// (typing 'd' then 'k' doesn't trigger 'dd').
  bool matchSequence(
    String key, {
    Duration timeout = const Duration(milliseconds: 600),
  }) {
    final now = DateTime.now();
    if (_pendingSequenceKey == key &&
        _pendingSequenceAt != null &&
        now.difference(_pendingSequenceAt!) <= timeout) {
      _pendingSequenceKey = null;
      _pendingSequenceAt = null;
      return true;
    }
    _pendingSequenceKey = key;
    _pendingSequenceAt = now;
    return false;
  }
}
