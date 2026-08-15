# Tool Wheel — plan (Concepts-inspired radial tool)

Inspiration: the **Concepts app** Tool Wheel. Goal: evolve `ToolDialHub`
(`lib/ui/editor/screens/radial_tool_dial.dart`) from a single ring of fixed
wedges into a **concentric-ring wheel** with real colour + tool control, sized
and placed to taste.

## Target anatomy (Concepts), center → out
1. **Center** — the active **colour** (fill) + **selected tool** (icon). In
   Concepts, tapping it opens the full brush/colour library.
2. **Values ring** — quick numeric controls with live readouts: brush **size**
   (px/pts), **opacity**, **smoothing**. Drag one → a slider fans out with snap
   stops (0/10/25/100 %) plus a big arc gauge.
3. **Tool/brush slots ring** — assignable "petals": undo/redo, eraser, and brush
   presets. User-customisable favourites.
4. **Colour ring** — a hue ring that blooms into a full radial palette
   (HSL / RGB / marker-library modes) with a recents bar.

## Interactions
- Tap a wedge/petal → select tool. Tap/scrub the colour ring → pick colour.
- Drag a value → fan-out slider (snap + fine drag) with live readout.
- Wheel is **movable** (drag) and **resizable** (pinch on touch / scroll on
  desktop), and collapsible/dockable.

---

## Phased build

### Phase 1 — NOW (completes basic functionality)  ✅ building
Concentric restructure + colour + resize. Enough to actually draw in any colour
with a clear tool/colour readout.
- [ ] **Center ring** shows the current colour (fill) + selected tool (icon).
- [ ] **Tool ring**: tappable wedges — pen, highlighter, eraser, undo, redo.
- [ ] **Colour wheel ring**: a continuous **hue ring**; tap/drag picks the colour
      (full saturation/value for v1). Applies to pen/highlighter via the existing
      `onSelectTool` broadcast so it follows across pages.
- [ ] **Resize**: two-finger pinch (touch/trackpad) + mouse-wheel scroll
      (desktop) — a `_scale` factor, clamped. Still **draggable** to reposition.
- [ ] Keep the existing public API (`ToolDialHub(notifier, onSelectTool)`) so the
      scaffold mounting is unchanged.

### Phase 2 — value sliders  ✅ (size)
- [x] Inner **size ring**: per-tool brush **size** with a drag-to-change gauge +
      live "N px" readout. Pen and highlighter each remember their own size,
      persisted in `<appDocs>/cerebrum/editor/settings.json`.
- [x] Wire size to the Scribble notifier (`setStrokeWidth`) via `onSelectTool`.
- [ ] Opacity control (still hardcoded: highlighter alpha 0.4).

### Phase 3 — richer colour  ✅ (mostly)
- [x] Copic-style wheel (12 hue × 5 shade), **rotatable** by dragging it.
- [x] Per-swatch **hex labels** + an active-colour hex/name readout pill.
- [x] **Custom colours**: a "+" slot opens an HSV picker; saved swatches persist
      in `<appDocs>/cerebrum/editor/palette.json` (`{hex, name}`) and appear in
      the wheel's custom ring. See `lib/services/editor_settings_store.dart`.
- [ ] Optional 2-D S/V picker + HSL/RGB entry modes (custom dialog is HSV-only).

### Phase 3.5 — v2 structure: fixed hub + big rotating wheel  ✅
Reapproach (see `radial_tool_dial.dart` header). Both layers share one draggable
`_anchor`:
- [x] **Fixed hub** (scales with `_hubScale`): center disc, tool chips at fixed
      bearings (`_ctlLayout`), draggable "N px" size readout, colour readout, "+".
- [x] **Constant-size colour wheel** (`_kWheelInnerR.._kWheelOuterR`): large
      enough to run **off-screen** when docked in a corner; **drag rotates** it
      360°, **tap a visible swatch** picks. Swatch size never changes.
- [x] **Resize scales the hub only**; wheel stays constant. Configurable **min +
      max** hub size (long-press the center), persisted in `settings.json`.
- [x] **`_DiscHitRegion`** gates pointers to the visible disc so you can still
      draw around/under the huge wheel (strokes fall through elsewhere).

### Phase 4 — customisable slots + library
- [ ] Assignable tool/brush slots (long-press a petal → choose what it holds).
- [ ] Link the center to a full **brush/colour library** sheet.

### Phase 5 — polish
- [ ] Collapse/dock to a corner; spring-open animation; haptics; the wheel
      following the pen while open.

---

## Notes / decisions
- **Colour model change:** a hue ring means the pen is colour-agnostic (one pen +
  wheel), replacing the 4 fixed-colour pens. That matches Concepts and unlocks any
  colour. Highlighter reuses the picked colour with alpha; eraser is colourless.
- **Desktop resize:** no pinch on a mouse, so mouse-wheel scroll over the wheel
  resizes it (touch/trackpad still pinch). Documented in code.
- **Why keep `onSelectTool`:** it broadcasts the tool/colour to every page's ink
  notifier, so a picked pen/colour follows across pages (see PagedNoteController).
