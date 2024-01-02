//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Screen component for the chat channel view.
public struct ChatChannelScreen: View {
    public var chatChannelController: ChatChannelController

    public var body: some View {
        ChatChannelView(
            viewFactory: DefaultViewFactory.shared,
            channelController: chatChannelController
        )
    }
}
