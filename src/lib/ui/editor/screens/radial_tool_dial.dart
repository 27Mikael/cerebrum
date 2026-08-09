import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:scribble/scribble.dart';

/// The eight tools on the dial, clockwise from the top. Order here is
/// the source of truth for wedge layout — [_ToolDialHubState._angleToTool]
/// and [_DialPainter] both derive wedge position from this map's order,
/// so don't reorder without checking both.
enum _DialTool {
  penBlack,
  penPurple,
  penTeal,
  penCoral,
  highlighter,
  eraser,
  undo,
  redo,
}

class _WedgeSpec {
  const _WedgeSpec({required this.icon, required this.color});
  final IconData icon;
  final Color color;
}

final _wedgeSpecs = <_DialTool, _WedgeSpec>{
  _DialTool.penBlack: _WedgeSpec(icon: Icons.edit, color: Colors.black),
  _DialTool.penPurple: _WedgeSpec(icon: Icons.edit, color: Colors.deepPurple),
  _DialTool.penTeal: _WedgeSpec(icon: Icons.edit, color: Colors.teal),
  _DialTool.penCoral: _WedgeSpec(icon: Icons.edit, color: Colors.deepOrange),
  _DialTool.highlighter: _WedgeSpec(
    icon: Icons.border_color,
    color: Colors.amber,
  ),
  _DialTool.eraser: _WedgeSpec(
    icon: Icons.cleaning_services,
    color: Colors.pinkAccent,
  ),
  _DialTool.undo: _WedgeSpec(icon: Icons.undo, color: Colors.blueGrey),
  _DialTool.redo: _WedgeSpec(icon: Icons.redo, color: Colors.blueGrey),
};

const double _outerRadius = 110;
const double _innerRadius = 46;
final double _wedgeAngle = 2 * math.pi / _wedgeSpecs.length;

/// Fixed-... no — FLOATING launcher for the radial tool picker, draggable
/// anywhere within the canvas. Two distinct gestures share this one
/// button, resolved by Flutter's gesture arena rather than anything
/// custom here:
///
///  - Hold still for ~500ms: the wheel opens (this used to fire on the
///    very first touch via onPanDown, before any movement, to avoid a
///    laggy hold with zero feedback — see the git history if you go
///    looking for that). Now that the same button also needs to be
///    freely draggable, "any touch-and-drag opens the wheel" and "drag
///    to move the button" can't both be true, so opening the wheel had
///    to move behind an actual hold. Drag out from there, same as
///    before, and release over a wedge to pick it.
///  - Move before that hold timer fires: it's a plain drag instead, and
///    repositions the button. `onPanUpdate` needs no `onPanStart` —
///    Flutter's `PanGestureRecognizer` works fine driven off `onUpdate`
///    alone.
///
/// This is still its own small gesture surface rather than a long-press
/// layered over the whole [Scribble] canvas, for the reason the original
/// version already got right: Scribble almost certainly does its own raw
/// pointer handling for drawing latency, and racing a recognizer against
/// that across the entire drawing area is the kind of gesture-arena
/// conflict that's easy to get wrong. Keeping the gesture scoped to this
/// one button sidesteps that entirely.
class ToolDialHub extends StatefulWidget {
  const ToolDialHub({super.key, required this.notifier, this.onSelectTool});

  /// The ACTIVE page's ink notifier — drives the hub's current-tool indicator
  /// and receives undo/redo (which are page-local actions, not tools).
  final ScribbleNotifier notifier;

  /// Called when a persistent tool (pen / highlighter / eraser) is picked, with
  /// a mutation to apply to a notifier. The owner (PagedNoteController) broadcasts
  /// it to every page so the tool FOLLOWS across pages. When null, the tool is
  /// applied directly to [notifier] (single-surface fallback).
  final void Function(void Function(ScribbleNotifier) config)? onSelectTool;

  @override
  State<ToolDialHub> createState() => _ToolDialHubState();
}

class _ToolDialHubState extends State<ToolDialHub> {
  final GlobalKey _hubKey = GlobalKey();

  // Approximate on-screen diameter of the hub button (14px padding each
  // side + a 22px icon ≈ 50px, rounded up). Only used to keep the button
  // from being dragged partially off-screen — doesn't need to track the
  // real render size pixel-for-pixel for that purpose.
  static const double _hubSize = 56;

  bool _open = false;
  Offset _center = Offset.zero; // global center, for wedge-angle math
  _DialTool? _highlighted;

