# Repository Guidelines

## Project Structure & Module Organization
- Core package manifest lives at `Package.swift`; the SwiftUI component is under `Sources/SwiftUIOTPEntry` (`ModelUISwiftUIOTPEntry.swift`, `ViewSwiftUIOTPEntry.swift`, `String+.swift`).
- Demo app resides in `Example/Example.xcodeproj` with supporting assets in `Assets/`.
- No `Tests/` folder yet; add XCTest targets mirroring module names when introducing tests (e.g., `Tests/SwiftUIOTPEntryTests`).

## Build, Test, and Development Commands
- `swift package resolve` — fetch dependencies before first build.
- `swift build` — compile the Swift package; use `-c release` when measuring performance.
- `swift test` — run unit tests (add XCTest targets first).
- `xed Example/Example.xcodeproj` — open the demo project in Xcode for interactive previews and UI validation.

## Coding Style & Naming Conventions
- Swift 6+, SwiftUI-first; iOS 17+ APIs are allowed.
- Indent with 4 spaces; keep lines readable and add a trailing newline per file.
- Use clear, descriptive type and view names (`ModelUISwiftUIOTPEntry`, `ViewSwiftUIOTPEntry`) and prefer verb-leading method names (`receiveText`, `strokeColor`).
- Document public APIs with triple-slash comments; keep inline comments focused on non-obvious logic (e.g., buffering, focus handling).
- Favor value semantics and `@State`/`@Binding` for view state; keep Combine subscriptions stored in `@State` to persist across view updates.

## Testing Guidelines
- Adopt XCTest; place suites in `Tests/SwiftUIOTPEntryTests` with filenames ending in `Tests.swift` and methods like `testPastingFillsAllDigits()`.
- Cover input parsing (`onlyDigits`), focus behavior, and paste/autofill flows; aim for deterministic tests without UI timing where possible.
- Run `swift test` locally before opening a PR; include failing scenarios when filing bugs.

## Commit & Pull Request Guidelines
- Commit messages observed: short summaries, often with a leading dash; prefer concise, imperative subjects that describe the change and its user impact.
- For PRs, include: what changed, why, testing performed (`swift build`, `swift test`, simulator/manual steps), and screenshots or GIFs for UI updates (especially accessibility changes).
- Link issues or tasks when available; note platform/OS versions used for validation.

## Accessibility & Behavior Notes
- Component is designed with VoiceOver/Dynamic Type in mind; preserve accessibility strings (`textAccessibilityForEmptyBox`, `textAccessibilityPosition`) and verify changes with VoiceOver in the simulator.
- Keep OTP length, spacing, and color customizations configurable; avoid hard-coding values that should live in `ModelUISwiftUIOTPEntry`.
