# Repository Guidelines

## Project Structure & Module Organization

This repository contains planning documents and a SwiftPM-based MVP prototype for **MacSnow**, a zero-dependency menu bar app concept using AppKit and SpriteKit.

- `1.XSNOW PRD.md`: functional and non-functional product requirements.
- `2.XSNOW ADD.md`: architecture design, module breakdown, and implementation roadmap.
- `Package.swift`: SwiftPM package definition.
- `Sources/MacSnow/`: MVP Swift app code (`MacSnowManager`, `DisplayDetector`, `OverlayWindow`, `SnowScene`).
- `AGENTS.md`: contributor guidance.

Future tests should live in `Tests/MacSnowTests/` once the local toolchain exposes XCTest or an Xcode project is added.

## Build, Test, and Development Commands

- `swift build -c release`: compile the SwiftPM macOS prototype without creating a debug executable.
- `swift run -c release MacSnow`: launch the menu bar app prototype from a release SwiftPM build when needed.
- `swift test`: currently expected to report no tests until a test target is added.
- `bash Scripts/build_app_bundle.sh`: create an unsigned local `dist/MacSnow.app` bundle.
- `bash Scripts/build_dmg.sh`: create an unsigned local `dist/MacSnow-<version>.dmg` installer image containing `MacSnow.app` and an `/Applications` shortcut.
- `git diff`: review local changes before committing, once this directory is initialized as a Git repository.

DMG packaging is the default install artifact for releases. Keep the DMG filename aligned with `VERSION` and regenerate it after every bundle-affecting change.

Do not use default `swift build` or `swift run MacSnow`; SwiftPM defaults to debug mode and creates `.build/.../debug/MacSnow`, which can register as an extra menu bar app.
The package manifest also blocks debug configuration with a compile-time error, so debug artifacts should not be produced.

## Code Search

Use Semble for repository code search on every user prompt that asks about code, files, symbols, behavior, bugs, tests, or implementation details.

- Call `mcp__semble__search` with the full user prompt as the query and `/Users/nick/proj/macsnow` as `repo` before falling back to broad text search.
- Use `mcp__semble__find_related` from a prior result when related implementations or nearby call sites would help.
- Prefer Semble over `rg`, `grep`, `find`, and broad file reads for locating code; use shell or context-mode afterward only for targeted verification, builds, diffs, and edits.

## Versioning

The current project version is stored in `VERSION`. The MVP 0.1 baseline is recorded as `0.1.0`.

For every future repository change, increment the patch version by `0.0.1` before committing. Example: `0.1.0` -> `0.1.1` -> `0.1.2`.

## Coding Style & Naming Conventions

Use Swift naming conventions for future app code: `UpperCamelCase` for types, `lowerCamelCase` for properties, functions, and local variables. Prefer small, single-purpose types that match the architecture: `MacSnowManager`, `DisplayController`, `WindowLayoutScanner`, and `SnowPhysicsEngine`.

Keep the project zero-dependency unless the requirements explicitly change. Prefer Apple frameworks already named in the specs: AppKit, SpriteKit, CoreGraphics, and Foundation.

For Markdown, use concise headings, short paragraphs, and stable requirement IDs when extending the PRD, such as `F-1.2.8` or `N-2.4.1`.

## Testing Guidelines

No automated tests exist yet. Future Swift tests should live under `Tests/MacSnowTests/` and use descriptive names such as `testDisplayDetectorRebuildsOverlaysWhenScreensChange()`.

Prioritize tests around coordinate conversion, display topology changes, settings persistence, and window filtering. Performance-sensitive behavior should include repeatable benchmarks or profiling notes for particle count, CPU use, and memory use.

## Commit & Pull Request Guidelines

This directory is not currently a Git repository, so no local commit history is available. Use clear, imperative commit messages such as `Add display detection design` or `Implement overlay window skeleton`.

Pull requests should include a short summary, affected documents or modules, validation performed, and screenshots or screen recordings for UI or visual changes. Link related issues or requirement IDs when applicable.

## Security & Configuration Tips

Avoid adding dependencies, background permissions, or screen-recording access without updating the PRD first. Keep privacy-sensitive behavior limited to window layout metadata where possible, matching the current design intent.