  // Top-left of the hub button, in this widget's own local coordinate
  // space. Null until the first LayoutBuilder pass gives us bounds to
  // seed a sensible default position (bottom-center) — see
  // _defaultTopLeft below.
  Offset? _hubTopLeft;

  Offset _defaultTopLeft(BoxConstraints constraints) {
    return Offset(
      (constraints.maxWidth - _hubSize) / 2,
      constraints.maxHeight - _hubSize - 24,
    );
  }

  // Holding still opens the wheel — same wedge-picking mechanics as
  // before, just triggered by LongPress callbacks instead of Pan ones.
  void _handleWheelStart(LongPressStartDetails details) {
    final box = _hubKey.currentContext!.findRenderObject() as RenderBox;
    _center = box.localToGlobal(box.size.center(Offset.zero));
    setState(() {
      _open = true;
      _highlighted = _angleToTool(details.globalPosition);
    });
  }

  void _handleWheelUpdate(LongPressMoveUpdateDetails details) {
    setState(() => _highlighted = _angleToTool(details.globalPosition));
  }

  void _handleWheelEnd(LongPressEndDetails details) {
    // LongPressEndDetails carries velocity, not position — same reason
    // as the old DragEndDetails comment: commit whatever wedge the last
    // move event computed rather than re-deriving it here.
    final chosen = _highlighted;
    setState(() {
      _open = false;
      _highlighted = null;
    });
    if (chosen != null) _applyTool(chosen);
  }

  // Moving before the long-press timer fires repositions the button
  // instead of opening the wheel — this is what the gesture arena routes
  // a quick drag to.
  void _handleDragUpdate(
    DragUpdateDetails details,
    BoxConstraints constraints,
  ) {
    setState(() {
      final current = _hubTopLeft ?? _defaultTopLeft(constraints);
      final next = current + details.delta;
      _hubTopLeft = Offset(
        next.dx.clamp(0, constraints.maxWidth - _hubSize),
        next.dy.clamp(0, constraints.maxHeight - _hubSize),
      );
    });
  }

  _DialTool? _angleToTool(Offset globalPosition) {
    final delta = globalPosition - _center;
    // Inside the dead zone — no wedge selected, so releasing here cancels.
    if (delta.distance < _innerRadius * 0.6) return null;

    // atan2(dx, -dy): 0 = straight up, increasing clockwise. Matches the
    // bearing convention used to lay out wedges in [_DialPainter].
    var angle = math.atan2(delta.dx, -delta.dy);
    if (angle < 0) angle += 2 * math.pi;
    final index = (angle / _wedgeAngle).floor() % _wedgeSpecs.length;
    return _wedgeSpecs.keys.elementAt(index);
  }

  void _applyTool(_DialTool tool) {
    switch (tool) {
      case _DialTool.penBlack:
      case _DialTool.penPurple:
      case _DialTool.penTeal:
      case _DialTool.penCoral:
        final color = _wedgeSpecs[tool]!.color;
        _selectTool((n) {
          n.setColor(color);
          n.setStrokeWidth(4);
        });
        break;
      case _DialTool.highlighter:
        _selectTool((n) {
          n.setColor(Colors.yellow.withValues(alpha: 0.4));
          n.setStrokeWidth(16);
        });
        break;
      case _DialTool.eraser:
        _selectTool((n) => n.setEraser());
        break;
      // Undo/redo are page-LOCAL actions, not persistent tools — they run on the
      // active page's notifier and are never broadcast/remembered.
      case _DialTool.undo:
        if (widget.notifier.canUndo) widget.notifier.undo();
        break;
      case _DialTool.redo:
        if (widget.notifier.canRedo) widget.notifier.redo();
        break;
    }
  }

  /// Route a persistent tool selection through [ToolDialHub.onSelectTool] so it
  /// FOLLOWS across pages; fall back to the active notifier when unset.
  void _selectTool(void Function(ScribbleNotifier) config) {
    final onSelect = widget.onSelectTool;
    if (onSelect != null) {
      onSelect(config);
    } else {
      config(widget.notifier);
    }
  }

