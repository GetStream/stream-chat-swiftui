#!/bin/bash

./hooks/git-format-staged --formatter 'mint run swiftformat --config .swiftformat stdin' 'Sources/*.swift' '!*Generated*' '!*StreamNuke*' '!*StreamSwiftyGif*'
./hooks/git-format-staged --formatter 'mint run swiftformat --config .swiftformat stdin' 'StreamChatSwiftUITests/*.swift'
./hooks/git-format-staged --formatter 'mint run swiftformat --config .swiftformat stdin' 'DemoAppSwiftUI/*.swift'

# Regenerage Package.swift files if needed
./hooks/regenerage-spm-package-if-needed.sh
