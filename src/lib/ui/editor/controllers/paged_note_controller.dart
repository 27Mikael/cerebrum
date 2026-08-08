import 'package:flutter/foundation.dart';
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
  PagedNoteController._(this._pages);

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
        pageId: 'p0',
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
  }) {
    return NotePage(
      pageId: pageId,
      pageIndex: index,
      controller: NoteEditorController(
        driver: AppFlowyTextDriver(initialDocumentJson: document),
        initialInkJson: ink,
      ),
    );
  }

  void setActive(int index) {
    if (index < 0 || index >= _pages.length) return;
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
    final idx = _pages.length;
    _pages.add(_makePage(
      pageId: 'p${DateTime.now().microsecondsSinceEpoch}',
      index: idx,
      document: null,
      ink: null,
    ));
    _activeIndex = idx;
    notifyListeners();
  }

  void removePage(int index) {
    if (_pages.length <= 1 || index < 0 || index >= _pages.length) return;
    _pages.removeAt(index).controller.dispose();
    if (_activeIndex >= _pages.length) _activeIndex = _pages.length - 1;
    notifyListeners();
  }

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
