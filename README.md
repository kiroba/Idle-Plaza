# Omni Plaza (repo: Idle-Plaza)

Omni Plaza for The Omniverse — the living shared plaza where your Halo lives. Split out of [kiroba/The-Omniverse](https://github.com/kiroba/The-Omniverse) with its git history (Oct 30 2026).

**Name note (Nov 16, 2026):** the Plaza was renamed from Idle Plaza to **Omni Plaza** on Nov 14, 2026 — it is alive, not idle. Docs use the new name now. This repo's name, the Android package (`com.omniverse.idle_plaza`) and the other code paths keep the old name until the rename sweep, which is parked until after the Nov 28, 2026 playtest.

**Roadmap:** games are places in the Plaza — the small Flutter games, Plaza Brawler and 9x9 each get a location to walk up to and play, and user-created games get a home there too. The first scenery set (storefronts, a big events billboard, trees) is being built locally; it is not shipped yet.

## Build
```
flutter pub get
flutter build apk --release --target-platform android-arm64
```
Shared code comes from [Omni-Core-UI](https://github.com/kiroba/Omni-Core-UI), pinned by tag in `pubspec.yaml`. Android package: `com.omniverse.idle_plaza`.

CI here makes test builds (debug key). Signed releases still come from the monorepo's `release.yml` until release orchestration moves.

`tool/build_multi_app_suite.py` is the old generator, kept for reference.
