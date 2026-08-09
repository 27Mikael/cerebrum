import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:scribble/scribble.dart';
import 'package:cerebrum_app/ui/editor/controllers/appflowy_text_driver.dart';
import 'package:cerebrum_app/ui/editor/controllers/note_editor_controller.dart';
import 'package:cerebrum_app/ui/editor/controllers/page_paginator.dart'
    as paginator;

/// Vertical continuous scroll (default, document feel) vs horizontal PageView
/// (slideshow). Both render the same page widget — see PagedEditor.
enum PageLayoutMode { vertical, horizontal }

/// One page's identity + editing state. Reuses [NoteEditorController] (one
/// AppFlowy document + one ink layer) unchanged — a page IS a single-surface
/// note, so nothing about that class had to move.
class NotePage {
  NotePage({
    required this.pageId,
    required this.pageIndex,
    required this.controller,
  });

  final String pageId;
  final int pageIndex;
  final NoteEditorController controller;
}

/// A note as an ORDERED LIST OF PAGES (Xournal / Samsung Notes style): each
/// page is its own text+ink surface, content does NOT flow between pages, and
/// pages are added explicitly. Maps 1:1 to the daemon's `NoteStorage.pages`.
///
/// UNVERIFIED (no flutter tooling in the build env) — run `flutter analyze`.
class PagedNoteController extends ChangeNotifier {
  PagedNoteController._(this._pages) {
    for (final p in _pages) {
      _initPage(p);
    }
  }

  /// Debounce timer for the live reflow trigger — coalesces a burst of edits
  /// into a single repagination once typing settles (see [_scheduleReflow]).
  Timer? _reflowTimer;

  /// True while [repaginate] is tearing down / rebuilding page controllers, so
  /// the edit notifications that rebuild fires don't schedule another reflow
  /// (which would thrash / recurse).
  bool _suppressReflow = false;

  /// How long typing must settle before a live reflow fires. Long enough that
  /// it lands in a pause rather than between two keystrokes; short enough that
  /// a page visibly reflows "as you type," not on some distant delay.
  static const Duration _reflowDebounce = Duration(milliseconds: 450);

  /// The drawing tool (pen colour+width / highlighter / eraser) currently
  /// selected on the single screen-level dial, expressed as a mutation applied
  /// to a page's ink notifier. Null until the user first picks a tool. Stored so
  /// the selection FOLLOWS across pages: it's broadcast to every page on pick
  /// (see [applyDrawingTool]) and applied to any page created afterwards (see
  /// [_initPage]). Undo/redo are NOT tools — they act on the active page only.
  void Function(ScribbleNotifier)? _activeTool;

  /// Select a drawing tool from the dial: remember it and apply it to EVERY
  /// page's ink notifier, so drawing on any page uses it immediately (no
  /// dependence on which page is active, and no pointer-dispatch ordering race).
  void applyDrawingTool(void Function(ScribbleNotifier) config) {
    _activeTool = config;
    for (final p in _pages) {
      config(p.controller.drawingNotifier);
    }
  }

  /// Wire everything a freshly created page needs: the backspace-at-start merge
  /// and the live-reflow edit trigger. Reused pages (kept as-is across a reflow)
  /// are NOT passed through here — their wiring already stands, and re-adding
  /// the reflow listener would fire it twice per edit.
  void _initPage(NotePage page) {
    _wireMerge(page);
    // Any edit on any page schedules a (debounced, no-op-unless-structure-
    // changes) reflow. Editing happens on the focused page, but listening to
    // all of them keeps this correct regardless of which page has focus.
    page.controller.addListener(_scheduleReflow);
    // A page created after a tool was picked inherits it, so the pen/highlighter
    // /eraser stays consistent on brand-new and reflow-rebuilt pages alike.
    _activeTool?.call(page.controller.drawingNotifier);
  }

