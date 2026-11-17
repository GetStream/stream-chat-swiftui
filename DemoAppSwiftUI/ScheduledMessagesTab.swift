//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatSwiftUI
import SwiftUI

/// The scheduled messages of all channels, with the current user's avatar in the navigation bar.
struct ScheduledMessagesTab: View {
    @Injected(\.chatClient) private var chatClient

    var body: some View {
        NavigationView {
            if #available(iOS 26, *) {
                list.toolbar {
                    avatar
                    #if compiler(>=6.2)
                    .sharedBackgroundVisibility(.hidden)
                    #endif
                }
            } else {
                list.toolbar { avatar }
            }
        }
        .navigationViewStyle(.stack)
    }

    private var list: some View {
        ScheduledMessageListView(
            viewFactory: DemoAppFactory.shared,
            viewModel: ViewModelsFactory.makeScheduledMessageListViewModel(
                scheduledMessageListController: chatClient.scheduledMessageListController()
            ),
            title: "Scheduled",
            embedInNavigationView: false
        )
    }

    @ToolbarContentBuilder private var avatar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            if let user = chatClient.currentUserController().currentUser {
                UserAvatar(user: user, size: 36)
                    .accessibilityHidden(true)
            }
        }
    }
}
