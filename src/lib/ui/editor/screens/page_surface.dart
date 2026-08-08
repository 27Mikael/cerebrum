import 'package:flutter/material.dart';
import 'package:cerebrum_app/ui/editor/controllers/note_editor_controller.dart';
import 'package:cerebrum_app/ui/editor/screens/drawing_layer.dart';

/// One page of a note: a fixed-aspect "sheet" (A4 portrait) holding the text
/// editor + ink layer, stacked — the paged equivalent of EditorSurface, bounded
/// to a page instead of filling the screen.
///
/// Ink is naturally page-LOCAL: each page has its own bounded scribble widget,
/// so strokes are relative to this sheet, not a global surface.
///
/// UNVERIFIED (no flutter tooling here) — run `flutter analyze`.
/// TODO(flutter): for pixel-identical strokes across devices of different
/// widths, normalise ink coords (0..1) on save/load. A refinement, not needed
/// for a first working cut.
class PageSurface extends StatelessWidget {
  const PageSurface({
    super.key,
    required this.controller,
    required this.drawingEnabled,
    this.pageNumber,
    this.aspectRatio = 1 / 1.414, // A4 portrait
  });

  final NoteEditorController controller;
  final bool drawingEnabled;
  final int? pageNumber;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                return Stack(
                  children: [
                    // Text layer — absorbs pointers while drawing so strokes
                    // don't also move the caret (same pattern as EditorSurface).
                    AbsorbPointer(
                      absorbing: drawingEnabled,
                      child: controller.driver.buildEditor(context),
                    ),
                    // Ink layer — only receptive to pointers while drawing.
                    IgnorePointer(
                      ignoring: !drawingEnabled,
                      child:
                          NoteDrawingLayer(notifier: controller.drawingNotifier),
                    ),
                    if (pageNumber != null)
                      Positioned(
                        right: 8,
                        bottom: 6,
                        child: IgnorePointer(
                          child: Text(
                            '$pageNumber',
                            style: const TextStyle(
                              color: Colors.black38,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