  /// Schedule a debounced live repagination. Cheap when nothing overflowed:
  /// [repaginate] bails via `_samePageBlocks` without rebuilding anything.
  void _scheduleReflow() {
    if (_suppressReflow) return;
    _reflowTimer?.cancel();
    _reflowTimer = Timer(_reflowDebounce, () {
      _reflowTimer = null;
      repaginate();
    });
  }

  /// Wire a page's backspace-at-start to merge it into the previous page. The
  /// closure looks the page's index up by identity at call time, so it stays
  /// correct as pages are added/removed/merged.
  void _wireMerge(NotePage page) {
    final driver = page.controller.driver;
    if (driver is AppFlowyTextDriver) {
      driver.onBackspaceAtStart = () {
        final idx = _pages.indexOf(page);
        if (idx <= 0) return false; // first page (or gone): default backspace
        mergePageIntoPrevious(idx);
        return true;
      };
    }
  }

  final List<NotePage> _pages;
  int _activeIndex = 0;
  bool _drawingEnabled = false;
  PageLayoutMode _layout = PageLayoutMode.vertical;

  List<NotePage> get pages => List.unmodifiable(_pages);
  int get activeIndex => _activeIndex;
  bool get drawingEnabled => _drawingEnabled;
  PageLayoutMode get layout => _layout;
  NoteEditorController get activeController => _pages[_activeIndex].controller;

  /// Build from `NoteStorage.pages`; falls back to a single page synthesised
  /// from the legacy `{document, ink}` shape when the note has no pages yet.
  factory PagedNoteController.fromNote({
    List<Map<String, dynamic>>? pages,
    Map<String, dynamic>? legacyDocument,
    List<Map<String, dynamic>>? legacyInk,
  }) {
    final built = <NotePage>[];
    if (pages != null && pages.isNotEmpty) {
      for (var i = 0; i < pages.length; i++) {
        final p = pages[i];
        built.add(_makePage(
          pageId: (p['page_id'] as String?) ?? 'p$i',
          index: (p['page_index'] as num?)?.toInt() ?? i,
          document: p['document'] as Map<String, dynamic>?,
          ink: _inkOf(p['ink']),
        ));
      }
    } else {
      built.add(_makePage(
        pageId: 'p1', // matches the daemon's synthesised first-page id
        index: 0,
        document: legacyDocument,
        ink: legacyInk,
      ));
    }
    built.sort((a, b) => a.pageIndex.compareTo(b.pageIndex));
    return PagedNoteController._(built);
  }

  static List<Map<String, dynamic>>? _inkOf(Object? raw) => raw is List
      ? raw.map((e) => Map<String, dynamic>.from(e as Map)).toList()
      : null;

  static NotePage _makePage({
    required String pageId,
    required int index,
    Map<String, dynamic>? document,
    List<Map<String, dynamic>>? ink,
    int? caretBlockIndex,
    int? caretOffset,
    bool autoFocus = false,
  }) {
    return NotePage(
      pageId: pageId,
      pageIndex: index,
      controller: NoteEditorController(
        driver: AppFlowyTextDriver(
          initialDocumentJson: document,
          initialCaretBlockIndex: caretBlockIndex,
          initialCaretOffset: caretOffset,
          autoFocus: autoFocus,
        ),
        initialInkJson: ink,
      ),
    );
  }

  void setActive(int index) {
    if (index < 0 || index >= _pages.length || index == _activeIndex) return;
    _activeIndex = index;
    notifyListeners();
  }

  /// Global draw/text toggle — applies to whichever page you're on.
  void toggleDrawingMode() {
    _drawingEnabled = !_drawingEnabled;
    notifyListeners();
  }

  void setLayout(PageLayoutMode mode) {
    _layout = mode;
    notifyListeners();
  }

  void toggleLayout() => setLayout(
        _layout == PageLayoutMode.vertical
            ? PageLayoutMode.horizontal
            : PageLayoutMode.vertical,
      );

