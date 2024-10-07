//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Screen component of the thread list.
/// It's the easiest way to integrate the SDK, but it provides the least customization options.
/// Use the `ChatThreadListView` for more customizations.
public struct ChatThreadListScreen: View {
    private var title: String?
    private var threadListController: ChatThreadListController?

    public init(
        title: String? = nil,
        threadListController: ChatThreadListController? = nil
    ) {
        self.title = title
        self.threadListController = threadListController
    }

    public var body: some View {
        ChatThreadListView(
            viewFactory: DefaultViewFactory.shared,
            threadListController: threadListController,
            title: title ?? L10n.Thread.title
        )
    }
}
