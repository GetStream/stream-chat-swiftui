//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatCommonUI
@testable import StreamChatSwiftUI
@_exported @testable import StreamChatTestTools
@_exported import StreamSwiftTestHelpers
import XCTest

/// Base class that sets up the `StreamChat` object.
@MainActor open class StreamChatTestCase: XCTestCase {
    public static var currentUserId: String = .unique

    public var chatClient: ChatClient_Mock = {
        let client = ChatClient.mock(isLocalStorageEnabled: false)
        client.mockAuthenticationRepository.mockedCurrentUserId = currentUserId
        return client
    }()

    public var streamChat: StreamChat? {
        willSet {
            Appearance.bundle = Bundle(for: type(of: self))
        }
    }

    override open func setUp() {
        super.setUp()
        Appearance.bundle = Bundle(for: type(of: self))
        streamChat = StreamChat(
            chatClient: chatClient,
            utils: Utils(
                videoPreviewLoader: VideoPreviewLoader_Mock(),
                imageLoader: ImageLoader_Mock(),
                composerConfig: .init(isVoiceRecordingEnabled: true)
            )
        )
    }
    
    func adjustAppearance(_ block: (inout Appearance) -> Void) {
        guard let streamChat else { return }
        var appearance = streamChat.appearance
        block(&appearance)
        streamChat.appearance = appearance
    }
    
    func setThemedNavigationBarAppearance() {
        adjustAppearance { appearance in
            appearance.colorPalette.navigationBarTintColor = .purple
            appearance.colorPalette.navigationBarTitle = .blue
            appearance.colorPalette.navigationBarSubtitle = .cyan
            appearance.colorPalette.navigationBarBackground = .yellow
            appearance.colorPalette.navigationBarGlyph = .green
        }
    }
}

// Forces the solid primary button style regardless of platform,
/// preventing Liquid Glass from appearing in snapshot tests.
struct RegularToolbarConfirmActionModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.buttonStyle(
            StreamButtonStyle(
                role: .primary,
                style: .solid,
                size: .medium,
                isIconOnly: true
            )
        )
    }
}

/// Test styles that override the toolbar confirm action to always use the solid style.
class DefaultTestStyles: RegularStyles {
    override func makeToolbarConfirmActionModifier(options: ToolbarConfirmActionModifierOptions) -> some ViewModifier {
        RegularToolbarConfirmActionModifier()
    }
}

/// Test view factory that uses ``DefaultTestStyles`` to avoid Liquid Glass in snapshot tests.
class DefaultTestViewFactory: ViewFactory {
    @Injected(\.chatClient) var chatClient
    var styles = DefaultTestStyles()

    static let shared = DefaultTestViewFactory()
}