  void addPage() {
    // Simple sequential ids (p1, p2, …). Use max-existing+1 so a delete then
    // add can't collide with a surviving page's id.
    var maxNum = 0;
    for (final p in _pages) {
      final m = RegExp(r'^p(\d+)$').firstMatch(p.pageId);
      if (m != null) {
        final n = int.parse(m.group(1)!);
        if (n > maxNum) maxNum = n;
      }
    }
    final idx = _pages.length;
    final page = _makePage(
      pageId: 'p${maxNum + 1}',
      index: idx,
      document: null,
      ink: null,
    );
    _pages.add(page);
    _initPage(page);
    _activeIndex = idx;
    notifyListeners();
  }

  void removePage(int index) {
    if (_pages.length <= 1 || index < 0 || index >= _pages.length) return;
    _pages.removeAt(index).controller.dispose();
    if (_activeIndex >= _pages.length) _activeIndex = _pages.length - 1;
    notifyListeners();
  }

  /// Backspace at the very start of page [index] pulls only its TYPED CONTENT up
  /// into the end of the previous page. Text and ink are separate layers:
  ///
  ///   * text (the document blocks) moves up to the previous page; the caret
  ///     lands at the seam;
  ///   * ink NEVER moves — strokes are page-local and only the ink tools (eraser)
  ///     may remove them;
  ///   * the emptied page is removed ONLY if it has no ink. If it still holds
  ///     ink, the page stays (now text-empty) so backspace can't destroy ink.
  void mergePageIntoPrevious(int index) {
    if (index <= 0 || index >= _pages.length) return;
    final prev = _pages[index - 1];
    final cur = _pages[index];

    final prevDoc = Map<String, dynamic>.from(prev.controller.documentJson);
    final curDoc = cur.controller.documentJson;
    final prevChildren = List<Map<String, dynamic>>.from(
      (prevDoc['children'] as List?) ?? const [],
    );
    final curChildren = List<Map<String, dynamic>>.from(
      (curDoc['children'] as List?) ?? const [],
    );

    // Drop a single trailing empty paragraph on the previous page so the seam
    // isn't a stray blank line (pages often end on an empty block).
    if (prevChildren.length > 1 && _isEmptyParagraph(prevChildren.last)) {
      prevChildren.removeLast();
    }
    final seamIndex = prevChildren.length; // caret lands at first merged block
    final mergedDoc = {
      ...prevDoc,
      'children': [...prevChildren, ...curChildren],
    };

    // Rebuild the PREVIOUS page with the merged text. Its OWN ink is passed back
    // through untouched — ink is never combined across pages.
    final newPrev = _makePage(
      pageId: prev.pageId,
      index: index - 1,
      document: mergedDoc,
      ink: prev.controller.inkJson,
      caretBlockIndex: seamIndex,
      autoFocus: true,
    );
    prev.controller.dispose();
    _pages[index - 1] = newPrev;
    _initPage(newPrev);

    if (_pageHasInk(cur)) {
      // Ink stays page-local: keep this page, just clear its now-moved text.
      final emptied = _makePage(
        pageId: cur.pageId,
        index: index,
        document: _emptyDoc(),
        ink: cur.controller.inkJson,
      );
      cur.controller.dispose();
      _pages[index] = emptied;
      _initPage(emptied);
    } else {
      // No ink → nothing left on the page, so the page break is removed.
      cur.controller.dispose();
      _pages.removeAt(index);
    }

    _activeIndex = index - 1;
    notifyListeners();

    // A merge just concatenates the pulled-up content onto the previous page
    // WITHOUT respecting the line budget — so if that page now overflows (most
    // visibly when a whole table is pulled up), its fixed-height sheet would go
    // scrollable. Reflow to push the overflow back onto following pages (an
    // atomic too-tall table lands on its own page). No-ops when it already fits,
    // and preserves the caret just seeded at the seam.
    repaginate();
  }

