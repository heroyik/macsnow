# Xsnow for macOS

Xsnow for macOS is a lightweight menu bar prototype that renders falling snow across connected macOS displays without blocking normal app interaction.

The project is currently at **MVP 0.3 implementation start**. The repository version is `0.1.3`, stored in `VERSION`. The repository includes product requirements, architecture notes, an MVP implementation plan, and a SwiftPM-based AppKit/SpriteKit prototype.

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
├── AGENTS.md
├── Package.swift
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
- `OverlayWindow`: transparent, borderless, click-through AppKit window.
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

## Validation Status

Verified:

- `swift build` completes successfully.

Not yet verified manually:

- Visual snow rendering on all connected displays
- Click-through behavior over Finder, Safari, and Xcode
- Display connect/disconnect overlay rebuild
- Settings restoration after app relaunch
- Density, wind, and per-display menu behavior
- Window scanner debug count
- Sleep/wake resume behavior
- CPU and memory usage in Activity Monitor

## Testing Notes

There is no automated test target yet. An initial Swift Testing/XCTest attempt was removed because the current Command Line Tools environment did not expose the expected testing modules.

For now, use `swift build` for compile verification and the manual validation checklist above for MVP behavior. Add `Tests/XsnowTests/` once an Xcode project or compatible XCTest environment is available.

## Next Steps

1. Run `swift run Xsnow` and manually validate MVP 0.1, 0.2, and 0.3 menu behavior.
2. Confirm settings restoration after app relaunch.
3. Validate that the debug window count updates as visible windows change.
4. Design coordinate conversion from CoreGraphics window bounds to per-display SpriteKit coordinates.
5. Tune overlay window level for fullscreen apps, Stage Manager, and Spaces.
