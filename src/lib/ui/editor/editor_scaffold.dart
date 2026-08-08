import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cerebrum_app/api/bubbles_api.dart';
import 'package:cerebrum_app/api/learning_center_api.dart';
import 'package:cerebrum_app/services/sync_service.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:cerebrum_app/ui/editor/controllers/note_editor_controller.dart';
import 'package:cerebrum_app/ui/editor/controllers/text_editing_driver.dart';
import 'package:cerebrum_app/ui/editor/controllers/appflowy_text_driver.dart';
import 'package:cerebrum_app/ui/editor/screens/editor_surface.dart';

enum _TextEngine { appFlowy, superEditor }

/// Everything that surrounds the editor: note loading/saving, autosave
/// scheduling, the analysis panel + its API calls, the app bar, and the
/// save FAB. This class only ever talks to the editor through
/// [NoteEditorController], which itself only talks to [TextEditingDriver]
/// — the AppFlowy/super_editor switch in the app bar below swaps the
/// driver at runtime without this class needing to know either engine
/// exists.
class EditorScaffold extends StatefulWidget {
  final Map<String, dynamic> note;
  final Map<String, dynamic>? initialTextJson;
  final List<Map<String, dynamic>>? initialInkJson;

  const EditorScaffold({
    super.key,
    required this.note,
    this.initialTextJson,
    this.initialInkJson,
  });

  @override
  State<EditorScaffold> createState() => _EditorScaffoldState();
}

class _EditorScaffoldState extends State<EditorScaffold> {
  late final NoteEditorController _editorController;
  _TextEngine _currentEngine = _TextEngine.appFlowy;

  // App-session default for which mode a note opens in. Lives only for
  // the lifetime of the app process — flip it from the "More" menu and
  // it applies to the next note you open. If you want it to survive an
  // app relaunch, persist this alongside your other user settings
  // (shared_preferences, or a user-settings API call) instead of a
  // static field.
  static bool _defaultStartInDrawingMode = false;

  Timer? _debounce;
  bool _isSaving = false;
  String _lastSavedState = '';

  String? _cachedAnalysis; // used only for error/empty/regenerate-raw messages
  Map<String, dynamic>? _analysisData; // raw /fetch/analysis/full payload

  /// The raw analysis payload, in case something outside the panel UI
  /// (debugging, a future detail view, etc.) needs it. Not read anywhere
  /// in this file itself — [_overviewMarkdown]/[_analysisChunks]/
  /// [_cachedAnalysis] are the derived views the panel actually renders.
  Map<String, dynamic>? get analysisData => _analysisData;
  String?
  _overviewMarkdown; // formatted note_overview, rendered once above the list
  List<Map<String, dynamic>> _analysisChunks =
      []; // flattened + numerically sorted
  bool _hasAttemptedLoad =
      false; // did we already try loading, vs. just toggling the panel
  bool _isLoadingAnalysis = false;
  bool _showAnalysisPanel = false;
  bool _isGeneratingAnalysis = false;

  late bool _analysisEnabled;
  bool _isTogglingAnalysis = false;

  String? _noteIdFromFilename(String? filename) {
    if (filename == null || filename.isEmpty) return null;
    return filename.endsWith('.json')
        ? filename.substring(0, filename.length - 5)
        : filename;
  }

