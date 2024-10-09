//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Screen component for the chat channel view.
public struct ChatChannelScreen<Factory>: View where Factory: ViewFactory {
    public let chatChannelController: ChatChannelController
    private let viewFactory: Factory

    public init(
        chatChannelController: ChatChannelController,
        viewFactory: Factory = DefaultViewFactory.shared
    ) {
        self.chatChannelController = chatChannelController
        self.viewFactory = viewFactory
    }
    
    public var body: some View {
        ChatChannelView(
            viewFactory: viewFactory,
            channelController: chatChannelController
        )
    }
}
