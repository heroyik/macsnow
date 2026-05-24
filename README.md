# Xsnow for macOS

Xsnow for macOS is a lightweight menu bar prototype that renders falling snow across connected macOS displays without blocking normal app interaction.

The project is currently at **main implementation 1.20 start**. The repository version is `1.20.0`, stored in `VERSION`. The repository includes product requirements, architecture notes, an MVP spec, an MVP implementation plan, validation notes, distribution notes, performance notes, and a SwiftPM-based AppKit/SpriteKit prototype.

## Current Status

Completed so far:

- Defined initial version `0.1.0`.
- Defined MVP 0.2 feature and architecture scope.
- Created repository contributor guide in `AGENTS.md`.
- Reviewed `1.XSNOW PRD.md` and identified requirement risks around performance targets, permissions, fullscreen behavior, and testability.
- Added an `MVP v0.1` scope section to `1.XSNOW PRD.md`.
- Added an `MVP v0.1` architecture section to `2.XSNOW ADD.md`.
- Added `3.MVP 0.1 IMPLEMENTATION PLAN.md`.
- Started MVP 0.1 implementation with a Swift Package Manager project.
- Started MVP 0.2 implementation with persisted settings, density control, wind presets, per-display toggles, and debug status.
- Started MVP 0.3 implementation with a throttled window layout scanner and debug window count.
- Started MVP 0.4 implementation with CoreGraphics-to-AppKit window bounds conversion and per-display top-edge collision body wiring.
- Started MVP 0.5 implementation with lightweight per-window top-edge snow accumulation visualization.
- Started MVP 0.6 implementation with lightweight collapse animation when a tracked window edge disappears or moves.
- Started MVP 0.7 implementation with a persisted menu toggle for window accumulation and collapse effects.
- Added current version display to the menu.
- Started MVP 0.8 implementation with a menu command to clear accumulated window snow.
- Started MVP 0.9 implementation with persisted accumulation rate presets.
- Started MVP 1.0 implementation with adaptive window scanner lifecycle management.
- Added `4.MVP 1.1 VALIDATION PLAN.md` with a repeatable manual validation matrix.
- Added overlay level tuning, edge debug rendering, bounded accumulation nodes, refined accumulation caps, coordinate mapping extraction, centralized app version, and distribution checklist notes for MVP 1.2 through 1.8.
- Added `6.MVP SPEC.md` as the consolidated MVP specification.
- Started MVP 1.9 implementation with a bounded SpriteKit physics flake layer that collides with tracked window top edges.
- Started MVP 1.10 implementation by feeding physics flake contacts into accumulation height.
- Started MVP 1.11 implementation with persisted Physics Quality presets for flake count, spawn rate, and contact-driven growth.
- Started main implementation with a zero-dependency `.app` bundle build script.
- Refined window-edge accumulation rendering with layered drifts, highlights, and small snow clumps.
- Added persisted Accumulation Style presets for Soft, Layered, and Detailed rendering.
- Added bottom snow drift, lightweight seasonal objects, and a recurring Santa/sleigh loop.
- Added Fullscreen Friendly overlay level for less intrusive fullscreen and Stage Manager tuning.
- Added `7.PERFORMANCE LOG.md` for Activity Monitor-based performance recording.
- Confirmed Light wind as the default and restored saved Wind menu selection on relaunch.
- Added the generated Santa/sleigh image as a bundled SpriteKit asset with smoother crossing motion.
- Added persisted Small Flake Accumulation and Spill When Full options.
- Hardened settings loading so older saved preferences keep working when new fields are added.
- Replaced the Santa/sleigh asset with the Xsnow-inspired generated image and changed Santa motion to a natural snowy mountain ride path.
- Replaced the Santa/sleigh asset with a more classic Xsnow-style retro sprite asset.
- Removed Santa/sleigh display logic and the bundled Santa/sleigh image asset.
- Verified `swift build` succeeds.

## MVP 0.1 Scope

Included:

- Menu bar only macOS app using `NSStatusItem`
- No Dock icon via accessory app activation policy
- Multi-display detection through `NSScreen.screens`
- One transparent overlay `NSWindow` per display
- Click-through overlay behavior with `ignoresMouseEvents = true`
- Basic SpriteKit snow animation using `SKEmitterNode`
- Global Start/Stop Snow menu control
- Sleep/wake pause and resume handling
- Overlay rebuild on display topology changes

