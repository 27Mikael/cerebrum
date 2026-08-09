import 'package:flutter/material.dart';
import 'package:scribble/scribble.dart';

/// Freehand ink layer for ONE page, backed by `scribble` instead of
/// `flutter_drawing_board`. This is purely the per-page canvas.
///
/// Tool selection lives elsewhere: a SINGLE radial [ToolDialHub] is mounted
/// once at the editor-screen level (see EditorScaffold), floating above the
/// whole page list and driving the active page's notifier — rather than one
/// dial embedded in every page (which duplicated the button per page and
/// clipped the wheel to a single sheet's bounds). See radial_tool_dial.dart.
///
/// Mouse input on desktop needs to be explicitly allowed — that's
/// handled once, in [NoteEditorController], via
/// `setAllowedPointersMode(ScribblePointerMode.all)`. This widget
/// doesn't need to know about that; it just renders whatever the
/// notifier is configured to accept.
class NoteDrawingLayer extends StatelessWidget {
  const NoteDrawingLayer({super.key, required this.notifier});

  final ScribbleNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Scribble(notifier: notifier);
  }
}
