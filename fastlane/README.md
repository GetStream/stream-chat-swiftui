fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew install fastlane`

# Available Actions
### release
```
fastlane release
```
Release a new version
### push_pods
```
fastlane push_pods
```
Pushes the StreamChatSwiftUI SDK podspec to Cocoapods trunk
### match_me
```
fastlane match_me
```
If `readonly: true` (by default), installs all Certs and Profiles necessary for development and ad-hoc.
If `readonly: false`, recreates all Profiles necessary for development and ad-hoc, updates them locally and remotely.
### register_new_device_and_recreate_profiles
```
fastlane register_new_device_and_recreate_profiles
```
Register new device, regenerates profiles, updates them remotely and locally
### get_next_issue_number
```
fastlane get_next_issue_number
```
Get next PR number from github to be used in CHANGELOG
### test_ui
```
fastlane test_ui
```
Runs tests in Debug config
### build_demo
```
fastlane build_demo
```
Builds Demo app
### spm_integration
```
fastlane spm_integration
```
Test SPM Integration
### cocoapods_integration
```
fastlane cocoapods_integration
```
Test CocoaPods Integration

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