Excluded from MVP 0.1:

- Third-party window collision via `CGWindowListCopyWindowInfo`
- Snow accumulation on app windows
- Window movement collapse physics
- Per-display settings
- Persistent preferences
- Santa, seasonal objects, wind effects, and advanced particle physics
- Signing, notarization, auto-update, or Mac App Store packaging

## Project Structure

```text
.
├── 1.XSNOW PRD.md
├── 2.XSNOW ADD.md
├── 3.MVP 0.1 IMPLEMENTATION PLAN.md
├── 4.MVP 1.1 VALIDATION PLAN.md
├── 5.DISTRIBUTION CHECKLIST.md
├── 6.MVP SPEC.md
├── 7.PERFORMANCE LOG.md
├── AGENTS.md
├── Package.swift
├── Scripts/
│   └── build_app_bundle.sh
└── Sources/
    └── Xsnow/
        ├── AppDelegate.swift
        ├── DisplayController.swift
        ├── DisplayDetector.swift
        ├── DisplayIdentity.swift
        ├── OverlayWindow.swift
        ├── SettingsStore.swift
        ├── SnowScene.swift
        ├── StatusMenuController.swift
        ├── WindowLayoutScanner.swift
        ├── XsnowManager.swift
        └── main.swift
```

## Key Components

- `main.swift`: starts `NSApplication` in accessory mode.
- `AppDelegate`: creates and starts `XsnowManager`.
- `XsnowManager`: orchestrates menu state, display overlays, and sleep/wake handling.
- `StatusMenuController`: owns the menu bar item and Start/Stop/Quit actions.
- `DisplayDetector`: watches macOS display configuration changes.
- `DisplayIdentity`: creates stable display identifiers and user-facing display labels.
- `DisplayController`: owns one overlay window and SpriteKit scene per display.
- `OverlayWindow`: transparent, borderless, click-through AppKit window with configurable overlay level.
- `SettingsStore`: persists global and per-display settings through `UserDefaults`.
- `SnowScene`: simple SpriteKit falling snow particle scene.
- `WindowLayoutScanner`: samples visible third-party window bounds for future collision support.

## Build and Run

Build the prototype:

```bash
swift build
```

Run the menu bar app:

```bash
swift run Xsnow
```

Stop the app from the menu bar item with `Quit Xsnow`.

Build a local unsigned app bundle:

```bash
bash Scripts/build_app_bundle.sh
```

The generated bundle is written to `dist/Xsnow.app`.

## Validation Status

Verified:

- `swift build` completes successfully.

Manual validation plan:

- Use `4.MVP 1.1 VALIDATION PLAN.md` as the canonical checklist for launch, menu controls, display behavior, accumulation, scanner lifecycle, sleep/wake, and resource checks.

Not yet verified manually:

- Visual snow rendering on all connected displays
- Bottom drift and seasonal objects pass visual review
- Click-through behavior over Finder, Safari, and Xcode
- Fullscreen Friendly overlay behavior over fullscreen apps, Stage Manager, and Spaces
- Display connect/disconnect overlay rebuild
- Settings restoration after app relaunch, including Wind and new accumulation options
- Spill When Full produces detailed falling snow fragments after buildup reaches the threshold
- Density, wind, and per-display menu behavior
- Window scanner debug count
- Sleep/wake resume behavior
- CPU and memory usage recorded in `7.PERFORMANCE LOG.md`

## Testing Notes

There is no automated test target yet. An initial Swift Testing/XCTest attempt was removed because the current Command Line Tools environment did not expose the expected testing modules.

For now, use `swift build` for compile verification and the manual validation checklist above for MVP behavior. Add `Tests/XsnowTests/` once an Xcode project or compatible XCTest environment is available.

## Next Steps

1. Run the full `4.MVP 1.1 VALIDATION PLAN.md` checklist.
2. Record Activity Monitor measurements in `7.PERFORMANCE LOG.md`.
3. Use `5.DISTRIBUTION CHECKLIST.md` before any packaged release.
4. Continue toward signing, notarization, and automated validation.
