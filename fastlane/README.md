fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

### sonar_upload

```sh
[bundle exec] fastlane sonar_upload
```

Get code coverage report and run complexity analysis for Sonar

### allure_upload

```sh
[bundle exec] fastlane allure_upload
```

Upload test results to Allure TestOps

### allure_launch

```sh
[bundle exec] fastlane allure_launch
```

Create launch on Allure TestOps

### allure_launch_removal

```sh
[bundle exec] fastlane allure_launch_removal
```

Remove launch on Allure TestOps

### allure_create_testcase

```sh
[bundle exec] fastlane allure_create_testcase
```

Create test-case in Allure TestOps and get its id

### allure_start_regression

```sh
[bundle exec] fastlane allure_start_regression
```

Sync and run regression test-plan on Allure TestOps

### release

```sh
[bundle exec] fastlane release
```

Release a new version

### push_pods

```sh
[bundle exec] fastlane push_pods
```

Pushes the StreamChatSwiftUI SDK podspec to Cocoapods trunk

### match_me

```sh
[bundle exec] fastlane match_me
```

If `readonly: true` (by default), installs all Certs and Profiles necessary for development and ad-hoc.
If `readonly: false`, recreates all Profiles necessary for development and ad-hoc, updates them locally and remotely.

### register_new_device_and_recreate_profiles

```sh
[bundle exec] fastlane register_new_device_and_recreate_profiles
```

Register new device, regenerates profiles, updates them remotely and locally

### get_next_issue_number

```sh
[bundle exec] fastlane get_next_issue_number
```

Get next PR number from github to be used in CHANGELOG

### test_ui

```sh
[bundle exec] fastlane test_ui
```

Runs tests in Debug config

### test_e2e_mock

```sh
[bundle exec] fastlane test_e2e_mock
```

Runs e2e ui tests using mock server in Debug config

### build_demo

```sh
[bundle exec] fastlane build_demo
```

Builds Demo app

### spm_integration

```sh
[bundle exec] fastlane spm_integration
```

Test SPM Integration

### cocoapods_integration

```sh
[bundle exec] fastlane cocoapods_integration
```

Test CocoaPods Integration

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
