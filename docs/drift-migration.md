# Drift migration for engram records — APPLIED

**Status: DONE.** 2026-08-11. Engram **records & queues** now live in Drift
(SQLite) via `lib/services/db/app_database.dart` (+ committed
`app_database.g.dart`). `EngramAttemptStore` and `OfflineMastery` are Drift-backed
behind their original public APIs, so callers (`EngramSyncService`, the completion
screens) didn't change. Notes stay JSON files mirroring the daemon folder shape.

## The codegen gotcha (and the fix): `--force-jit`

Plain `build_runner` fails in this environment:

```
E 'dart compile' does not support build hooks, use 'dart build' instead.
```

Root cause: Dart **3.10.9** (Flutter 3.38.10) refuses `dart compile` when any
package in the graph has a native-assets **build hook**, and this app already
pulls **`objective_c` 9.5.0** (hooked) transitively. `build_runner` AOT-compiles
its builder with `dart compile`, so it dies before generating. This blocks **all**
codegen (json_serializable, etc.) on this SDK, not just drift.

**Fix:** force build_runner to run its builder in **JIT** mode (`dart run`, which
doesn't hit the guard). Regenerate after any schema change with:

```
flutter pub run build_runner build --force-jit
```

(`--delete-conflicting-outputs` is ignored in JIT mode; harmless.) `dart build`
is unrelated — it builds executables, it does not run build_runner.

## Layout

- `lib/services/db/app_database.dart` — tables `EngramAttempts`
  (`@DataClassName('EngramAttemptRow')` to avoid clashing with the
  `EngramAttempt` domain model) and `EngramMasteryRows`, plus DAO query methods.
  Opens `<appDocs>/cerebrum/cerebrum.db` via `NativeDatabase`.
- `app_database.g.dart` — generated; **commit it** (tracked, not gitignored).
- Runtime native lib via `sqlite3_flutter_libs`. That package's build hook only
  affected `dart compile`/build_runner (bypassed with `--force-jit`);
  `flutter run/build` support native assets natively.

## Notes / follow-ups

- Old interim JSON files (`cerebrum/engrams/attempts|mastery/*.json`) are NOT
  auto-migrated — fine for fresh installs; write a one-time importer if real data
  exists.
- Reactivity: tables are ready for `watch*` streams so the badge / completion
  screens can auto-update. Stores currently expose the same Future-based APIs
  (drop-in); converting `Notifications.badgeCount` to a `watch` stream is the
  natural next enhancement.
- Linux desktop needs a sqlite3 lib at runtime (mobile/macOS/Windows covered by
  `sqlite3_flutter_libs`).
- Scope: engram attempts + mastery are in Drift; the note/image/delete outboxes
  in `SyncService` remain `shared_preferences` (optional to move later).
