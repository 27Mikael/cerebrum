import 'package:flutter/material.dart';
import 'package:scribble/scribble.dart';
import 'radial_tool_dial.dart';

/// Freehand ink layer, backed by `scribble` instead of
/// `flutter_drawing_board`. Tool selection is [ToolDialHub] — a radial
/// pie menu, not a linear button row. See radial_tool_dial.dart for why
/// it's a fixed launcher button rather than a long-press over the whole
/// canvas.
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
    return Stack(
      children: [
        Positioned.fill(child: Scribble(notifier: notifier)),
        Positioned.fill(child: ToolDialHub(notifier: notifier)),
      ],
    );
  }
}
