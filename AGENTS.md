Guidance for AI coding agents (Copilot, Cursor, Aider, Claude, etc.) working in this repository. Human readers are welcome, but this file is written for tools.

### Repository purpose

This repo hosts Stream's SwiftUI Chat SDK for iOS. It builds on the core client and provides SwiftUI-first chat components (views, view models, modifiers) for messaging apps.

Agents should optimize for clean code, follow Apple's SwiftUI guidelines and Swift best practices, accessibility, and high test coverage when changing code. Avoid doing any source-breaking changes without adding deprecations.

### Tech & toolchain

- Language: Swift 6.0 (strict concurrency enabled — `swift-tools-version:6.0`)
- Primary distribution: Swift Package Manager (SPM)
- Project file: `StreamChatSwiftUI.xcodeproj` (used for builds and tests; SPM manifest does not declare test targets)
- Xcode: 16.x or newer (Apple Silicon supported)
- Platforms / deployment targets: iOS 14+, macOS 11+ (see `Package.swift`; do not lower targets without approval)
- CI: GitHub Actions + Fastlane (see `.github/workflows/smoke-checks.yml`)
- Linting: SwiftLint (v0.59.1) — config in `.swiftlint.yml`
- Formatting: SwiftFormat (v0.58.2) — config in `.swiftformat`
- Code generation: SwiftGen (v6.5.1) — generates `L10n.swift` for localization strings
- Git hooks: lefthook (`lefthook.yml`) — runs SwiftLint fix + SwiftFormat on pre-commit, SwiftLint strict on pre-push
- Tool versions are pinned in `Githubfile`

### Dependencies

