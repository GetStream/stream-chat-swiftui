//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
@_exported @testable import StreamChatTestTools
@_exported import StreamSwiftTestHelpers
import XCTest

/// Base class that sets up the `StreamChat` object.
open class StreamChatTestCase: XCTestCase {
    public static var currentUserId: String = .unique

    public var chatClient: ChatClient_Mock = {
        let client = ChatClient.mock(isLocalStorageEnabled: false)
        client.mockAuthenticationRepository.mockedCurrentUserId = currentUserId
        return client
    }()

    public var streamChat: StreamChat?

    override open func setUp() {
        super.setUp()
        streamChat = StreamChat(
            chatClient: chatClient,
            utils: Utils(videoPreviewLoader: VideoPreviewLoader_Mock(), imageLoader: ImageLoader_Mock())
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
            appearance.colors.navigationBarTintColor = .purple
            appearance.colors.navigationBarTitle = .blue
            appearance.colors.navigationBarSubtitle = .cyan
            appearance.colors.navigationBarBackground = .yellow
            appearance.colors.navigationBarGlyph = .green
        }
    }
}
