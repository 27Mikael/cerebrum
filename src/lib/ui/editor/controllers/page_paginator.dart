/// Pure, deterministic note pagination (heuristic, line-budget based).
///
/// Given the note as an ordered list of pages (each page = a list of AppFlowy
/// top-level block maps), [paginate] reflows every block into pages so no page
/// exceeds a line budget — true continuous pagination:
///
///   * inserting content on an early page cascades everything after it down;
///   * deleting content pulls later content back up;
///   * a block taller than a page is SPLIT across the boundary (paragraphs by
///     line, tables by row) rather than clipped;
///   * a genuinely unsplittable oversized block gets its own page (it can still
///     overflow, but nothing is lost).
///
/// It is intentionally free of Flutter / appflowy_editor so it is trivially
/// unit-testable and can never break the live editor. "Lines" are ESTIMATED
/// from block content (see [estimateBlockLines]); pagination therefore fills to
/// *about* a sheet, not pixel-exact — tune [kLineBudget]/[kCharsPerLine] to the
/// real sheet + font. The editor integration (when to run this, how to rebuild
/// pages, caret hand-off) lives in PagedNoteController.
library;

typedef Block = Map<String, dynamic>;

/// Lines that fit on one A4 sheet at the current font. Tune to taste.
const int kLineBudget = 40;

/// Characters that fit on one wrapped line of a paragraph. Tune to the sheet
/// width + font. Used to estimate how many lines a text block occupies.
const int kCharsPerLine = 80;

/// A heading renders taller than a body line (bigger font + spacing).
const int kHeadingLines = 2;

/// Don't bother splitting a block into a gap smaller than this — flush the page
/// and start the block fresh on the next one instead (avoids 1-line slivers).
const int kMinSplitLines = 3;

/// Block types whose text is a `data.delta` run and that split by line.
const Set<String> _kTextTypes = {
  'paragraph',
  'heading',
  'quote',
  'bulleted_list',
  'numbered_list',
  'todo_list',
  'toggle_list',
};

// --------------------------------------------------------------------------
// Estimation
// --------------------------------------------------------------------------

/// Estimated line count a block occupies on a sheet.
int estimateBlockLines(Block block) {
  final type = block['type'] as String?;
  if (type == 'divider') return 1;
  if (type == 'table') {
    final rows = _int(_data(block)['rowsLen']) ?? 1;
    return rows + 1; // rows + a little chrome
  }
  final lines = _textLineCount(_blockText(block));
  if (type == 'heading') return lines + kHeadingLines - 1; // headings are taller
  return lines;
}

int _textLineCount(String text) {
  if (text.isEmpty) return 1;
  // Count hard newlines, then wrap each by width.
  var total = 0;
  for (final line in text.split('\n')) {
    total += line.isEmpty ? 1 : (line.length / kCharsPerLine).ceil();
  }
  return total < 1 ? 1 : total;
}

/// Plain text of a block's TOP-LEVEL delta (nested/table-cell text is not
/// included). Exposed so the controller can measure a caret as a global
/// character offset across the flattened block stream — an anchor that survives
/// pagination, because [paginate] conserves this text exactly (blocks split by
/// character, tables stay atomic, nothing is dropped).
String blockPlainText(Block block) => _blockText(block);

String _blockText(Block block) {
  final delta = _data(block)['delta'];
  if (delta is! List) return '';
  final sb = StringBuffer();
  for (final op in delta) {
    if (op is Map && op['insert'] is String) sb.write(op['insert'] as String);
  }
  return sb.toString();
}

// --------------------------------------------------------------------------
// Pagination
// --------------------------------------------------------------------------

