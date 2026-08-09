import 'dart:async';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:cerebrum_app/ui/editor/helpers/editor_commands.dart';
import 'package:cerebrum_app/ui/editor/controllers/vim_move_controller.dart';
import 'package:cerebrum_app/ui/editor/controllers/text_editing_driver.dart';
// NEW: the proper code block builder (syntax highlighting, language
// switcher, copy button) — path assumes you saved it at
// features/editor/blocks/code_block/code_block_component.dart; adjust
// to wherever you actually put the file.
import 'package:cerebrum_app/ui/editor/blocks/code_block/code_block_component.dart';

/// AppFlowy-backed [TextEditingDriver]. This is the only file that should
/// import `appflowy_editor` — everything above it (NoteEditorController,
/// EditorSurface, EditorScaffold) works against the interface, not this.
class AppFlowyTextDriver extends ChangeNotifier
    implements TextEditingDriver, VimModeAware {
  AppFlowyTextDriver({
    Map<String, dynamic>? initialDocumentJson,
    int? initialCaretBlockIndex,
    int? initialCaretOffset,
    bool autoFocus = false,
  }) {
    _autoFocus = autoFocus;
    _editorState = _buildEditorState(
      initialDocumentJson,
      initialCaretBlockIndex,
      initialCaretOffset,
    );
    // shrinkWrap: true → AppFlowyEditor lays the document out as a Column with
    // NO internal scroll view. Required when the editor is embedded inside
    // another scrollable (the paged editor stacks one editor per page inside a
    // ListView): a default (non-shrinkWrap) controller builds a
    // ScrollablePositionedList whose selection service can't find its
    // EditorScrollController provider once nested — the
    // "Could not find the correct Provider<EditorScrollController>" crash seen
    // on multi-page notes. Built once and reused across every buildEditor call.
    _scrollController = EditorScrollController(
      editorState: _editorState,
      shrinkWrap: true,
    );
    _transactionSub = _editorState.transactionStream.listen(
      (_) => notifyListeners(),
    );
    // NOTE: deliberately NOT `vimMode.addListener(notifyListeners)` here.
    // EditorSurface's mode badge already listens to `vimMode` directly
    // (its own narrowly-scoped AnimatedBuilder), so forwarding vimMode
    // changes into this driver's notifyListeners was redundant — and
    // actively harmful: it fired a full-stack rebuild (recreating
    // AppFlowyEditor via EditorSurface's outer AnimatedBuilder, plus a
    // whole-scaffold setState via EditorScaffold._onEditorChanged) at
    // the exact moment vim mode changes, e.g. right when 'i' switches
    // normal -> insert. That rebuild landing right on top of the very
    // next keystroke's own transaction-triggered rebuild is what was
    // dropping the caret and eating the following keystroke — plain
    // click-to-focus typing never touches vimMode, so it never hit this
    // double-rebuild collision. It also meant toggling modes alone (no
    // actual edit) was incorrectly marking the note as having unsaved
    // changes via EditorScaffold's autosave scheduling.
  }

  late final EditorState _editorState;
  late final EditorScrollController _scrollController;
  late final StreamSubscription<dynamic> _transactionSub;
  bool _autoFocus = false;

  /// Called when Backspace is pressed with the caret at the VERY START of this
  /// page's first block. Set by [PagedNoteController] to merge the page up into
  /// the previous one. Returns true if it handled the key (so the editor's own
  /// backspace is suppressed), false to let the default backspace run (e.g. this
  /// is already the first page). Null when the note isn't paged.
  bool Function()? onBackspaceAtStart;

  /// The current collapsed caret as `(path, offset)`, or null when there's no
  /// selection or it's a range. `path` is the block path (length 1 for a
  /// top-level block; longer when nested, e.g. inside a table cell). Used by
  /// [PagedNoteController] to snapshot the caret before a reflow so it can be
  /// re-seeded afterwards.
  ({List<int> path, int offset})? get caret {
    final sel = _editorState.selection;
    if (sel == null || !sel.isCollapsed) return null;
    return (path: List<int>.from(sel.start.path), offset: sel.start.offset);
  }

  // Built ONCE and reused across every `buildEditor` call, rather than
  // being reconstructed from scratch on every rebuild.
  //
  // Every transaction — a typed character, a cursor move, anything —
  // runs through `_editorState.transactionStream.listen((_) =>
  // notifyListeners())` above, which (via NoteEditorController ->
  // EditorSurface's AnimatedBuilder) rebuilds this widget and calls
  // `buildEditor` again. If `commandShortcutEvents`/
  // `characterShortcutEvents` were rebuilt inline in `buildEditor` (as
  // `...EditorShortcuts.getCustomShortcuts(vimMode)` etc., which is what
  // this used to do), every single keystroke would hand AppFlowyEditor
  // a brand-new List of brand-new shortcut objects — same content, but
  // different identity every time. AppFlowyEditor uses these lists to
  // decide whether its internal keyboard/selection-overlay service
  // needs to reinitialize, so a "different" list on every keystroke
  // made it tear down and rebuild that service constantly, which is
  // what was dropping the caret after every character typed or every
  // normal-mode navigation move (both are transactions, so both hit
  // this path identically). Caching these once means AppFlowyEditor
  // sees the *same* lists across rebuilds and has no reason to
  // reinitialize anything.
  late final List<CommandShortcutEvent> _commandShortcutEvents = [
    // FIRST: intercept backspace-at-page-start so it merges into the previous
    // page instead of doing nothing. Returns ignored in every other case, so
    // normal backspace (and the vim/standard handlers below) run untouched.
    _mergeToPreviousPageOnBackspace(),
    ...EditorShortcuts.getCustomShortcuts(vimMode),
    ...standardCommandShortcutEvents,
  ];

  CommandShortcutEvent _mergeToPreviousPageOnBackspace() {
    return CommandShortcutEvent(
      key: 'merge into previous page on backspace at start',
      getDescription:
          () =>
              'Backspace at the very start of a page merges it into the previous page',
      command: 'backspace',
      handler: (editorState) {
        final handler = onBackspaceAtStart;
        if (handler == null) return KeyEventResult.ignored;
        final sel = editorState.selection;
        if (sel == null || !sel.isCollapsed) return KeyEventResult.ignored;
        if (sel.start.offset != 0) return KeyEventResult.ignored;
        // Only the caret at offset 0 of the FIRST top-level block (path [0]).
        // TODO(tables): when that first block is a table this still fires and
        // flows the whole table up to the previous page. Deferred with the rest
        // of the table-specific pagination work — decide whether a table should
        // block/merge differently.
        final path = sel.start.path;
        if (path.length != 1 || path.first != 0) return KeyEventResult.ignored;
        return handler() ? KeyEventResult.handled : KeyEventResult.ignored;
      },
    );
  }
  // Same identity-stability reasoning as `_commandShortcutEvents` above:
  // built once, reused across every `buildEditor` call rather than
  // rebuilt inline.
  //
  // The "/" slash menu is not a separate constructor param on
  // AppFlowyEditor — it's just another CharacterShortcutEvent
  // (the built-in `slashCommand`, triggered by typing '/'). To add our
  // own items we build a replacement via `customSlashCommand(...)` and
  // swap it in for the default one via `removeWhere`, same pattern
  // AppFlowy's own code-block extension example uses.
  //
  // standardSelectionMenuItems only exposes Heading 1-3 — the heading
  // block itself supports any level via its `HeadingBlockKeys.level`
  // attribute, the menu just doesn't surface higher levels by default.
  // The heading items below add H4-H6.

  // Same identity-stability reasoning as the shortcut/menu lists above:
  // built once, reused across every `buildEditor` call.
  //
  // CHANGED: was `_codeBlockType: ParagraphBlockComponentBuilder(...)`
  // with a plain monospace TextStyle — no highlighting, no language
  // switch, no copy action, just a mono-styled paragraph. Now registered
  // against `CodeBlockComponentBuilder` (see
  // features/editor/blocks/code_block/code_block_component.dart),
  // which layers real syntax highlighting (via flutter_highlight, no
  // dependency on appflowy_editor's version), a language dropdown, and
  // a copy button, while still delegating the actual editable text
  // rendering to `ParagraphBlockComponentBuilder` underneath — so all
  // the "why this is safe" reasoning from the old comment still holds,
  // this is strictly additive on top of it.
  late final Map<String, BlockComponentBuilder> _blockComponentBuilders = {
    ...standardBlockComponentBuilderMap,
    kCodeBlockType: CodeBlockComponentBuilder(),
  };

  late final List<SelectionMenuItem> _slashMenuItems = [
    ...standardSelectionMenuItems,
    _headingMenuItem(4),
    _headingMenuItem(5),
    _headingMenuItem(6),
    _codeBlockMenuItem(),
  ];

  late final List<CharacterShortcutEvent> _characterShortcutEvents = [
    ...VimCharacterShortcuts.getCharacterShortcuts(vimMode),
    customSlashCommand(_slashMenuItems),
    ...standardCharacterShortcutEvents
      ..removeWhere((element) => element == slashCommand),
  ];

  static SelectionMenuItem _headingMenuItem(int level) {
    return SelectionMenuItem(
      getName: () => 'H$level',
      // The built-in H1-H3 items render via SelectionMenuIconWidget(name:
      // 'h1'/'h2'/'h3', ...), which maps to bundled icon assets that only
      // exist for levels 1-3. There's no 'h4'/'h5'/'h6' asset to reuse, so
      // this reproduces the same "big H + small number" look by hand.
      // Colors are hardcoded rather than pulled from SelectionMenuStyle
      // since its exact field names weren't confirmed against your pinned
      // version — swap in the theme's real icon color if it looks off
      // next to H1-H3.
      icon:
          (editorState, isSelected, style) =>
              _HeadingIcon(level: level, isSelected: isSelected),
      keywords: ['h$level', 'heading$level', 'heading $level'],
      handler: (editorState, menuService, context) {
        final selection = editorState.selection;
        if (selection == null || !selection.isCollapsed) return;
        final path = selection.start.path;
        final node = editorState.getNodeAtPath(path);
        if (node == null) return;

        final transaction =
            editorState.transaction
              ..insertNode(path, headingNode(level: level, delta: node.delta))
              ..deleteNode(node)
              ..afterSelection = Selection.collapsed(
                Position(path: path, offset: selection.start.offset),
              );
        editorState.apply(transaction);
      },
    );
  }

  static SelectionMenuItem _codeBlockMenuItem() {
    return SelectionMenuItem(
      getName: () => 'Code Block',
      icon:
          (editorState, isSelected, style) => SelectionMenuIconWidget(
            icon: Icons.code,
            isSelected: isSelected,
            style: style,
          ),
      keywords: ['code', 'code block', 'codeblock', '```'],
      handler: (editorState, menuService, context) {
        final selection = editorState.selection;
        if (selection == null || !selection.isCollapsed) return;
        final path = selection.start.path;
        final node = editorState.getNodeAtPath(path);
        if (node == null) return;

        // CHANGED: was a hand-built `Node(type: _codeBlockType,
        // attributes: {blockComponentDelta: ...})` with no language
        // attribute. `codeBlockNode(...)` is the same shape plus a
        // default `language: 'plaintext'`, which CodeBlockComponentBuilder
        // reads to pick the highlight grammar and pre-select the
        // dropdown.
        final transaction =
            editorState.transaction
              ..insertNode(path, codeBlockNode(delta: node.delta))
              ..deleteNode(node)
              ..afterSelection = Selection.collapsed(
                Position(path: path, offset: selection.start.offset),
              );
        editorState.apply(transaction);
      },
    );
  }

  @override
  final VimModeController vimMode = VimModeController();

  /// Exposed for anything AppFlowy-specific that needs it (there isn't
  /// much reason to reach for this outside of this file/tests).
  EditorState get editorState => _editorState;

  @override
  Map<String, dynamic> get documentJson =>
      _editorState.document.toJson()['document'] as Map<String, dynamic>;

  @override
  Widget buildEditor(BuildContext context) {
    return AppFlowyEditor(
      editorState: _editorState,
      // Embed as a non-scrolling Column so this editor coexists with the
      // paged ListView (see _scrollController). Without it, nesting the
      // editor's own scroll view inside the page list throws the
      // "Provider<EditorScrollController>" error on multi-page notes.
      editorScrollController: _scrollController,
      // Never let a page's editor drive scrolling to chase the caret. Each page
      // is a bounded sheet inside the outer page ListView; auto-scroll-into-view
      // would scroll that OUTER list — which showed up as the view lurching to
      // the previous page after a backspace-merge, and "jumping to a new page"
      // when Enter pushed the caret past the sheet. The user scrolls the page
      // list themselves. (Gates desktop_scroll_service's scrollTo.)
      disableAutoScroll: true,
      disableScrollService: false,

      // Off by default: with one editor per page, all pages auto-focusing at
      // once fights for the keyboard and surfaced the "Null check operator used
      // on a null value" on open. Only a page created to receive focus (e.g.
      // the freshly-merged page after a backspace-merge) sets this true so the
      // caret lands there.
      autoFocus: _autoFocus,
      // Carries the standard block builders plus the 'code_block' type
      // added above (registered against CodeBlockComponentBuilder with
      // syntax highlighting). Cached field — see _blockComponentBuilders.
      blockComponentBuilders: _blockComponentBuilders,
      // Custom shortcuts go FIRST: AppFlowyEditor stops at the first
      // matching shortcut whose handler returns `handled`. The standard
      // library ships its own Escape binding (used to collapse
      // selection / dismiss popups) — with standard shortcuts checked
      // first, that binding swallowed Escape before
      // `mode.enterNormalMode()` ever ran, so Escape looked like a
      // no-op instead of returning to normal mode. Same reasoning
      // applies to characterShortcutEvents.
      //
      // These are cached fields (see above), NOT rebuilt here, so the
      // same List/object identity survives every rebuild.
      commandShortcutEvents: _commandShortcutEvents,
      // Carries the customized "/" slash menu (standard items + H4-H6 +
      // Code Block) via customSlashCommand — see
      // _characterShortcutEvents above. There is no separate
      // `selectionMenuItems` constructor param.
      characterShortcutEvents: _characterShortcutEvents,
    );
  }

  static const _emptyDocument = {
    "type": "page",
    "children": [
      {
        "type": "paragraph",
        "data": {
          "delta": [
            {"insert": ""},
          ],
        },
      },
    ],
  };

  static EditorState _buildEditorState(
    Map<String, dynamic>? initial, [
    int? caretBlockIndex,
    int? caretOffset,
  ]) {
    final docJson = initial ?? _emptyDocument;
    final state = _constructEditorState(docJson);

    // Seed the caret. `caretBlockIndex` targets a specific top-level block:
    // the backspace-merge passes it with offset 0 (the seam); the reflow's
    // caret hand-off passes an explicit `caretOffset` to land the caret exactly
    // where the user was typing. Otherwise the caret goes to the END of the last
    // line, so a focused page is immediately editable with no click.
    final children = state.document.root.children;
    if (caretBlockIndex != null && children.isNotEmpty) {
      final idx = caretBlockIndex.clamp(0, children.length - 1).toInt();
      // Clamp the offset to the target block's length (a non-text or shorter
      // block can't hold an offset carried over from a longer one).
      final blockLen = children[idx].delta?.length ?? 0;
      final off = (caretOffset ?? 0).clamp(0, blockLen).toInt();
      state.updateSelectionWithReason(
        Selection.collapsed(Position(path: [idx], offset: off)),
        reason: SelectionUpdateReason.uiEvent,
      );
      return state;
    }

    final lastNode = state.document.last;
    if (lastNode != null) {
      final offset = lastNode.delta?.length ?? 0;
      state.updateSelectionWithReason(
        Selection.collapsed(Position(path: lastNode.path, offset: offset)),
        reason: SelectionUpdateReason.uiEvent,
      );
    }

    return state;
  }

  // Split out from `_buildEditorState` specifically so the try/catch
  // can use `return` in each branch. Assigning a single `final` local
  // from both a try block and its catch block is a Dart compile error
  // (assignment_to_final_local) even though only one branch ever
  // actually runs — a separate function that returns directly from
  // each branch avoids that restriction entirely.
  static EditorState _constructEditorState(Map<String, dynamic> docJson) {
    try {
      return EditorState(document: Document.fromJson({'document': docJson}));
    } catch (_) {
      return EditorState.blank();
    }
  }

  @override
  void dispose() {
    _transactionSub.cancel();
    _scrollController.dispose();
    vimMode.dispose();
    super.dispose();
  }
}

/// Renders "H" + a small trailing number, matching the visual pattern of
/// the package's built-in H1-H3 slash-menu icons (big letter, small
/// subscript-style digit) for the H4-H6 items this file adds. Sizing and
/// color are approximate — nudge `fontSize`/color to match exactly if it
/// looks slightly off next to the built-in H1-H3 icons in your theme.
class _HeadingIcon extends StatelessWidget {
  const _HeadingIcon({required this.level, required this.isSelected});

  final int level;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final color =
        isSelected ? const Color(0xFF2E7BF6) : const Color(0xFF44474D);
    return SizedBox(
      width: 20,
      height: 18,
      child: Center(
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'H',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              TextSpan(
                text: '$level',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
