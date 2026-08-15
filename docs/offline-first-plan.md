# TODO: Offline-first client persistence

**Status: DONE (phases 1-4).** Planned 2026-08-09, implemented 2026-08-10 — see
`changelog/2026-08-10.md`. Remaining items are daemon-side or explicitly v2
(cross-device image serving, client-owned page ids, stronger conflict handling).

## Why this exists
The app is meant to be **offline-first**, but today the client persists notes
**only on the daemon**:
- No on-device note store (only `shared_preferences` for session/settings/sync metadata).
- Reads are live from the daemon (`fetchNotes`, `fetchNoteByFileName`) — tunnel/cloud down → nothing loads.
- Saves go straight to the daemon (`EditorScaffold._save` → `BubbleNotesApi.updateNote` → `PUT /update`), synchronously — offline → the save throws and the edit is lost on close.
- `SyncService` (replica id + per-note version vectors + outbox) is **dead code**: its `pushNote` is never called (the whole-page-set `/update` refactor bypassed it), so the outbox is never filled and `drainOutbox()` is a no-op.
- Images are daemon-only (absolute URL + `Image.network`) — no offline render, upload fails offline.

So over zrok/cloud: online-only. This doc is the plan to fix it.

## Decisions locked
- **Local store backing:** JSON files that mirror the daemon note-folder shape (via `path_provider`). No SQL DB.
- **First slice:** TBD — confirm whether phase 1 ("writes never lost offline") ships first.
- **Conflict model (v1):** last-writer-wins per page (what `/update`'s per-`page_id` diff already does). Confirm acceptable.

## On-device layout (mirrors the daemon)
```
<appDocs>/cerebrum/bubbles/<bubble_id>/notes/<note_id>/
    note.json      # canonical client copy: manifest fields + pages:[{page_id,page_index,document,ink}] (== toPagesJson())
    images/<name>  # cached image bytes (same <ulid>.<ext> names the daemon uses)
    .sync.json     # per-note sync state: version_vector, dirty, last_pushed_at, deleted (tombstone)
<appDocs>/cerebrum/bubbles/<bubble_id>/notes/_index.json  # list for the notes screen
```
Daemon-only sidecars (history/analysis) are NOT mirrored — they refetch when online.

## Work items (phased, each shippable)

### Phase 1 — writes never lost offline  *(the core)*  ✅
- [x] Add `path_provider` dep.
- [x] New `lib/services/note_store.dart` — the only filesystem toucher: `listNotes / readNote / writeNote / markDeleted+purge / readImage / writeImage` + sync-state getters/setters.
- [x] `EditorScaffold._save` → write to `NoteStore` first (always succeeds), mark dirty, enqueue sync, then best-effort push. *(Version vectors dropped — the `/update` diff is per-page LWW, no vv in the body.)*
- [x] Rewire `SyncService` outbox to the **whole-page-set `/update`** contract (`BubbleNotesApi.updateNote`) instead of the retired `pushNote`; adopt the merged server response on success, clear dirty.
- [x] `main.dart` — `drainOutbox()` on app start AND resume. Reconnect handled by SyncService's auto-drain poll (no connectivity dep).

### Phase 2 — local-first reads  ✅
- [x] `d_study_bubble_page.loadNotes` → read local `_index.json` first, then background-refresh from daemon when reachable (keeps local-only/unsynced notes).
- [x] `_openNote` → `NoteStore.readNote` first; background `fetchNoteByFileName` refresh if online and not locally-dirty.

### Phase 3 — images offline + URL-fragility fix  ✅
- [x] On insert: `NoteStore.writeImage` locally + embed a **stable ref** (`cerebrum-image://<note_id>/<name>`), not an absolute daemon URL; queue the upload.
- [x] Image resolver (`note_image_resolver.dart`): ref → local file if cached, else recorded daemon URL. (Also fixes "absolute URL breaks when baseUrl changes".) Transform happens at load/save boundaries (AppFlowy's image component left untouched).

### Phase 4 — client-owned identity / offline create  ✅
- [x] Mint `note_id` (ULID, `lib/services/id.dart`) **client-side** so notes exist locally before the daemon sees them; `createNote` is now "first push of a local note". `addNote` works fully offline.
- Note: page ids kept as `p{n}` — client-owned page ids would need a coordinated daemon change (per-page analysis keys on them).

## Reachability & triggers
- Gate background sync on a connectivity/"last request succeeded" check. Trigger `drainOutbox` on: app start, resume, reconnect, and after each local save (best-effort).

## Files touched (summary)
- **New:** `lib/services/note_store.dart`, image-ref resolver widget, `path_provider` dep.
- **Rewire:** `lib/services/sync_service.dart`, `lib/main.dart`.
- **Reads:** `lib/ui/screens/study_bubble/d_study_bubble_page.dart`.
- **Writes:** `lib/ui/editor/editor_scaffold.dart`, `lib/api/bubbles_api.dart`.
- **Daemon:** minor — accept a client-supplied `note_id` on create (likely already via `NoteIn.note_id`); `/update` already reconciles whole page sets, so no big server change.

## Open questions / risks
- **Deletes offline** need tombstones (`.sync.json` deleted flag) so a background refresh can't resurrect a locally-deleted note.
- **Analysis/highlights** are daemon-computed → stay online-only, degrade gracefully offline.
- **Image cache growth** needs an eviction policy eventually (not v1).
- **Stronger conflict handling** (carry `version_vector` in the `/update` body + daemon merge) is explicitly OUT of scope for v1 — that path previously dropped edits / couldn't delete pages.
