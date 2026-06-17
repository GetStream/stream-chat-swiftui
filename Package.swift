// swift-tools-version:6.0

import Foundation
import PackageDescription

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
        // Temporarily points to the enhanced mentions LLC branch until the
        // corresponding stream-chat-swift changes are released.
        .package(url: "https://github.com/GetStream/stream-chat-swift.git", branch: "add/enhanced-user-mentions")
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
