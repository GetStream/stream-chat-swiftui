#!/usr/bin/env bash
set -euo pipefail

echo -e "👉 Running SwiftFormat Linting"

echo -e "👉 Linting Sources..."
mint run swiftformat --lint --config .swiftformat Sources --exclude **/Generated,Sources/StreamChatUI/StreamNuke,Sources/StreamChatUI/StreamSwiftyGif
echo -e "👉 Linting Tests..."
mint run swiftformat --lint --config .swiftformat StreamChatSwiftUITests
echo -e "👉 Linting DemoApp..."
mint run swiftformat --lint --config .swiftformat DemoAppSwiftUI