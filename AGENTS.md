Guidance for AI coding agents (Copilot, Cursor, Aider, Claude, etc.) working in this repository. Human readers are welcome, but this file is written for tools.

### Repository purpose

This repo hosts Stream’s SwiftUI Chat SDK for iOS. It builds on the core client and provides SwiftUI-first chat components (views, view models, modifiers) for messaging apps.

Agents should optimize for clean code, follow Apple's SwiftUI guidelines and Swift best practices, accessibility, and high test coverage when changing code. Avoid doing any source-breaking changes without adding deprecations.

### Tech & toolchain

- Language: Swift (SwiftUI)
- Primary distribution: Swift Package Manager (SPM)
- Xcode: 16.x or newer (Apple Silicon supported)
- Platforms / deployment targets: Use the values set in Package.swift; do not lower targets without approval
- CI: GitHub Actions (assume PR validation for build + tests + lint)
- Linters & docs: SwiftLint and SwiftFormat

### Project layout (high level)

Sources/
  StreamChatSwiftUI/       # SwiftUI views, view models, theming, utils
Tests/
  StreamChatSwiftUITests/  # Unit/UI tests for SwiftUI layer

When editing near other packages (e.g., StreamChat or StreamChatUI), prefer extending the SwiftUI layer rather than duplicating logic from dependencies.

### New files & target membership
  When creating new source or resource files, add them to the correct Xcode target(s). Update the project (e.g. project.pbxproj) so each new file is included in the appropriate target's "Compile Sources" (or "Copy Bundle Resources" for assets). Match the target(s) used by sibling files in the same directory (e.g. Sources/StreamChatSwiftUI/ → StreamChatSwiftUI; Tests/StreamChatSwiftUITests/ → StreamChatSwiftUITests). Omitting target membership will cause build failures or unused files.

### Local setup (SPM)

1. Open the repository in Xcode (root contains Package.swift).
2. Resolve packages.
3. Choose an iOS Simulator (e.g., iPhone 17 Pro) and Build.

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
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -configuration Debug build
```

Run tests:

```
xcodebuild \
  -scheme StreamChatSwiftUI \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -configuration Debug test
```

If the device is not available, use one of the active booted devices, like so:

```
xcodebuild \
  -scheme StreamChatSwiftUI \
  -destination "platform=iOS Simulator,OS=any,name=$(xcrun simctl list devices booted | grep '(Booted)' | head -1 | sed 's/ (.*)//')" \
  -configuration Debug test
```

If a Makefile or scripts exist (e.g., make build, make test, ./scripts/lint.sh), prefer those to keep parity with CI. Discover with make help and ls scripts/.

Linting & formatting
  • SwiftLint (strict):

swiftlint --strict

  • Respect .swiftlint.yml and any repo-specific rules. Do not broadly disable rules; scope exceptions and justify in PRs.

### Development guidelines

Accessibility & UI quality

- Ensure components have accessibility labels, traits, and dynamic type support.
- Support both light/dark mode.
- Use the tokens, colors, fonts, utils etc all from InjectedValuesExtensions.swift.
- When using Figma MCP, all the tokens, colors and fonts are available in the InjectedValuesExtensions.swift file with the same names.

Testing policy

- Add/extend tests in StreamChatSwiftUITests/
- Prefer using the AssertSnapshot from StreamChatTestHelpers instead of using the SnapshotTesting framework directly.
- Avoid using the AssertAsync from StreamChatTestHelpers, instead use the XCTestExpectation directly whenever possible.

Pull Requests:

- Use the Github CLI to create a PR and use the Linear MCP to link the relevant issue assigned to me.
- When creating a PR, the base branch should be the develop branch.
- Make sure that the PR respects the PR template in .github/PULL_REQUEST_TEMPLATE.md.
- Make sure to fill the template with atomic information, do not mention things that were done and then reverted in this same PR.
- Do not write "Made with Cursor" in the PR description.
