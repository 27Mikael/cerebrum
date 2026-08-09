import 'package:flutter/foundation.dart';
import 'package:scribble/scribble.dart';
import 'package:cerebrum_app/ui/editor/controllers/appflowy_text_driver.dart';
import 'package:cerebrum_app/ui/editor/controllers/note_editor_controller.dart';

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

  /// Uploads a picked image and returns the URL to embed. Set by the note
  /// context (EditorScaffold, which knows the bubble + note). Stored so it can
  /// be applied to every page's driver — including pages created later — so the
  /// "/image" slash item works on any page.
  Future<String?> Function(List<int> bytes, String filename)? _imageUploader;

  set imageUploader(
    Future<String?> Function(List<int> bytes, String filename)? uploader,
  ) {
    _imageUploader = uploader;
    for (final p in _pages) {
      final driver = p.controller.driver;
      if (driver is AppFlowyTextDriver) driver.imageUploader = uploader;
    }
  }

  /// Wire everything a freshly created page needs: the backspace-at-start merge
  /// and the live-reflow edit trigger. Reused pages (kept as-is across a reflow)
  /// are NOT passed through here — their wiring already stands, and re-adding
  /// the reflow listener would fire it twice per edit.
  void _initPage(NotePage page) {
    _wireMerge(page);
    // A page created after a tool was picked inherits it, so the pen/highlighter
    // /eraser stays consistent on brand-new pages.
    _activeTool?.call(page.controller.drawingNotifier);
    // New pages get the image uploader too, so "/image" works on any page.
    final driver = page.controller.driver;
    if (driver is AppFlowyTextDriver) driver.imageUploader = _imageUploader;
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

  /// Next free `p{n}` id: max existing + 1, so a delete-then-add can't collide
  /// with a surviving page's id.
  String _nextPageId() {
    var maxNum = 0;
    for (final p in _pages) {
      final m = RegExp(r'^p(\d+)$').firstMatch(p.pageId);
      if (m != null) {
        final n = int.parse(m.group(1)!);
        if (n > maxNum) maxNum = n;
      }
    }
    return 'p${maxNum + 1}';
  }

  void addPage() {
    final idx = _pages.length;
    final page = _makePage(
      pageId: _nextPageId(),
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

  /// True while [pushOverflow] is rebuilding pages, so an overflow report that
  /// arrives mid-rebuild is ignored rather than recursing.
  bool _flowing = false;

  /// Forward-only overflow flow: the blocks from [fromBlockIndex] onward on page
  /// [pageIndex] no longer fit the sheet, so move them to the FRONT of the next
  /// page (creating one if this is the last page) and carry the caret with them
  /// so typing continues there. Whole blocks move (never split), so the caret's
  /// (block, offset) maps directly — the moved block's new index is simply
  /// `oldIndex - fromBlockIndex`.
  ///
  /// Existing pages are NOT reflowed; content only ever moves DOWN, so this
  /// terminates and never churns page ids upward the way the old continuous
  /// pagination did. Reported by PageSurface, which measures the actual rendered
  /// block positions against the sheet.
  void pushOverflow(int pageIndex, int fromBlockIndex) {
    if (_flowing || pageIndex < 0 || pageIndex >= _pages.length) return;
    final page = _pages[pageIndex];
    final children = List<Map<String, dynamic>>.from(
      (page.controller.documentJson['children'] as List?) ?? const [],
    );
    // Keep at least one block on this page (fromBlockIndex >= 1); a single block
    // taller than a whole sheet can't be helped without splitting, so leave it.
    //
    // TODO(tables): follow-up — a TABLE taller than a whole sheet therefore
    // overflows its own page (we only ever move whole blocks; nothing splits).
    // Options when we want to handle it: (a) reinstate the verified row-splitter
    // (`_splitTable` in the deleted page_paginator.dart — see git history) as a
    // targeted case here, splitting only an oversized table across the boundary;
    // or (b) shrink / internally scroll a too-tall table within its sheet. Until
    // then, oversized tables are left whole and overflow.
    if (fromBlockIndex < 1 || fromBlockIndex >= children.length) return;

    _flowing = true;

    final kept = children.sublist(0, fromBlockIndex);
    final moved = children.sublist(fromBlockIndex);

    // If the caret is on this page in a moved block, it travels to the next page.
    int? caretBlock;
    int? caretOffset;
    final driver = page.controller.driver;
    if (_activeIndex == pageIndex && driver is AppFlowyTextDriver) {
      final caret = driver.caret;
      if (caret != null &&
          caret.path.length == 1 &&
          caret.path.first >= fromBlockIndex) {
        caretBlock = caret.path.first - fromBlockIndex; // index within `moved`
        caretOffset = caret.offset;
      }
    }

    // Rebuild this page with just the kept blocks (its ink stays).
    final trimmed = _makePage(
      pageId: page.pageId,
      index: pageIndex,
      document: {'type': 'page', 'children': kept},
      ink: page.controller.inkJson,
    );
    page.controller.dispose();
    _pages[pageIndex] = trimmed;
    _initPage(trimmed);

    if (pageIndex + 1 < _pages.length) {
      // Prepend the moved blocks to the existing next page (may cascade — that
      // page will report its own overflow next frame if it now doesn't fit).
      final next = _pages[pageIndex + 1];
      final nextChildren = List<Map<String, dynamic>>.from(
        (next.controller.documentJson['children'] as List?) ?? const [],
      );
      final rebuiltNext = _makePage(
        pageId: next.pageId,
        index: pageIndex + 1,
        document: {'type': 'page', 'children': [...moved, ...nextChildren]},
        ink: next.controller.inkJson,
        caretBlockIndex: caretBlock,
        caretOffset: caretOffset,
        autoFocus: caretBlock != null,
      );
      next.controller.dispose();
      _pages[pageIndex + 1] = rebuiltNext;
      _initPage(rebuiltNext);
    } else {
      // Last page overflowed → spill onto a fresh page.
      final created = _makePage(
        pageId: _nextPageId(),
        index: pageIndex + 1,
        document: {'type': 'page', 'children': moved},
        ink: null,
        caretBlockIndex: caretBlock,
        caretOffset: caretOffset,
        autoFocus: caretBlock != null,
      );
      _pages.add(created);
      _initPage(created);
    }

    if (caretBlock != null) _activeIndex = pageIndex + 1;
    _flowing = false;
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
    for (final p in _pages) {
      p.controller.dispose();
    }
    super.dispose();
  }
}
