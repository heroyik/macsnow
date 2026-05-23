# Xsnow for macOS

Xsnow for macOS is a lightweight menu bar prototype that renders falling snow across connected macOS displays without blocking normal app interaction.

The project is currently at **MVP 0.1 implementation start**. The repository includes product requirements, architecture notes, an MVP implementation plan, and a SwiftPM-based AppKit/SpriteKit prototype.

## Current Status

Completed so far:

- Created repository contributor guide in `AGENTS.md`.
- Reviewed `1.XSNOW PRD.md` and identified requirement risks around performance targets, permissions, fullscreen behavior, and testability.
- Added an `MVP v0.1` scope section to `1.XSNOW PRD.md`.
- Added an `MVP v0.1` architecture section to `2.XSNOW ADD.md`.
- Added `3.MVP 0.1 IMPLEMENTATION PLAN.md`.
- Started MVP 0.1 implementation with a Swift Package Manager project.
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
        ├── OverlayWindow.swift
        ├── SnowScene.swift
        ├── StatusMenuController.swift
        ├── XsnowManager.swift
        └── main.swift
```

## Key Components

- `main.swift`: starts `NSApplication` in accessory mode.
- `AppDelegate`: creates and starts `XsnowManager`.
- `XsnowManager`: orchestrates menu state, display overlays, and sleep/wake handling.
- `StatusMenuController`: owns the menu bar item and Start/Stop/Quit actions.
- `DisplayDetector`: watches macOS display configuration changes.
- `DisplayController`: owns one overlay window and SpriteKit scene per display.
- `OverlayWindow`: transparent, borderless, click-through AppKit window.
- `SnowScene`: simple SpriteKit falling snow particle scene.

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
- Sleep/wake resume behavior
- CPU and memory usage in Activity Monitor

## Testing Notes

There is no automated test target yet. An initial Swift Testing/XCTest attempt was removed because the current Command Line Tools environment did not expose the expected testing modules.

For now, use `swift build` for compile verification and the manual validation checklist above for MVP behavior. Add `Tests/XsnowTests/` once an Xcode project or compatible XCTest environment is available.

## Next Steps

1. Run `swift run Xsnow` and manually validate the MVP checklist.
2. Tune overlay window level for fullscreen apps, Stage Manager, and Spaces.
3. Confirm display coordinate behavior for monitors arranged above or left of the main display.
4. Record CPU and RAM usage at the default snow density.
5. Add persistent settings and per-display controls in a later MVP.
