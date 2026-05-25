# Status Bar Icon Missing When Running from .app Bundle

## Overview

**Reported by**: User (Nick)
**Date**: May 25, 2026
**Severity**: High (app functions but has no menu bar affordance)
**Status**: Investigation / Spec

## Problem Statement

After building MacSnow via `bash Scripts/build_dmg.sh`, opening the resulting DMG, and dragging `MacSnow.app` to `/Applications`, launching the app results in **no status bar icon appearing** in the macOS menu bar. The user confirms:

- The app **process is running** (visible in Activity Monitor)
- **Snow overlays render correctly** on screen
- **No click target exists** in the menu bar (clicking where the icon should be does nothing)
- **No menu bar management tools** (Bartender, Ice, Hidden Bar, etc.) are installed
- **Menu bar has ~10–15 icons** (not overcrowded)

## Critical Clue: Works with `swift run`

The status bar icon **works correctly** when the app is launched via `swift run MacSnow` from the terminal. The issue is **specific to running from the bundled .app** installed from the DMG.

## Environment

| Attribute | Value |
|-----------|-------|
| macOS version | **26.5** (Build 25F71) — confirmed via `sw_vers` |
| Hardware | Apple Silicon (M-series) |
| Build method | `bash Scripts/build_dmg.sh` → DMG → Drag to /Applications |
| Menu bar density | ~10–15 icons, no overcrowding |
| Menu bar managers | None |
| Bundle ID | `local.macsnow.prototype` |
| App name | MacSnow v1.21.72 |

## Investigation Step 1 Results (May 25, 2026)

