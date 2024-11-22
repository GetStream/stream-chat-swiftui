// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "StreamChatSwiftUI",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v14), .macOS(.v11) // General platform settings
    ],
    products: [
        .library(
            name: "StreamChatSwiftUI",
            targets: ["StreamChatSwiftUI"]
        ),
        .library(
            name: "StreamChatAISwiftUI",
            targets: ["StreamChatAISwiftUI"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/GetStream/stream-chat-swift.git", from: "4.66.0"),
        .package(url: "https://github.com/JohnSundell/Splash.git", from: "0.16.0"),
        .package(url: "https://github.com/gonzalezreal/swift-markdown-ui.git", from: "2.4.1")
    ],
    targets: [
        .target(
            name: "StreamChatSwiftUI",
            dependencies: [
                .product(name: "StreamChat", package: "stream-chat-swift")
            ],
            exclude: ["README.md", "Info.plist", "Generated/L10n_template.stencil"],
            resources: [.process("Resources")]
        ),
        .target(
            name: "StreamChatAISwiftUI",
            dependencies: [
                .product(name: "Splash", package: "Splash"),
                .product(name: "MarkdownUI", package: "swift-markdown-ui")
            ],
            exclude: [],
            resources: [],
            swiftSettings: [
                .define("PLATFORM_IOS15_OR_LATER")
            ]
        )
    ]
)

#if swift(>=5.6)
package.dependencies.append(
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
)
#endif