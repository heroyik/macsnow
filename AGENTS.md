# Repository Guidelines

## Project Structure & Module Organization

This repository contains planning documents and a SwiftPM-based MVP prototype for **Xsnow for macOS**, a zero-dependency menu bar app concept using AppKit and SpriteKit.

- `1.XSNOW PRD.md`: functional and non-functional product requirements.
- `2.XSNOW ADD.md`: architecture design, module breakdown, and implementation roadmap.
- `Package.swift`: SwiftPM package definition.
- `Sources/Xsnow/`: MVP Swift app code (`XsnowManager`, `DisplayDetector`, `OverlayWindow`, `SnowScene`).
- `AGENTS.md`: contributor guidance.

Future tests should live in `Tests/XsnowTests/` once the local toolchain exposes XCTest or an Xcode project is added.

## Build, Test, and Development Commands

- `swift build`: compile the SwiftPM macOS prototype.
- `swift run Xsnow`: launch the menu bar app prototype.
- `swift test`: currently expected to report no tests until a test target is added.
- `git diff`: review local changes before committing, once this directory is initialized as a Git repository.

## Versioning

The current project version is stored in `VERSION`. The MVP 0.1 baseline is recorded as `0.1.0`.

For every future repository change, increment the patch version by `0.0.1` before committing. Example: `0.1.0` -> `0.1.1` -> `0.1.2`.

## Coding Style & Naming Conventions

Use Swift naming conventions for future app code: `UpperCamelCase` for types, `lowerCamelCase` for properties, functions, and local variables. Prefer small, single-purpose types that match the architecture: `XsnowManager`, `DisplayController`, `WindowLayoutScanner`, and `SnowPhysicsEngine`.

Keep the project zero-dependency unless the requirements explicitly change. Prefer Apple frameworks already named in the specs: AppKit, SpriteKit, CoreGraphics, and Foundation.

For Markdown, use concise headings, short paragraphs, and stable requirement IDs when extending the PRD, such as `F-1.2.8` or `N-2.4.1`.

## Testing Guidelines

No automated tests exist yet. Future Swift tests should live under `Tests/XsnowTests/` and use descriptive names such as `testDisplayDetectorRebuildsOverlaysWhenScreensChange()`.

Prioritize tests around coordinate conversion, display topology changes, settings persistence, and window filtering. Performance-sensitive behavior should include repeatable benchmarks or profiling notes for particle count, CPU use, and memory use.

## Commit & Pull Request Guidelines

This directory is not currently a Git repository, so no local commit history is available. Use clear, imperative commit messages such as `Add display detection design` or `Implement overlay window skeleton`.

Pull requests should include a short summary, affected documents or modules, validation performed, and screenshots or screen recordings for UI or visual changes. Link related issues or requirement IDs when applicable.

## Security & Configuration Tips

Avoid adding dependencies, background permissions, or screen-recording access without updating the PRD first. Keep privacy-sensitive behavior limited to window layout metadata where possible, matching the current design intent.
