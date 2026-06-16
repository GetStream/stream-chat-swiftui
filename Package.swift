// swift-tools-version:6.0

import Foundation
import PackageDescription

// Use a sibling `stream-chat-swift` checkout when present so unreleased LLC APIs
// are available during local development. Falls back to the released package
// (e.g. on CI) when the sibling directory is not available.
let localLLCPath: String? = {
    let path = "../stream-chat-swift"
    return FileManager.default.fileExists(atPath: path + "/Package.swift") ? path : nil
}()

let package = Package(
    name: "StreamChatSwiftUI",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v14), .macOS(.v11)
    ],
    products: [
        .library(
            name: "StreamChatSwiftUI",
            targets: ["StreamChatSwiftUI"]
        )
    ],
    dependencies: [
        localLLCPath != nil
            ? .package(name: "stream-chat-swift", path: localLLCPath!)
            : .package(url: "https://github.com/GetStream/stream-chat-swift.git", from: "5.5.1")
    ],
    targets: [
        .target(
            name: "StreamChatSwiftUI",
            dependencies: [
                .product(name: "StreamChat", package: "stream-chat-swift"),
                .product(name: "StreamChatCommonUI", package: "stream-chat-swift")
            ],
            exclude: ["README.md", "Info.plist", "Generated/L10n_template.stencil"],
            resources: [.process("Resources")]
        )
    ]
)

package.dependencies.append(
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
)
