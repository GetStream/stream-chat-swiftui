//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatSwiftUI
import SwiftUI

struct DebugChannelHeaderModifier: ChatChannelHeaderViewModifier {
    let factory: DemoAppFactory
    let channel: ChatChannel
    let shouldShowTypingIndicator: Bool

    @State private var isChannelInfoShown = false
    @State private var isChannelActionsShown = false

    func body(content: Content) -> some View {
        content
            .toolbarThemed {
                ToolbarItem(placement: .principal) {
                    ChannelTitleView(
                        factory: factory,
                        channel: channel,
                        shouldShowTypingIndicator: shouldShowTypingIndicator
                    )
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        Button {
                            isChannelActionsShown = true
                        } label: {
                            Image(systemName: "ladybug.fill")
                        }
                        .accessibilityLabel("Channel Actions")
                        ZStack {
                            Button {
                                resignFirstResponder()
                                isChannelInfoShown = true
                            } label: {
                                factory.makeChannelAvatarView(
                                    options: ChannelAvatarViewOptions(channel: channel, size: AvatarSize.large)
                                )
                            }
                            .accessibilityLabel("Channel info")
                            NavigationLink(isActive: $isChannelInfoShown) {
                                LazyView(ChatChannelInfoView(factory: factory, channel: channel, shownFromMessageList: true))
                            } label: {
                                EmptyView()
                            }
                            .accessibilityHidden(true)
                        }
                    }
                }
            }
            .sheet(isPresented: $isChannelActionsShown) {
                DebugChannelActionsView(channel: channel)
            }
    }
}