  /// Continuous pagination: reflow every page's text so no page exceeds the
  /// line budget, splitting blocks that span a boundary (see page_paginator).
  /// Rebuilds only when the block distribution actually changes, and only the
  /// pages that changed — an untouched prefix of pages is kept as-is, so their
  /// live editor state (caret, undo, scroll) survives.
  ///
  /// Caret hand-off: before reflowing, the active page's caret is snapshotted as
  /// a GLOBAL character offset over the flattened block stream — an anchor that
  /// survives splitting because [paginator.paginate] conserves that text exactly.
  /// After reflow it's mapped back to whichever (page, block, offset) now holds
  /// that character, and re-seeded there with focus. If the caret can't be
  /// resolved (no selection, or it's inside a table cell), the reflow still runs;
  /// only the caret restore is skipped.
  ///
  /// Ink is page-LOCAL and stays with its page INDEX (page 0 keeps page 0's
  /// strokes, etc.); pages added by the reflow get empty ink.
  ///
  /// Fires both from the Reflow button and, debounced, live while typing (see
  /// [_scheduleReflow]). Reentrancy while it rebuilds controllers is guarded by
  /// [_suppressReflow].
  void repaginate({int budget = paginator.kLineBudget, bool preserveCaret = true}) {
    if (_suppressReflow) return;
    final current = <List<paginator.Block>>[
      for (final p in _pages)
        List<paginator.Block>.from(
          (p.controller.documentJson['children'] as List?) ?? const [],
        ),
    ];
    final paged = paginator.paginate(current, budget: budget);
    if (_samePageBlocks(current, paged)) return; // no structural change

    // Snapshot the caret (against the pre-reflow layout) and find where that
    // same character lands in the post-reflow layout.
    final globalCaret =
        preserveCaret ? _captureGlobalCaret(current) : null;
    final target =
        globalCaret == null ? null : _locateCaret(paged, globalCaret);

    final oldInk = [for (final p in _pages) p.controller.inkJson];
    final oldIds = [for (final p in _pages) p.pageId];
    var nextIdNum = _maxPageIdNum() + 1;

    _suppressReflow = true;
    final rebuilt = <NotePage>[];
    final kept = <NotePage>{};
    for (var i = 0; i < paged.length; i++) {
      // Reuse an existing page verbatim when its blocks are byte-identical at
      // the same index (the unchanged prefix before the overflow point). The
      // caret page is only rebuilt when its content actually changed — if it's
      // reused, the live caret is already right where it should be.
      final reusable = i < _pages.length &&
          jsonEncode(current[i]) == jsonEncode(paged[i]);
      if (reusable) {
        kept.add(_pages[i]);
        rebuilt.add(_pages[i]);
        continue;
      }
      final onCaretPage = target != null && target.pageIndex == i;
      rebuilt.add(_makePage(
        pageId: i < oldIds.length ? oldIds[i] : 'p${nextIdNum++}',
        index: i,
        document: {'type': 'page', 'children': paged[i]},
        ink: i < oldInk.length ? oldInk[i] : null, // ink stays by page index
        caretBlockIndex: onCaretPage ? target.blockIndex : null,
        caretOffset: onCaretPage ? target.offset : null,
        autoFocus: onCaretPage,
      ));
    }

    // Dispose only the pages we're actually replacing; kept pages carry on.
    for (final p in _pages) {
      if (!kept.contains(p)) p.controller.dispose();
    }
    _pages
      ..clear()
      ..addAll(rebuilt);
    // Wire only the freshly created pages; kept pages are already wired (and
    // re-wiring would double their reflow listener).
    for (final p in _pages) {
      if (!kept.contains(p)) _initPage(p);
    }
    _activeIndex = target?.pageIndex ??
        (_activeIndex >= _pages.length ? _pages.length - 1 : _activeIndex);
    _suppressReflow = false;
    notifyListeners();
  }

