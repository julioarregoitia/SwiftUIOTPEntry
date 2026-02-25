# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SwiftUIOTPEntry is a lightweight Swift Package providing a SwiftUI OTP/PIN entry component for iOS 17+ and tvOS 17+. It has zero external dependencies—only SwiftUI, Combine, and Foundation.

## Build & Development Commands

```bash
swift build                        # Compile the package
swift build -c release             # Release build
swift test                         # Run unit tests (no tests exist yet)
xed Example/Example.xcodeproj     # Open demo app in Xcode
```

## Architecture

The package has three source files in `Sources/SwiftUIOTPEntry/`:

- **ViewSwiftUIOTPEntry** — The main SwiftUI view. Renders a row of OTP digit boxes using `EnhancedTextField` (a `UIViewRepresentable` wrapping a custom `EnhancedUITextField` subclass that detects backspace via `deleteBackward()`). A `EnhancedTextFieldCoordinator` handles `UITextFieldDelegate` methods for sequential input enforcement, focus management, and paste/autofill detection.
- **ModelUISwiftUIOTPEntry** — A `Sendable` configuration struct controlling appearance (font, colors, spacing, box size, box count) and accessibility strings.
- **String+** — Extension adding `onlyDigits()` for input sanitization via `CharacterSet.decimalDigits`.

### Key Design Decisions

- **Combine-based paste/autofill**: Multi-character input (paste or iOS SMS autofill) is emitted through a `PassthroughSubject` and collected in 250ms time windows before being distributed across fields. This is the non-obvious core mechanism—understand it before modifying input handling.
- **Sequential field enforcement**: `textFieldShouldBeginEditing` prevents users from tapping ahead of the current input position. Focus advances automatically on digit entry and retreats on backspace.
- **`textContentType = .oneTimeCode`**: Enables iOS keyboard autofill from SMS codes.

## Coding Conventions

- Swift 6+, SwiftUI-first, minimum iOS 17+
- 4-space indentation, trailing newlines
- Naming: descriptive types (`ModelUISwiftUIOTPEntry`, `ViewSwiftUIOTPEntry`), verb-leading methods (`receiveText`, `strokeColor`)
- Value semantics preferred; `@State`/`@Binding` for view state; Combine subscriptions stored in `@State`
- Accessibility: maintain VoiceOver labels and Dynamic Type support; keep customizable strings in the model, not hardcoded

## Testing

No tests exist yet. When adding them, place in `Tests/SwiftUIOTPEntryTests/` with filenames like `*Tests.swift` and methods like `testPastingFillsAllDigits()`. Priority areas: `onlyDigits` parsing, focus progression, paste/autofill flows.



## Swift Formatting

1. Prefer single-line expressions when they are short and readable.
2. For initializers and chained calls, keep a single line if the expression is 140 characters or fewer.
3. Split into multiple lines only when the expression exceeds 140 characters or readability clearly improves.
4. If an expression is already on one line and within the limit, do not reformat it into multiple lines.
5. Never add a newline immediately after `(` or immediately before `)`.
