import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cerebrum_app/ui/editor/controllers/page_paginator.dart' as pg;

/// Regression guard for table pagination. The first attempt at splitting tables
/// re-indexed cells into a shape AppFlowy's `TableNode` rejects — it renders
/// nothing (the "vanishing table"). These tests reconstruct every table the
/// paginator emits through the REAL `TableNode` and assert it's accepted, plus
/// that no rows/columns are lost across the split.

/// True when `TableNode` accepted the table: on rejection it clears its internal
/// cell grid, so colsLen/rowsLen come back 0.
bool _accepted(Map<String, dynamic> block) {
  final tn = TableNode(node: Node.fromJson(Map<String, Object>.from(block)));
  return tn.colsLen > 0 && tn.rowsLen > 0;
}

List<Map<String, dynamic>> _tablesIn(List<List<pg.Block>> pages) => [
      for (final page in pages)
        for (final b in page)
          if (b['type'] == 'table') Map<String, dynamic>.from(b),
    ];

/// Every cell's text in a table (unordered) — a row-split re-partitions the
/// grid, so conservation is checked as a multiset, not a fixed sequence.
List<String> _cellTexts(Map<String, dynamic> block) {
  final tn = TableNode(node: Node.fromJson(Map<String, Object>.from(block)));
  return [
    for (var c = 0; c < tn.colsLen; c++)
      for (var r = 0; r < tn.rowsLen; r++)
        tn.getCell(c, r).children.first.delta?.toPlainText() ?? '',
  ];
}

void main() {
  Map<String, dynamic> makeTable(int cols, int rows) {
    final grid = [
      for (var c = 0; c < cols; c++)
        [for (var r = 0; r < rows; r++) 'c${c}r$r'],
    ];
    return jsonDecode(jsonEncode(TableNode.fromList(grid).node.toJson()))
        as Map<String, dynamic>;
  }

  test('a too-tall table splits into valid, accepted tables', () {
    final block = makeTable(2, 5); // estimates 6 lines
    final pages = pg.paginate([
      [block],
    ], budget: 4); // forces a split (head 3 rows, tail 2)

    final tables = _tablesIn(pages);
    expect(tables.length, greaterThanOrEqualTo(2),
        reason: 'the table should have split across pages');

    var totalRows = 0;
    for (final t in tables) {
      expect(_accepted(t), isTrue,
          reason: 'every split half must be a valid AppFlowy table');
      final tn = TableNode(node: Node.fromJson(Map<String, Object>.from(t)));
      expect(tn.colsLen, 2, reason: 'column count is preserved');
      expect((t['children'] as List).length, tn.colsLen * tn.rowsLen,
          reason: 'children == colsLen * rowsLen (TableNode invariant)');
      totalRows += tn.rowsLen;
    }
    expect(totalRows, 5, reason: 'no rows lost across the split');
  });

  test('split conserves every cell\'s text (no loss/duplication)', () {
    final block = makeTable(3, 6);
    final before = _cellTexts(block)..sort();

    final pages = pg.paginate([
      [block],
    ], budget: 3);
    final tables = _tablesIn(pages);
    expect(tables.length, greaterThanOrEqualTo(2));

    final after = [for (final t in tables) ..._cellTexts(t)]..sort();
    expect(after, before, reason: 'every cell survives the split exactly once');
  });

  test('a single-row table is never split (stays atomic)', () {
    final block = makeTable(3, 1);
    final pages = pg.paginate([
      [block],
    ], budget: 1); // even with no room, a 1-row table can't be divided
    final tables = _tablesIn(pages);
    expect(tables.length, 1, reason: 'nothing to split');
    expect(_accepted(tables.single), isTrue);
  });

  test('a table splits repeatedly across many pages when very tall', () {
    final block = makeTable(2, 12);
    final pages = pg.paginate([
      [block],
    ], budget: 4); // ~3 rows per page -> several pages
    final tables = _tablesIn(pages);
    expect(tables.length, greaterThan(2));
    for (final t in tables) {
      expect(_accepted(t), isTrue);
    }
    final totalRows = tables
        .map((t) => TableNode(node: Node.fromJson(Map<String, Object>.from(t))).rowsLen)
        .fold<int>(0, (a, b) => a + b);
    expect(totalRows, 12, reason: 'all rows survive repeated splitting');
  });
}
