//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Screen component of the channel list.
/// It's the easiest way to integrate the SDK, but it provides the least customization options.
/// Use the `ChatChannelListView` for more customizations.
public struct ChatChannelListScreen: View {
    private var title: String
    private var channelListController: ChatChannelListController?
    private var selectedChannelId: String?

    public init(
        title: String = "Stream Chat",
        channelListController: ChatChannelListController? = nil,
        selectedChannelId: String? = nil
    ) {
        self.title = title
        self.channelListController = channelListController
        self.selectedChannelId = selectedChannelId
    }

    public var body: some View {
        ChatChannelListView(
            viewFactory: DefaultViewFactory.shared,
            channelListController: channelListController,
            title: title,
            selectedChannelId: selectedChannelId
        )
    }
}