  /// Which wedge's look the hub itself should borrow — the hub always
  /// mirrors the currently active tool, same as the old toolbar's
  /// active-icon highlight did.
  _WedgeSpec _currentSpec(ScribbleState state) {
    if (state is Erasing) return _wedgeSpecs[_DialTool.eraser]!;
    if (state is Drawing) {
      final color = Color(state.selectedColor);
      return _wedgeSpecs.values.firstWhere(
        (spec) => spec.color.toARGB32() == color.toARGB32(),
        orElse: () => _wedgeSpecs[_DialTool.penBlack]!,
      );
    }
    return _wedgeSpecs[_DialTool.penBlack]!;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final topLeft = _hubTopLeft ?? _defaultTopLeft(constraints);

        // `_center` is in global (screen) coordinates — correct for the
        // angle math in `_angleToTool`, since the LongPress details are
        // also global. But `Positioned.left/top` below are relative to
        // this Stack, not the screen, so it needs converting back
        // before use.
        // Only resolve the global→local transform while the dial is OPEN, and
        // guard on a non-null render object. (`localCenter` is only read by the
        // `if (_open)` branch; when closed it stays Offset.zero and is unused.)
        // The dial is now a single overlay at the editor-screen level, not one
        // instance per page inside a lazy ListView, so the old "sliver child
        // layoutOffset is null for offscreen pages → Null check operator" crash
        // no longer applies — but keeping the guard is harmless and defensive.
        final stackBox = context.findRenderObject() as RenderBox?;
        final localCenter = (_open && stackBox != null)
            ? stackBox.globalToLocal(_center)
            : Offset.zero;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            if (_open)
              Positioned(
                left: localCenter.dx - _outerRadius,
                top: localCenter.dy - _outerRadius,
                width: _outerRadius * 2,
                height: _outerRadius * 2,
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _DialPainter(highlighted: _highlighted),
                  ),
                ),
              ),
            Positioned(
              left: topLeft.dx,
              top: topLeft.dy,
              child: GestureDetector(
                onLongPressStart: _handleWheelStart,
                onLongPressMoveUpdate: _handleWheelUpdate,
                onLongPressEnd: _handleWheelEnd,
                onPanUpdate:
                    (details) => _handleDragUpdate(details, constraints),
                child: ValueListenableBuilder<ScribbleState>(
                  valueListenable: widget.notifier,
                  builder: (context, state, _) {
                    final spec = _currentSpec(state);
                    return Material(
                      key: _hubKey,
                      color: spec.color,
                      shape: const CircleBorder(),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Icon(spec.icon, color: Colors.white, size: 22),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DialPainter extends CustomPainter {
  _DialPainter({required this.highlighted});

  final _DialTool? highlighted;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    var i = 0;

    for (final entry in _wedgeSpecs.entries) {
      final startAngle =
          -math.pi / 2 + i * _wedgeAngle; // 0 = top, canvas angle
      final isActive = entry.key == highlighted;

      final path =
          Path()
            ..moveTo(
              center.dx + _innerRadius * math.cos(startAngle),
              center.dy + _innerRadius * math.sin(startAngle),
            )
            ..arcTo(
              Rect.fromCircle(center: center, radius: _outerRadius),
              startAngle,
              _wedgeAngle,
              false,
            )
            ..lineTo(
              center.dx + _innerRadius * math.cos(startAngle + _wedgeAngle),
              center.dy + _innerRadius * math.sin(startAngle + _wedgeAngle),
            )
            ..arcTo(
              Rect.fromCircle(center: center, radius: _innerRadius),
              startAngle + _wedgeAngle,
              -_wedgeAngle,
              false,
            )
            ..close();

      canvas.drawPath(
        path,
        Paint()
          ..color = entry.value.color.withValues(alpha: isActive ? 0.95 : 0.5),
      );

      final midAngle = startAngle + _wedgeAngle / 2;
      final iconRadius = (_outerRadius + _innerRadius) / 2;
      final iconCenter =
          center + Offset(math.cos(midAngle), math.sin(midAngle)) * iconRadius;

      final tp = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(entry.value.icon.codePoint),
          style: TextStyle(
            fontSize: isActive ? 22 : 18,
            fontFamily: entry.value.icon.fontFamily,
            package: entry.value.icon.fontPackage,
            color: Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, iconCenter - Offset(tp.width / 2, tp.height / 2));

      i++;
    }

    canvas.drawCircle(center, _innerRadius, Paint()..color = Colors.white);
    canvas.drawCircle(
      center,
      _innerRadius,
      Paint()
        ..color = Colors.black12
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _DialPainter oldDelegate) =>
      oldDelegate.highlighted != highlighted;
}