/// Reflow [pages] so each page's estimated lines ≤ [budget]. Returns a fresh
/// list of pages (deep-independent block maps; inputs are not mutated).
List<List<Block>> paginate(
  List<List<Block>> pages, {
  int budget = kLineBudget,
}) {
  // 1. Flatten to a single ordered block stream (page boundaries are recomputed).
  final queue = <Block>[];
  for (final page in pages) {
    for (final block in page) {
      queue.add(_clone(block));
    }
  }
  if (queue.isEmpty) {
    return [
      [_emptyParagraph()],
    ];
  }

  // 2. Greedily fill pages; split blocks that don't fit.
  final out = <List<Block>>[];
  var cur = <Block>[];
  var used = 0;

  var i = 0;
  while (i < queue.length) {
    final block = queue[i];
    final h = estimateBlockLines(block);
    final remaining = budget - used;

    if (h <= remaining) {
      cur.add(block);
      used += h;
      i++;
      continue;
    }

    if (cur.isEmpty) {
      // Fresh page and the block still doesn't fit.
      if (_isSplittable(block) && budget >= kMinSplitLines) {
        final parts = _split(block, budget);
        if (parts != null) {
          out.add([parts.$1]);
          queue[i] = parts.$2; // continue the tail on the next page
          continue;
        }
      }
      // Unsplittable oversized block → its own page (may overflow, never lost).
      out.add([block]);
      i++;
      continue;
    }

    // Page has content but the block won't fit the remaining space.
    if (_isSplittable(block) && remaining >= kMinSplitLines) {
      final parts = _split(block, remaining);
      if (parts != null) {
        cur.add(parts.$1);
        out.add(cur);
        cur = <Block>[];
        used = 0;
        queue[i] = parts.$2;
        continue;
      }
    }

    // Flush the page and retry this whole block at the top of a fresh one.
    out.add(cur);
    cur = <Block>[];
    used = 0;
  }

  if (cur.isNotEmpty) out.add(cur);
  if (out.isEmpty) {
    out.add([_emptyParagraph()]);
  }
  return out;
}

// --------------------------------------------------------------------------
// Splitting
// --------------------------------------------------------------------------

bool _isSplittable(Block block) {
  final type = block['type'] as String?;
  if (type == 'table') return _tableIsSplittable(block);
  return _kTextTypes.contains(type);
}

/// A table can be row-split only if it has more than one row (a single-row
/// table has nothing to divide) and enough structure to reindex.
bool _tableIsSplittable(Block block) {
  final rows = _int(_data(block)['rowsLen']) ?? 0;
  return rows > 1;
}

/// Split [block] so the head occupies at most [headLines] lines and the tail
/// carries the rest. Returns null if it can't be split usefully.
(Block, Block)? _split(Block block, int headLines) {
  if (block['type'] == 'table') return _splitTable(block, headLines);
  return _splitTextBlock(block, headLines);
}

/// Split a delta-backed block by character budget (headLines × chars/line),
/// preserving each op's attributes. The head keeps the block's type/data; the
/// tail is a plain paragraph continuation (so a split heading/list item doesn't
/// repeat its marker).
(Block, Block)? _splitTextBlock(Block block, int headLines) {
  final data = _data(block);
  final delta = data['delta'];
  if (delta is! List || delta.isEmpty) return null;

  final headChars = headLines * kCharsPerLine;
  if (headChars <= 0) return null;

  final headOps = <dynamic>[];
  final tailOps = <dynamic>[];
  var consumed = 0;
  var splitDone = false;

  for (final op in delta) {
    if (splitDone) {
      tailOps.add(op);
      continue;
    }
    final insert = (op is Map && op['insert'] is String) ? op['insert'] as String : null;
    if (insert == null) {
      headOps.add(op);
      continue;
    }
    if (consumed + insert.length <= headChars) {
      headOps.add(op);
      consumed += insert.length;
    } else {
      final cut = headChars - consumed;
      if (cut > 0) {
        headOps.add(
          Map<String, dynamic>.from(op as Map)..['insert'] = insert.substring(0, cut),
        );
      }
      final rest = insert.substring(cut < 0 ? 0 : cut);
      if (rest.isNotEmpty) {
        tailOps.add(
          Map<String, dynamic>.from(op as Map)..['insert'] = rest,
        );
      }
      splitDone = true;
    }
  }

  if (headOps.isEmpty || tailOps.isEmpty) return null; // nothing gained

  final head = _clone(block);
  (head['data'] as Map)['delta'] = headOps;

  // Tail continues as a paragraph (avoids duplicating a heading style or list
  // number across the page break).
  final tail = <String, dynamic>{
    'type': 'paragraph',
    'data': {'delta': tailOps},
  };
  return (head, tail);
}

