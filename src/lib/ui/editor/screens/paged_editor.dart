import 'package:flutter/material.dart';
import 'package:cerebrum_app/ui/editor/controllers/paged_note_controller.dart';
import 'package:cerebrum_app/ui/editor/screens/page_surface.dart';

/// Renders a note's pages as either a **vertical** continuous scroll (default,
/// document feel) or a **horizontal** PageView (slideshow), switchable at
/// runtime via [PagedNoteController.layout]. Both iterate the same [PageSurface],
/// so the layout is just a scroll-widget choice. A trailing "add page" tile
/// appends a blank page.
///
/// UNVERIFIED (no flutter tooling here) — run `flutter analyze`.
class PagedEditor extends StatefulWidget {
  const PagedEditor({super.key, required this.controller});

  final PagedNoteController controller;

  @override
  State<PagedEditor> createState() => _PagedEditorState();
}

class _PagedEditorState extends State<PagedEditor> {
  final PageController _pageViewController = PageController();

  @override
  void dispose() {
    _pageViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final c = widget.controller;
        final pages = c.pages;
        final itemCount = pages.length + 1; // + trailing "add page" tile

        Widget itemAt(int i) {
          if (i == pages.length) {
            return _AddPageTile(onAdd: c.addPage);
          }
          return Padding(
            padding: const EdgeInsets.all(12),
            // Touching a page makes it the ACTIVE page. In vertical scroll mode
            // nothing else tracks which page you're on, and the single
            // screen-level drawing dial drives the active page's notifier — so
            // without this, drawing / undo / redo would target the wrong page.
            // A passive Listener observes pointer-down without entering the
            // gesture arena, so it doesn't interfere with drawing or text input.
            child: Listener(
              behavior: HitTestBehavior.deferToChild,
              onPointerDown: (_) => c.setActive(i),
              // Key by controller identity: pages keep the same element across
              // normal rebuilds (preserving editor/scroll state), but a page
              // whose controller was replaced — e.g. the freshly-merged page
              // after a backspace-merge — gets a new key and REMOUNTS, so its
              // `autoFocus` fires and the caret lands at the merge seam.
              child: PageSurface(
                key: ObjectKey(pages[i].controller),
                controller: pages[i].controller,
                drawingEnabled: c.drawingEnabled,
                pageNumber: i + 1,
              ),
            ),
          );
        }

        if (c.layout == PageLayoutMode.horizontal) {
          return PageView.builder(
            controller: _pageViewController,
            itemCount: itemCount,
            onPageChanged: c.setActive,
            itemBuilder: (context, i) => itemAt(i),
          );
        }
        return ListView.builder(
          itemCount: itemCount,
          itemBuilder: (context, i) => itemAt(i),
        );
      },
    );
  }
}

class _AddPageTile extends StatelessWidget {
  const _AddPageTile({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: OutlinedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add),
          label: const Text('Add page'),
        ),
      ),
    );
  }
}
