//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Screen component for the chat channel view.
struct ChatChannelScreen: View {
    var chatChannelController: ChatChannelController
    
    var body: some View {
        ChatChannelView(
            viewFactory: DefaultViewFactory.shared,
            channelController: chatChannelController
        )
    }
}
