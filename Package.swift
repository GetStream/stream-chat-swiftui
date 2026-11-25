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
        .package(url: "https://github.com/GetStream/stream-chat-swift.git", revision: "dfbde5804846215cc551e0b66da3cc76ffec879e")
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