/// Split a table into a head (first [headRows]) and a tail (the rest), each a
/// STANDALONE valid AppFlowy table, so a table too tall for the remaining space
/// flows across the page boundary instead of taking its own (possibly
/// overflowing) sheet.
///
/// AppFlowy's `TableNode` is strict: it rejects a table (renders NOTHING — the
/// "vanishing table" the first attempt hit) unless
///   * `children.length == colsLen * rowsLen`, and
///   * every cell carries `rowPosition` + `colPosition`, and
///   * every (col, row) coordinate in range is covered by exactly one cell.
/// So the head keeps rows `[0, headRows)` verbatim (already valid) and the tail
/// takes rows `[headRows, rowsLen)` with every cell's `rowPosition` shifted down
/// by `headRows` (0-based again). `colsLen`/`colPosition` and every per-cell
/// width/height are untouched — both halves therefore satisfy all three rules.
/// `colsHeight` (a CACHED total pixel height of the whole table) is dropped from
/// both so each recomputes its own; leaving the old total would just be
/// self-corrected by TableNode on first layout, but dropping it is cleaner.
(Block, Block)? _splitTable(Block block, int headLines) {
  final data = _data(block);
  final rows = _int(data['rowsLen']) ?? 0;
  final cols = _int(data['colsLen']) ?? 0;
  if (rows <= 1 || cols < 1) return null;

  // A table renders as `rowsLen` rows + 1 line of chrome (see estimateBlockLines)
  // so `headLines` lines hold `headLines - 1` rows.
  var headRows = headLines - 1;
  if (headRows < 1) headRows = 1;
  if (headRows >= rows) return null; // nothing to move to the tail

  final children = (block['children'] as List?) ?? const [];

  final headCells = <dynamic>[];
  final tailCells = <dynamic>[];
  for (final cell in children) {
    final rp = _int((_data(cell as Block))['rowPosition']);
    if (rp == null) return null; // malformed cell — don't risk a broken split
    if (rp < headRows) {
      headCells.add(_clone(cell));
    } else {
      final moved = _clone(cell);
      (moved['data'] as Map)['rowPosition'] = rp - headRows;
      tailCells.add(moved);
    }
  }

  // Guard the invariant explicitly: if the cell count doesn't match a full
  // colsLen×rowsLen grid on either side, the source table was already irregular
  // (merged/ragged cells we don't model) — keep it atomic rather than emit a
  // table AppFlowy would drop.
  if (headCells.length != cols * headRows ||
      tailCells.length != cols * (rows - headRows)) {
    return null;
  }

  final head = _clone(block);
  (head['data'] as Map)
    ..['rowsLen'] = headRows
    ..remove('colsHeight');
  head['children'] = headCells;

  final tail = _clone(block);
  (tail['data'] as Map)
    ..['rowsLen'] = rows - headRows
    ..remove('colsHeight');
  tail['children'] = tailCells;

  return (head, tail);
}

// --------------------------------------------------------------------------
// Helpers
// --------------------------------------------------------------------------

Map<String, dynamic> _data(Block block) {
  final d = block['data'];
  return d is Map<String, dynamic> ? d : <String, dynamic>{};
}

int? _int(Object? v) => v is num ? v.toInt() : null;

Block _emptyParagraph() => {
      'type': 'paragraph',
      'data': {
        'delta': [
          {'insert': ''},
        ],
      },
    };

/// Deep clone via JSON-safe structures (blocks are plain maps/lists/scalars).
Block _clone(Object? block) => _deep(block) as Block;

Object? _deep(Object? v) {
  if (v is Map) {
    return <String, dynamic>{
      for (final e in v.entries) e.key.toString(): _deep(e.value),
    };
  }
  if (v is List) return [for (final e in v) _deep(e)];
  return v;
}