- **StreamChat** and **StreamChatCommonUI** from [`stream-chat-swift`](https://github.com/GetStream/stream-chat-swift) (≥ 5.0.0-beta)
- **Vendored libraries** (do not edit directly):
  - `Sources/StreamChatSwiftUI/StreamNuke/` — vendored Nuke image loading
  - `Sources/StreamChatSwiftUI/StreamSwiftyGif/` — vendored SwiftyGif
  - Update these via `make update_nuke version=X.Y.Z` / `make update_swiftygif version=X.Y.Z`

### Project layout (high level)

```
Sources/
  StreamChatSwiftUI/         # Main SDK: views, view models, theming, utils
    ChatChannel/             # Channel view & sub-components
    ChatChannelList/         # Channel list view & view model
    ChatComposer/            # Message composer
    ChatMessageList/         # Message list rendering
    ChatThreadList/          # Thread list
    CommonViews/             # Shared/reusable SwiftUI views
    Generated/               # Auto-generated (L10n.swift, version) — do not edit manually
    Resources/               # Localization files (en.lproj, etc.)
    StreamNuke/              # Vendored — do not edit
    StreamSwiftyGif/         # Vendored — do not edit
    Utils/                   # Utilities, common helpers
    ViewFactory/             # ViewFactory protocol & default implementation

DemoAppSwiftUI/              # Demo/sample app (use to validate UI changes)
StreamChatSwiftUITests/      # Unit & snapshot tests for the SDK
StreamChatSwiftUITestsApp/   # Test harness app for E2E tests
StreamChatSwiftUITestsAppTests/  # E2E / UI automation tests
Scripts/                     # Helper scripts (bootstrap, dependency updates, docs)
fastlane/                    # Fastlane lanes for CI (build, test, release)
```

When editing near other packages (e.g., StreamChat or StreamChatUI), prefer extending the SwiftUI layer rather than duplicating logic from dependencies.

### New files & target membership

When creating new source or resource files, add them to the correct Xcode target(s). Update the project (e.g. `project.pbxproj`) so each new file is included in the appropriate target's "Compile Sources" (or "Copy Bundle Resources" for assets). Match the target(s) used by sibling files in the same directory (e.g. `Sources/StreamChatSwiftUI/` → StreamChatSwiftUI target; `StreamChatSwiftUITests/` → StreamChatSwiftUITests target). Omitting target membership will cause build failures or unused files.

### Local setup (SPM)

1. Open the repository in Xcode (root contains `Package.swift` and `StreamChatSwiftUI.xcodeproj`).
2. Resolve packages.
3. Choose an iOS Simulator (e.g., iPhone 17 Pro) and Build.

Optional: run `Scripts/bootstrap.sh` to install pinned versions of SwiftLint, SwiftFormat, and SwiftGen, and to set up lefthook git hooks.

### Demo app

The `DemoAppSwiftUI` target is a fully functional sample app. Prefer running it to validate UI changes. Keep demo configs free of credentials and use placeholders like `YOUR_STREAM_KEY`.

### Schemes

Available shared schemes (under `StreamChatSwiftUI.xcodeproj/xcshareddata/xcschemes/`):
  - `StreamChatSwiftUI` — builds the SDK framework
  - `DemoAppSwiftUI` — builds and runs the demo app
  - `StreamChatSwiftUITestsApp` — builds and runs the E2E test harness

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

### Linting & formatting

SwiftLint (strict mode):

```
swiftlint lint --config .swiftlint.yml --strict
```

SwiftFormat (check only — no edits):

```
swiftformat --config .swiftformat --lint .
```

SwiftFormat (auto-fix):

```
swiftformat --config .swiftformat .
```

Respect `.swiftlint.yml` and `.swiftformat` rules. Do not broadly disable rules; scope exceptions and justify in PRs.

### CI overview

CI is driven by Fastlane (see `fastlane/Fastfile`). Key lanes:

- `test_ui` — runs unit/snapshot tests
- `test_e2e_mock` — runs E2E tests against a mock server
- `build_demo` — builds the demo app
- `build_test_app_and_frameworks` — builds test app and SDK frameworks

The `smoke-checks.yml` workflow is the primary PR gate. It runs linting, formatting validation, unit tests, E2E tests, and demo app builds.

### Generated code

Do not manually edit files in `Sources/StreamChatSwiftUI/Generated/`:
- `L10n.swift` — generated by SwiftGen from localization `.strings` files. Edit the `.strings` source files instead.
- `SystemEnvironment+Version.swift` — updated automatically during releases.
- `L10n_template.stencil` — the SwiftGen template for localization generation.

### Localization

The SDK uses `defaultLocalization: "en"`. String resources live in `Sources/StreamChatSwiftUI/Resources/en.lproj/`. After modifying `.strings` files, regenerate `L10n.swift` by running SwiftGen (or let CI handle it). Always use `L10n` accessors for user-facing strings rather than raw string literals.

### Concurrency model

The project uses Swift 6.0 strict concurrency. Many public types and view models are annotated with `@MainActor`. When adding new code:
- Mark SwiftUI view models and UI-bound types as `@MainActor`
- Use `Sendable` conformances where needed for cross-isolation transfers
- Avoid introducing data races; the compiler will enforce actor isolation

### Development guidelines

Accessibility & UI quality

- Ensure components have accessibility labels, traits, and dynamic type support.
- Support both light/dark mode.
- Use the tokens, colors, fonts, utils etc all from `InjectedValuesExtensions.swift`.
- When using Figma MCP, all the tokens, colors and fonts are available in the `InjectedValuesExtensions.swift` file with the same names.

Testing policy

- Add/extend tests in `StreamChatSwiftUITests/Tests/` (mirrors the source directory structure)
- Test infrastructure (mocks, shared helpers) lives in `StreamChatSwiftUITests/Infrastructure/`
- Prefer using `AssertSnapshot` from StreamChatTestHelpers instead of using the SnapshotTesting framework directly.
- Avoid using `AssertAsync` from StreamChatTestHelpers, instead use `XCTestExpectation` directly whenever possible.

### Branching & changelog

- The default integration branch is `develop`. Feature branches are merged into `develop`.
- Update `CHANGELOG.md` under the `# Upcoming` section when making client-facing changes (follow the Keep a Changelog format with `### Added`, `### Fixed`, `### Changed` subsections).
- Only update `CHANGELOG.md` **after the PR has been opened**, so the entry can include the PR link (e.g. `[#1234](https://github.com/GetStream/stream-chat-swiftui/pull/1234)`). Push the changelog update as a follow-up commit on the same branch.
- Keep changelog entries as short and high-level as possible. Describe the user-visible outcome in one line and do not explain implementation details, file names, or internal APIs.

### Commits

- Start commit subject lines with a capital letter.
- Do not end commit subject lines with a period.
- Keep the subject line concise (ideally under 72 characters); put additional context in the body separated by a blank line.

### Pull Requests

- Use the Github CLI to create a PR and use the Linear MCP to link the relevant issue assigned to me.
- When creating a PR, the base branch should be the `develop` branch.
- Make sure that the PR respects the PR template in `.github/PULL_REQUEST_TEMPLATE.md`.
- Make sure to fill the template with atomic information, do not mention things that were done and then reverted in this same PR.
- Do not write "Made with Cursor" in the PR description.
