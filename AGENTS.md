Guidance for AI coding agents (Copilot, Cursor, Aider, Claude, etc.) working in this repository. Human readers are welcome, but this file is written for tools.

### Repository purpose

This repo hosts Stream’s SwiftUI Chat SDK for iOS. It builds on the core client and provides SwiftUI-first chat components (views, view models, modifiers) for messaging apps.

Agents should optimize for API stability, backwards compatibility, accessibility, and high test coverage when changing code.

### Tech & toolchain
  • Language: Swift (SwiftUI)
  • Primary distribution: Swift Package Manager (SPM), secondary CocoaPods and XCFrameworks
  • Xcode: 15.x or newer (Apple Silicon supported)
  • Platforms / deployment targets: Use the values set in Package.swift/podspecs; do not lower targets without approval
  • CI: GitHub Actions (assume PR validation for build + tests + lint)
  • Linters & docs: SwiftLint and SwiftFormat

### Project layout (high level)

Sources/
  StreamChatSwiftUI/       # SwiftUI views, view models, theming, utils
Tests/
  StreamChatSwiftUITests/  # Unit/UI tests for SwiftUI layer

When editing near other packages (e.g., StreamChat or StreamChatUI), prefer extending the SwiftUI layer rather than duplicating logic from dependencies.

### Local setup (SPM)
  1.  Open the repository in Xcode (root contains Package.swift).
  2.  Resolve packages.
  3.  Choose an iOS Simulator (e.g., iPhone 15) and Build.

Optional: sample/demo app

If a sample app target exists in this repo, prefer running that to validate UI changes. Keep demo configs free of credentials and use placeholders like YOUR_STREAM_KEY.

### Schemes

Typical scheme names include:
  • StreamChatSwiftUI
  • StreamChatSwiftUITests

Agents must query existing schemes before invoking xcodebuild.

### Build & test commands (CLI)

Prefer Xcode for day-to-day work; use CLI for CI parity & automation.

Build (Debug):

```
xcodebuild \
  -scheme StreamChatSwiftUI \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -configuration Debug build
```

Run tests:

```
xcodebuild \
  -scheme StreamChatSwiftUI \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -configuration Debug test
```

If a Makefile or scripts exist (e.g., make build, make test, ./scripts/lint.sh), prefer those to keep parity with CI. Discover with make help and ls scripts/.

Linting & formatting
  • SwiftLint (strict):

swiftlint --strict

  • Respect .swiftlint.yml and any repo-specific rules. Do not broadly disable rules; scope exceptions and justify in PRs.

Public API & SemVer
  • Follow semantic versioning for the SwiftUI package.
  • Any public API change must include updated docs and migration notes.
  • Avoid source-breaking changes. If unavoidable, add deprecations first with a transition path.

Accessibility & UI quality
  • Ensure components have accessibility labels, traits, and dynamic type support.
  • Support both light/dark mode.
  • When altering UI, attach before/after screenshots (or screen recordings) in PRs.

Testing policy
  • Add/extend tests in StreamChatSwiftUITests/ for:
  • View models and state handling