  /// The active page's caret as a global character offset over the flattened
  /// block stream of [pages] (the pre-reflow per-page block lists). Returns null
  /// if there's no collapsed caret or it's nested (e.g. inside a table cell),
  /// in which case the caller skips the caret restore.
  int? _captureGlobalCaret(List<List<paginator.Block>> pages) {
    final driver = _pages[_activeIndex].controller.driver;
    if (driver is! AppFlowyTextDriver) return null;
    final caret = driver.caret;
    if (caret == null || caret.path.length != 1) return null;
    final blockIdx = caret.path.first;

    var total = 0;
    for (var p = 0; p < _activeIndex && p < pages.length; p++) {
      for (final b in pages[p]) {
        total += paginator.blockPlainText(b).length;
      }
    }
    final active = _activeIndex < pages.length ? pages[_activeIndex] : const [];
    for (var b = 0; b < blockIdx && b < active.length; b++) {
      total += paginator.blockPlainText(active[b]).length;
    }
    return total + caret.offset;
  }

  /// Map a global character offset (from [_captureGlobalCaret]) to a concrete
  /// caret target in the post-reflow [paged] layout. Lands at the END of the
  /// first block that contains the offset — so a caret sitting at a block
  /// boundary stays with the text just typed, not the start of the next block.
  _CaretTarget? _locateCaret(List<List<paginator.Block>> paged, int globalCaret) {
    var remaining = globalCaret;
    _CaretTarget? last;
    for (var p = 0; p < paged.length; p++) {
      for (var b = 0; b < paged[p].length; b++) {
        final len = paginator.blockPlainText(paged[p][b]).length;
        last = _CaretTarget(p, b, len);
        if (remaining <= len) return _CaretTarget(p, b, remaining);
        remaining -= len;
      }
    }
    // Ran past the end (shouldn't happen — text is conserved). Land at the very
    // end of the last block rather than losing the caret.
    return last;
  }

  int _maxPageIdNum() {
    var maxNum = 0;
    for (final p in _pages) {
      final m = RegExp(r'^p(\d+)$').firstMatch(p.pageId);
      if (m != null) {
        final n = int.parse(m.group(1)!);
        if (n > maxNum) maxNum = n;
      }
    }
    return maxNum;
  }

  static bool _samePageBlocks(
    List<List<paginator.Block>> a,
    List<List<paginator.Block>> b,
  ) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (jsonEncode(a[i]) != jsonEncode(b[i])) return false;
    }
    return true;
  }

  static bool _isEmptyParagraph(Map<String, dynamic> block) {
    if (block['type'] != 'paragraph') return false;
    final delta = (block['data'] as Map?)?['delta'];
    if (delta is! List || delta.isEmpty) return true;
    final text = delta
        .whereType<Map>()
        .map((e) => (e['insert'] ?? '').toString())
        .join();
    return text.isEmpty;
  }

  /// True if the page has any ink strokes. `inkJson` is a single-element list
  /// holding one `Sketch.toJson()` (`{lines: [...]}`).
  static bool _pageHasInk(NotePage page) {
    final ink = page.controller.inkJson;
    if (ink.isEmpty) return false;
    final lines = (ink.first['lines'] as List?) ?? const [];
    return lines.isNotEmpty;
  }

  static Map<String, dynamic> _emptyDoc() => {
        'type': 'page',
        'children': [
          {
            'type': 'paragraph',
            'data': {
              'delta': [
                {'insert': ''},
              ],
            },
          },
        ],
      };

  /// Serialise to the `NoteStorage.pages` shape for save/sync.
  List<Map<String, dynamic>> toPagesJson() => [
        for (var i = 0; i < _pages.length; i++)
          {
            'page_id': _pages[i].pageId,
            'page_index': i,
            'document': _pages[i].controller.documentJson,
            'ink': _pages[i].controller.inkJson,
          }
      ];

  @override
  void dispose() {
    _reflowTimer?.cancel();
    for (final p in _pages) {
      p.controller.dispose();
    }
    super.dispose();
  }
}

/// Where a snapshotted caret should land after a reflow: the [blockIndex]-th
/// block on page [pageIndex], at character [offset] within it.
class _CaretTarget {
  const _CaretTarget(this.pageIndex, this.blockIndex, this.offset);

  final int pageIndex;
  final int blockIndex;
  final int offset;
}