### Console.app Logs
- **No crash reports** found for MacSnow anywhere on the system
- **No autosave data** exists for `local.macsnow.statusItem` (`defaults read` failed — domain doesn't exist)
- **NSStatusItem scenes ARE being created successfully** via Control Center scene architecture:
  - Logs confirm `__NSStatusItemSceneHostSettings__`, `__NSStatusItemSceneClientSettings__`, `__NSStatusItemAuxiliaryViewSceneSettings__`
  - Control Center requested and completed scenes for the status item
  - Scene workspace handshake and fence actions completed
- **No status bar errors** — Control Center communication succeeds
- **Recurring but unrelated errors**: `com.apple.linkd.autoShortcut` connection failures (Code 4097, `XPC_ERROR_CONNECTION_INTERRUPTED`) — AppIntents framework, unrelated to status bar
- **Warning**: CoreSpotlight window tab indexing (`_setMailMessageAttributes skip:1`) — unrelated

### Relaunch Test (3 consecutive launches from /Applications)
| Launch | Status | Status Item Scenes in Logs | Icon Visible |
|--------|--------|---------------------------|--------------|
| 1 | Process runs, snow renders | ✅ Created successfully | ❌ Not visible |
| 2 | Process runs, snow renders | ✅ Created successfully | ❌ Not visible |
| 3 | Process runs, snow renders | ✅ Created successfully | ❌ Not visible |

**Conclusion**: Relaunching does NOT resolve the issue. The known Sonoma-era workaround (relaunch 2-3 times to get a hidden status item to appear) does not apply here.

### Bundle Structure Check
- `/Applications/MacSnow.app` exists with correct structure
- Binary: `Mach-O 64-bit executable arm64` (correct for Apple Silicon)
- Info.plist: Contains all expected keys, `LSUIElement=true`

## New Hypothesis: `statusItem.button` is nil on macOS 26.5 from LSUIElement App

The system logs confirm the NSStatusItem's **scene** is created and registered with Control Center. However, the `button` property of `NSStatusItem` may still be `nil` when `configure()` runs. On macOS 26.5, if the status item's visual representation (button) is not yet resolved by the scene architecture, `statusItem.button` returns nil, and no image or title is ever set. The scene exists in Control Center but no visual element renders in the menu bar.

This explains:
- **Why logs show scene creation**: The scene was allocated and registered
- **Why the icon is invisible**: The button was nil, so no visual content was applied
- **Why clicking does nothing**: No click target exists because the button was never initialized
- **Why `swift run` works**: Different app lifecycle path may resolve the button differently

## Technical Background

### How the status bar icon is created

1. **`StatusMenuController.swift`** (line 43):
   ```swift
   private let statusItem = NSStatusBar.system.statusItem(withLength: 22)
   ```

2. **`configure()`** method (line 87+):
   ```swift
   statusItem.autosaveName = "local.macsnow.statusItem"
   if let button = statusItem.button {
       button.image = Self.makeStatusImage()  // SF Symbol "snowflake" or fallback
       button.imagePosition = .imageOnly
       // ...
   }
   statusItem.menu = menu
   ```

3. **`makeStatusImage()`** (line 295+):
   - Tries SF Symbol `"snowflake"` first
   - Falls back to a hand-drawn snowflake `NSImage`
   - Sets `isTemplate = true` for dark/light mode

4. **`main.swift`**:
   ```swift
   app.setActivationPolicy(.accessory)
   app.finishLaunching()
   DispatchQueue.main.async {
       delegate.startIfNeeded()  // → MacSnowManager.start() → statusMenuController.configure()
   }
   app.run()
   ```

5. **Info.plist** (in `build_app_bundle.sh`):
   ```xml
   <key>LSUIElement</key>
   <true/>
   ```

### Key difference between `swift run` and `.app` bundle

| Aspect | `swift run MacSnow` | `.app` bundle (DMG) |
|--------|-------------------|---------------------|
| Info.plist | None (no bundle) | Has `LSUIElement=true` |
| Activation policy | Set in code: `.accessory` | Set by system to `.accessory` via LSUIElement, also set in code redundantly |
| Working directory | Project root | Inside .app bundle |
| AppKit lifecycle | Managed by framework | Managed by LaunchServices + framework |

## Potential Root Causes

### 1. LSUIElement + NSStatusBar interaction (Highest Probability)

When `LSUIElement=true` is set in Info.plist, macOS treats the app as a background agent (same as `.accessory` activation policy). On some macOS versions (particularly early releases), there have been reports of `NSStatusBar.system.statusItem()` not creating a visible item in the menu bar when the app is an LSUIElement agent.

**Why `swift run` works**: When running without a bundle, there's no Info.plist, so `LSUIElement` is not set. The app relies solely on `setActivationPolicy(.accessory)` in code. This code-path works correctly.

**Hypothesis**: The combination of `LSUIElement=true` in Info.plist AND `setActivationPolicy(.accessory)` in code may cause a conflict or the system may not properly create the status item when the app is launched as an LSUIElement agent from LaunchServices.

### 2. `statusItem.button` is nil

If `NSStatusBar.statusItem(withLength: 22).button` returns `nil` at the time `configure()` runs, the image is never set. However, the status item itself (as an empty slot) should still appear in the menu bar. Since the user says **no click target exists**, this is unlikely to be the sole cause — but it could be related if the status item itself doesn't get created.

### 3. `autosaveName` Corruption

The status item has:
```swift
statusItem.autosaveName = "local.macsnow.statusItem"
```

If there's a corrupted or invalid saved state associated with this autosave name, the system might position the item at an invalid location (e.g., off-screen or within another menu). Clearing the saved state might resolve the issue.

### 4. macOS Sonoma/Sequoia Status Bar Bug

macOS 14 (Sonoma) introduced changes to the menu bar that caused various status bar app compatibility issues. Some LSUIElement apps had their status items not appear until the app was relaunched. This could be a factor depending on the exact macOS version.

### 5. Bundle Configuration Issues

- **Bundle ID** `local.macsnow.prototype` is a non-standard reverse-domain format (should be `com.example.macsnow` or similar). While this shouldn't cause status bar issues, it's worth noting.
- **No `CFBundleDisplayName`** set — minor, but could affect how the system identifies the app.
- **`CFBundlePackageType`** is set to `APPL` — correct for a regular app. LSUIElement apps typically use `APPL` as well.

## Investigation Steps

### Step 1: Reproduce and confirm
- [ ] Launch from DMG-installed `/Applications/MacSnow.app`
- [ ] Confirm no status bar icon appears
- [ ] Check Console.app (`/Applications/Utilities/Console.app`) for MacSnow-related logs at launch time
- [ ] Check if relaunching 2–3 times makes the icon appear (known workaround for Sonoma-era bug)

### Step 2: Test isolation
- [ ] Build and run via `swift run MacSnow` — confirm icon appears (baseline)
- [ ] Manually copy `.app` bundle from `dist/` to `/Applications` (bypassing DMG) — check if icon appears
- [ ] Run the `.app` bundle directly from `dist/` without moving to `/Applications` — check behavior
- [ ] Build the app with `swift build -c debug` and run the raw executable from `.build/debug/`

### Step 3: Test LSUIElement variations
- [ ] Remove `LSUIElement` from Info.plist and rebuild → test
- [ ] Change `LSUIElement` to `<false/>` → test
- [ ] Remove `app.setActivationPolicy(.accessory)` from main.swift → test (both with and without LSUIElement)
- [ ] Move `statusMenuController.configure()` call to before `app.finishLaunching()` → test

### Step 4: Test status item creation timing
- [ ] Add explicit logging: "statusItem created", "button is nil / not nil", "image set"
- [ ] Add a short delay before `configure()` is called
- [ ] Move `statusItem` creation from `init` to after `app.finishLaunching()`
- [ ] Try `NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)` instead of fixed 22

### Step 5: Test autosaveName
- [ ] Remove or change `statusItem.autosaveName` → rebuild and test
- [ ] Run `defaults delete local.macsnow.statusItem` (if it exists) then relaunch
- [ ] Run `defaults read local.macsnow.statusItem` to check for saved state

### Step 6: Verify bundle structure
- [ ] Confirm `dist/MacSnow.app/Contents/MacOS/MacSnow` exists and is executable
- [ ] Confirm `dist/MacSnow.app/Contents/Info.plist` has correct contents
- [ ] Run `file dist/MacSnow.app/Contents/MacOS/MacSnow` to confirm architecture matches system
- [ ] Run `codesign -dv dist/MacSnow.app` to check code signing status (unsigned is expected)

## Potential Fixes

### Fix A: Remove redundant activation policy
Remove `app.setActivationPolicy(.accessory)` from `main.swift` since it's already set by `LSUIElement=true` in Info.plist. Or alternatively, remove LSUIElement from Info.plist and keep the code-based activation policy (which works).

**Precedence**: Since `swift run` (no LSUIElement, code-based .accessory) works, the code-based approach is confirmed functional. The fix would be to remove LSUIElement from Info.plist and rely solely on the code call.

### Fix B: Delay status item creation
Create the `NSStatusItem` after `app.finishLaunching()` or with a slight delay (`DispatchQueue.main.async`) to ensure AppKit has fully initialized.

### Fix C: Clear autosave on first launch
Add a launch flag or version check to clear/reset the `autosaveName` on first launch after an update.

### Fix D: Use variableLength
Change `withLength: 22` to `withLength: NSStatusItem.variableLength` which may behave differently on some macOS versions.

### Fix E: Add explicit visibility check
After creating the status item, programmatically check if it's visible and retry creation if not.

## Acceptance Criteria

- [ ] Status bar icon appears in menu bar when MacSnow is launched from `/Applications`
- [ ] Status bar icon appears in menu bar when MacSnow is launched via any method (DMG, direct bundle, swift run)
- [ ] Clicking the icon opens the MacSnow menu
- [ ] All existing functionality (snow rendering, menu items, settings) continues to work
- [ ] No regressions in behavior when running via `swift run`

## Related Files

| File | Role |
|------|------|
| `Sources/MacSnow/main.swift` | Entry point, sets activation policy, launches app |
| `Sources/MacSnow/StatusMenuController.swift` | Creates and configures the NSStatusItem |
| `Sources/MacSnow/MacSnowManager.swift` | Orchestrates startup, calls `statusMenuController.configure()` |
| `Sources/MacSnow/AppDelegate.swift` | App delegate, calls `manager.start()` |
| `Scripts/build_app_bundle.sh` | Creates .app bundle with Info.plist (LSUIElement) |
| `Scripts/build_dmg.sh` | Creates DMG from .app bundle |