  @override
  void initState() {
    super.initState();

    final rawFilename = widget.note['filename'];
    final parsedNoteId = _noteIdFromFilename(rawFilename as String?);
    debugPrint(
      '[EditorScaffold] Opening note. filename="$rawFilename" '
      'noteId="$parsedNoteId"',
    );

    // Seed the toggle from the note payload (backend field: analyse_note).
    _analysisEnabled = widget.note['analyse_note'] as bool? ?? true;

    final contentData =
        widget.initialTextJson ??
        widget.note['content'] as Map<String, dynamic>?;
    final docJson = contentData?['document'] as Map<String, dynamic>?;

    final inkJson =
        widget.initialInkJson ??
        (widget.note['ink'] != null
            ? List<Map<String, dynamic>>.from(widget.note['ink'])
            : null);

    // TEMP DEBUG — remove once the ink-loading issue is confirmed/fixed.
    debugPrint(
      '[EditorScaffold] widget.note has "ink" key: '
      '${widget.note.containsKey('ink')}, '
      'inkJson length: ${inkJson?.length}, '
      'first-elem keys: ${inkJson?.firstOrNull?.keys.toList()}',
    );

    _editorController = NoteEditorController(
      driver: AppFlowyTextDriver(initialDocumentJson: docJson),
      initialInkJson: inkJson,
      startInDrawingMode: _defaultStartInDrawingMode,
    );
    _editorController.addListener(_onEditorChanged);

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _updateLastSavedState(),
    );
  }

  void _onEditorChanged() {
    // Autosave scheduling needs to run on every driver change, no matter
    // what. UI that reacts to every keystroke — the save indicator, the
    // drawing-mode icon — used to be refreshed via a blanket
    // `setState(() {})` here, which rebuilt the ENTIRE scaffold (app
    // bar, analysis panel, everything) on every single character typed.
    // That's now scoped to just those two widgets via their own
    // `AnimatedBuilder(animation: _editorController, ...)` down in
    // build() instead, so a keystroke no longer forces the whole
    // scaffold — including the AppFlowyEditor subtree one level down —
    // through a rebuild on top of AppFlowyEditor's own internal
    // focus/selection handling for that same keystroke.
    _scheduleSave();
  }

  String _serializedEditorState() =>
      '${jsonEncode(_editorController.documentJson)}|'
      '${jsonEncode(_editorController.inkJson)}';

  void _updateLastSavedState() {
    _lastSavedState = _serializedEditorState();
  }

  bool _hasUnsavedChanges() => _serializedEditorState() != _lastSavedState;

  void _scheduleSave() {
    if (!_hasUnsavedChanges()) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 2), _save);
  }

  Future<void> _save() async {
    if (_isSaving || !_hasUnsavedChanges()) return;

    setState(() => _isSaving = true);

    try {
      final bubbleId = widget.note['bubble_id'] as String;
      final filename = widget.note['filename'] as String?;

      // Existing note → push through sync (version-vector merge, offline-safe
      // queue). New note → create as before; subsequent saves sync.
      final updated =
          filename != null
              ? await _syncSave(bubbleId, filename)
              : await BubbleNotesApi.createNote(
                bubbleId: bubbleId,
                title: widget.note['title'] ?? 'Untitled',
                content: {'document': _editorController.documentJson},
                ink: _editorController.inkJson,
              );

      widget.note.addAll(updated);
      _updateLastSavedState();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// Save an existing note via [SyncService.pushNote]: the server merges our
  /// version (version-vector; last-writer-wins per page on concurrent edits;
  /// ink union) and returns the merged note. If the daemon is unreachable the
  /// push is queued offline and we keep the local edits; drainOutbox() retries.
  Future<Map<String, dynamic>> _syncSave(String bubbleId, String filename) async {
    final noteId =
        filename.endsWith('.json')
            ? filename.substring(0, filename.length - 5)
            : filename;
    final note = <String, dynamic>{
      'title': widget.note['title'] ?? 'Untitled',
      'content': {'document': _editorController.documentJson},
      'ink': _editorController.inkJson,
      'bubble_id': bubbleId,
      'note_id': noteId,
    };
    final result = await SyncService.pushNote(bubbleId, noteId, note);
    if (result == null) return note; // queued offline — keep local edits
    return Map<String, dynamic>.from(result['note'] as Map);
  }

  Future<void> _toggleAnalysis(bool newValue) async {
    final bubbleId = widget.note['bubble_id'] as String?;
    final filename = widget.note['filename'] as String?;

    if (bubbleId == null || filename == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Save the note before changing analysis settings'),
          ),
        );
      }
      return;
    }

    // Optimistically flip the UI, then reconcile with the server response.
    setState(() {
      _analysisEnabled = newValue;
      _isTogglingAnalysis = true;
    });

    try {
      final result = await BubbleNotesApi.toggleNoteAnalysis(
        bubbleId,
        filename,
      );

      widget.note.addAll(result);

      setState(() {
        _analysisEnabled = result['analyse_note'] as bool? ?? _analysisEnabled;
        _isTogglingAnalysis = false;
      });
    } catch (e) {
      setState(() {
        _analysisEnabled = !newValue;
        _isTogglingAnalysis = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update analysis setting: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadAnalysis() async {
    final bubbleId = widget.note['bubble_id'] as String?;
    final noteId = _noteIdFromFilename(widget.note['filename'] as String?);
    final version = widget.note["version"];

    if (bubbleId == null || noteId == null) return;

    setState(() => _isLoadingAnalysis = true);

    try {
      final full = await LearningCenterApi.getFullCachedAnalysis(
        bubbleId: bubbleId,
        noteId: noteId,
        currentVersion: version is num ? version.toDouble() : null,
      );

      setState(() {
        _hasAttemptedLoad = true;
        if (full != null) {
          _analysisData = full;
          _overviewMarkdown = _formatOverviewMarkdown(full);
          _analysisChunks = _flattenAndSortChunks(
            full['chunk_diagnostics'] as List<dynamic>? ?? [],
          );
          _cachedAnalysis = null;
        } else {
          _analysisData = null;
          _overviewMarkdown = null;
          _analysisChunks = [];
          _cachedAnalysis = 'No cached analysis found for this note.';
        }
        _showAnalysisPanel = true;
        _isLoadingAnalysis = false;
      });
    } catch (e) {
      setState(() {
        _hasAttemptedLoad = true;
        _analysisData = null;
        _overviewMarkdown = null;
        _analysisChunks = [];
        _cachedAnalysis = 'Error loading analysis:\n$e';
        _showAnalysisPanel = true;
        _isLoadingAnalysis = false;
      });
    }
  }

  // Formats just the note-level overview (topic, mastery, concept map,
  // priority study order, suggested sources) as markdown. Chunk-level
  // findings are rendered separately as widgets, not text — see
  // _flattenAndSortChunks and _ChunkExpansionTile below.
  String _formatOverviewMarkdown(Map<String, dynamic> data) {
    final buffer = StringBuffer();

    if (data['is_current'] == false && data['cached_version'] != null) {
      buffer.writeln(
        '> ⚠️ Showing cached analysis from **v${data['cached_version']}** '
        '— this may be out of date.',
      );
      buffer.writeln();
    }

    final overview = data['note_overview'] as Map<String, dynamic>?;
    if (overview == null) return buffer.toString();

    buffer.writeln('## ${overview['topic'] ?? 'Overview'}');
    buffer.writeln();
    if (overview['mastery_signal'] != null) {
      buffer.writeln(
        '**Mastery:** ${overview['mastery_signal']} '
        '(${overview['progress_delta'] ?? 'n/a'})',
      );
      buffer.writeln();
    }

    final conceptMap = overview['concept_map'] as Map<String, dynamic>?;
    if (conceptMap != null) {
      final strong = conceptMap['strong_areas'] as List<dynamic>? ?? [];
      final weak = conceptMap['weak_areas'] as List<dynamic>? ?? [];
      final confused = conceptMap['confused_links'] as List<dynamic>? ?? [];

      if (strong.isNotEmpty) {
        buffer.writeln('**Strong areas:**');
        for (final s in strong) buffer.writeln('- $s');
        buffer.writeln();
      }
      if (weak.isNotEmpty) {
        buffer.writeln('**Weak areas:**');
        for (final w in weak) buffer.writeln('- $w');
        buffer.writeln();
      }
      if (confused.isNotEmpty) {
        buffer.writeln('**Confused concepts:**');
        for (final c in confused) {
          final cm = c as Map<String, dynamic>;
          buffer.writeln(
            '- *${cm['concept_a']}* vs *${cm['concept_b']}*: ${cm['confusion_description']}',
          );
        }
        buffer.writeln();
      }
    }

    final gaps = overview['knowledge_gaps_summary'] as List<dynamic>? ?? [];
    if (gaps.isNotEmpty) {
      buffer.writeln('**Knowledge gaps:**');
      for (final g in gaps) buffer.writeln('- $g');
      buffer.writeln();
    }

    final priority = overview['priority_study_areas'] as List<dynamic>? ?? [];
    if (priority.isNotEmpty) {
      buffer.writeln('**Priority study order:**');
      for (final p in priority) buffer.writeln('1. $p');
      buffer.writeln();
    }

    final sources = overview['suggested_sources'] as List<dynamic>? ?? [];
    if (sources.isNotEmpty) {
      buffer.writeln('**Suggested reading:**');
      for (final s in sources) {
        final sm = s as Map<String, dynamic>;
        buffer.writeln('- *${sm['title']}* — ${sm['reason']}');
      }
      buffer.writeln();
    }

    return buffer.toString();
  }

  // Flattens the nested chunk_diagnostics payload into one list per finding
  // group, and sorts NUMERICALLY by the index embedded in chunk_id (e.g.
  // "chunk_2" before "chunk_10") — the raw glob().sort() on the backend is
  // a lexicographic string sort and gets this wrong past chunk_9.
  List<Map<String, dynamic>> _flattenAndSortChunks(List<dynamic> rawChunks) {
    final flattened = <Map<String, dynamic>>[];

    for (final outer in rawChunks) {
      final outerMap = outer as Map<String, dynamic>;
      final diagnostics = outerMap['chunk_diagnostics'] as List<dynamic>? ?? [];

      for (final diag in diagnostics) {
        final d = diag as Map<String, dynamic>;
        final chunkId = (d['chunk_id'] ?? 'chunk').toString();
        final match = RegExp(r'(\d+)').firstMatch(chunkId);
        final chunkIndex = match != null ? int.parse(match.group(1)!) : 1 << 30;

        flattened.add({
          'chunkId': chunkId,
          'chunkIndex': chunkIndex,
          'excerpt': d['chunk_excerpt'] as String?,
          'findings': d['findings'] as List<dynamic>? ?? [],
        });
      }
    }

    flattened.sort(
      (a, b) => (a['chunkIndex'] as int).compareTo(b['chunkIndex'] as int),
    );
    return flattened;
  }

  Future<void> _generateAnalysis() async {
    final bubbleId = widget.note['bubble_id'] as String?;
    final filename = widget.note['filename'] as String?;

    if (bubbleId == null || filename == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot generate analysis: Note not saved yet'),
          ),
        );
      }
      return;
    }

    setState(() => _isGeneratingAnalysis = true);

    try {
      final analysis = await LearningCenterApi.runActiveAnalysis(
        bubbleId: bubbleId,
        filename: filename,
      );

      setState(() {
        // runActiveAnalysis returns raw text, not the structured
        // chunk_diagnostics/note_overview payload — show it as a plain
        // message until the next _loadAnalysis() call repopulates the
        // structured view from the cache.
        _analysisData = null;
        _overviewMarkdown = null;
        _analysisChunks = [];
        _cachedAnalysis =
            analysis ?? 'Analysis generated but no content returned.';
        _hasAttemptedLoad = true;
        _showAnalysisPanel = true;
        _isGeneratingAnalysis = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Analysis generated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _analysisData = null;
        _overviewMarkdown = null;
        _analysisChunks = [];
        _cachedAnalysis = 'Error generating analysis:\n$e';
        _hasAttemptedLoad = true;
        _showAnalysisPanel = true;
        _isGeneratingAnalysis = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate analysis: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Whether the current driver has vim-style modal editing at all —
  /// not every engine implements [VimModeAware] (see
  /// text_editing_driver.dart), so the menu item below disables itself
  /// rather than toggling something that doesn't exist.
  bool get _vimModeAvailable => _editorController.driver is VimModeAware;

  bool get _vimModeEnabled {
    final driver = _editorController.driver;
    if (driver is! VimModeAware) return false;
    return (driver as VimModeAware).vimMode.isEnabled;
  }

  void _toggleVimMode() {
    final driver = _editorController.driver;
    if (driver is! VimModeAware) return;
    final vimAware = driver as VimModeAware;
    vimAware.vimMode.setEnabled(!vimAware.vimMode.isEnabled);
    // vimMode notifies its own listeners, which _onEditorChanged is
    // already wired to (driver -> controller -> this widget), so no
    // separate setState is strictly required — but this menu is
    // rebuilt from scratch on open each time anyway.
  }

  void _switchEngine(_TextEngine engine) {
    if (engine == _currentEngine) return;

    final TextEditingDriver newDriver;
    switch (engine) {
      case _TextEngine.appFlowy:
        // Reuse whatever content the previous driver reports, so
        // switching back to AppFlowy after testing doesn't lose it.
        newDriver = AppFlowyTextDriver(
          initialDocumentJson: _editorController.documentJson,
        );
        break;
      case _TextEngine.superEditor:
        // newDriver = SuperEditorTextDriver();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'super_editor is a testing engine — content typed here '
                "won't be saved until its serializer is finished.",
              ),
            ),
          );
        }
        break;
    }

    setState(() {
      _currentEngine = engine;
      // _editorController.switchDriver(newDriver);
    });
  }

  @override
  void dispose() {
    _editorController.removeListener(_onEditorChanged);
    _editorController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note['title'] ?? 'Edit Note'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          if (_isGeneratingAnalysis)
            const Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.orange,
              ),
            ),

          // The primary mode switch: which view of this note you're
          // looking at. Replaces the old bare analytics IconButton — same
          // load-on-first-open / toggle-after behavior, just legible.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Note')),
                ButtonSegment(value: true, label: Text('Analysis')),
              ],
              selected: {_showAnalysisPanel},
              onSelectionChanged:
                  _isLoadingAnalysis
                      ? null
                      : (selection) {
                        final wantsAnalysis = selection.first;
                        if (wantsAnalysis && !_hasAttemptedLoad) {
                          _loadAnalysis();
                        } else {
                          setState(() => _showAnalysisPanel = wantsAnalysis);
                        }
                      },
            ),
          ),

          AnimatedBuilder(
            animation: _editorController,
            builder: (context, _) {
              final drawingEnabled = _editorController.drawingEnabled;
              return IconButton(
                icon: Icon(drawingEnabled ? Icons.brush : Icons.text_fields),
                tooltip:
                    drawingEnabled
                        ? 'Switch to text mode'
                        : 'Switch to drawing mode',
                onPressed: () {
                  _editorController.toggleDrawingMode();
                  if (_editorController.drawingEnabled) {
                    FocusScope.of(context).unfocus();
                  }
                },
              );
            },
          ),

          // Secondary, settings-style actions that don't need to be
          // permanently visible: whether analysis runs for this note at
          // all (distinct from just viewing the panel above), and the
          // editing-engine switch, which is a testing tool, not a
          // day-to-day control.
          PopupMenuButton<String>(
            tooltip: 'More',
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'toggle_analysis_enabled':
                  _toggleAnalysis(!_analysisEnabled);
                  break;
                case 'engine_appFlowy':
                  _switchEngine(_TextEngine.appFlowy);
                  break;
                case 'engine_superEditor':
                  _switchEngine(_TextEngine.superEditor);
                  break;
                case 'default_start_in_drawing_mode':
                  setState(
                    () =>
                        _defaultStartInDrawingMode =
                            !_defaultStartInDrawingMode,
                  );
                  break;
                case 'toggle_vim_mode':
                  setState(_toggleVimMode);
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  CheckedPopupMenuItem<String>(
                    value: 'toggle_analysis_enabled',
                    checked: _analysisEnabled,
                    enabled: !_isTogglingAnalysis,
                    child: const Text('Analysis enabled for this note'),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem<String>(
                    value: 'engine_appFlowy',
                    child: Row(
                      children: [
                        Icon(
                          _currentEngine == _TextEngine.appFlowy
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Text('Editing engine: AppFlowy'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'engine_superEditor',
                    child: Row(
                      children: [
                        Icon(
                          _currentEngine == _TextEngine.superEditor
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Text('Editing engine: super_editor (testing)'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  CheckedPopupMenuItem<String>(
                    value: 'default_start_in_drawing_mode',
                    checked: _defaultStartInDrawingMode,
                    child: const Text('Open new notes in drawing mode'),
                  ),
                  CheckedPopupMenuItem<String>(
                    value: 'toggle_vim_mode',
                    checked: _vimModeEnabled,
                    enabled: _vimModeAvailable,
                    child: Text(
                      _vimModeAvailable
                          ? 'Neovim keybindings'
                          : 'Neovim keybindings (unsupported by this engine)',
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: EditorSurface(controller: _editorController),
            ),

            if (_showAnalysisPanel && _hasAttemptedLoad)
              Positioned(
                right: 16,
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 900,
                    width: 800,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.insights_rounded, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Note Analysis',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            Row(
                              children: [
                                FilledButton.icon(
                                  onPressed:
                                      (_isGeneratingAnalysis ||
                                              !_analysisEnabled)
                                          ? null
                                          : _generateAnalysis,
                                  icon:
                                      _isGeneratingAnalysis
                                          ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                          : const Icon(Icons.auto_awesome),
                                  label: Text(
                                    _isGeneratingAnalysis
                                        ? 'Generating...'
                                        : 'Regenerate',
                                  ),
                                ),

                                const SizedBox(width: 8),

                                IconButton(
                                  icon: const Icon(Icons.close),
                                  tooltip: 'Close',
                                  onPressed: () {
                                    setState(() {
                                      _showAnalysisPanel = false;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Divider(),
                        if (!_analysisEnabled)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'Analysis is currently turned off for this note.',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        Expanded(
                          child:
                              _cachedAnalysis != null
                                  // Error / empty / raw-regenerate-result states —
                                  // no structured chunk data to build a list from.
                                  ? SingleChildScrollView(
                                    child: GptMarkdown(_cachedAnalysis!),
                                  )
                                  : ListView.builder(
                                    itemCount: 1 + _analysisChunks.length,
                                    itemBuilder: (context, index) {
                                      if (index == 0) {
                                        return _overviewMarkdown != null &&
                                                _overviewMarkdown!
                                                    .trim()
                                                    .isNotEmpty
                                            ? Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 12,
                                              ),
                                              child: GptMarkdown(
                                                _overviewMarkdown!,
                                              ),
                                            )
                                            : const SizedBox.shrink();
                                      }
                                      return _ChunkExpansionTile(
                                        chunk: _analysisChunks[index - 1],
                                      );
                                    },
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            // Passive save-status indicator, replacing the old bare Save
            // FAB. Tapping it still forces an immediate save — it's the
            // same _save() call — but at rest it now tells you whether
            // there's anything to save at all, instead of always looking
            // like an unpressed button.
            Positioned(
              right: 16,
              bottom: 16,
              child: AnimatedBuilder(
                animation: _editorController,
                builder: (context, _) {
                  final hasUnsaved = _hasUnsavedChanges();
                  return Material(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                    elevation: 2,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: _isSaving ? null : _save,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_isSaving)
                              const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            else
                              Icon(
                                hasUnsaved ? Icons.circle : Icons.check,
                                size: 14,
                                color:
                                    hasUnsaved ? Colors.orange : Colors.green,
                              ),
                            const SizedBox(width: 6),
                            Text(
                              _isSaving
                                  ? 'Saving…'
                                  : (hasUnsaved ? 'Unsaved changes' : 'Saved'),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One expandable list item per chunk. Collapsed shows the chunk id and a
/// finding count; expanded shows the source excerpt plus each finding as
/// its own nested expansion tile (see _FindingTile).
class _ChunkExpansionTile extends StatelessWidget {
  final Map<String, dynamic> chunk;

  const _ChunkExpansionTile({required this.chunk});

  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final findings = chunk['findings'] as List<dynamic>? ?? [];
    final excerpt = chunk['excerpt'] as String?;
    final chunkId = chunk['chunkId'] as String? ?? 'chunk';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ExpansionTile(
        title: Text(
          chunkId,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${findings.length} finding${findings.length == 1 ? '' : 's'}',
        ),
        children: [
          if (excerpt != null && excerpt.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                  border: Border(
                    left: BorderSide(color: Colors.grey.shade400, width: 3),
                  ),
                ),
                child: Text(
                  excerpt,
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          for (final f in findings)
            _FindingTile(
              finding: f as Map<String, dynamic>,
              severityColor: _severityColor,
            ),
        ],
      ),
    );
  }
}

/// One expandable finding within a chunk. Collapsed shows a severity dot
/// and the finding type; expanded shows claim / correct-understanding
/// (only if it actually differs from the claim) / gap explanation.
class _FindingTile extends StatelessWidget {
  final Map<String, dynamic> finding;
  final Color Function(String) severityColor;

  const _FindingTile({required this.finding, required this.severityColor});

  @override
  Widget build(BuildContext context) {
    final severity = (finding['severity'] ?? 'unknown').toString();
    final type = (finding['type'] ?? 'finding').toString().replaceAll('_', ' ');
    final claim = finding['student_claim'] as String?;
    final correct = finding['correct_understanding'] as String?;
    final gap = finding['gap_explanation'] as String?;
    final showCorrect = correct != null && correct != claim;

    return ExpansionTile(
      leading: CircleAvatar(
        radius: 6,
        backgroundColor: severityColor(severity),
      ),
      title: Text(
        type,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text(
        severity.toUpperCase(),
        style: TextStyle(fontSize: 11, color: severityColor(severity)),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (claim != null) ...[
                const Text(
                  'Claim',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Text(claim),
                const SizedBox(height: 8),
              ],
              if (showCorrect) ...[
                const Text(
                  'Correct understanding',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Text(correct),
                const SizedBox(height: 8),
              ],
              if (gap != null) ...[
                const Text(
                  'Gap',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Text(gap),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
