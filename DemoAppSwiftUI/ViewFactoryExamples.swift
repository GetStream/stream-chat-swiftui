//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatSwiftUI
import SwiftUI

class DemoAppFactory: ViewFactory {
    
    @Injected(\.chatClient) public var chatClient
    
    private init() {}
    
    public static let shared = DemoAppFactory()
    
    func makeChannelListHeaderViewModifier(title: String) -> some ChannelListHeaderViewModifier {
        CustomChannelModifier(title: title)
    }
}

struct CustomChannelDestination: View {
    
    var channel: ChatChannel
    
    var body: some View {
        VStack {
            Text("This is the channel \(channel.name ?? "")")
        }
    }
}

class CustomFactory: ViewFactory {
    
    @Injected(\.chatClient) public var chatClient
    
    private init() {}
    
    public static let shared = CustomFactory()
    
    func makeGiphyBadgeViewType(for message: ChatMessage, availableWidth: CGFloat) -> some View {
        EmptyView()
    }
    
    func makeLoadingView() -> some View {
        VStack {
            Text("This is custom loading view")
            ProgressView()
        }
    }
    
    func makeNoChannelsView() -> some View {
        VStack {
            Spacer()
            Text("This is our own custom no channels view.")
            Spacer()
        }
    }
    
    func makeChannelListHeaderViewModifier(title: String) -> some ChannelListHeaderViewModifier {
        CustomChannelModifier(title: title)
    }
    
    // Example for an injected action. Uncomment to see it in action.
    func supportedMoreChannelActions(
        for channel: ChatChannel,
        onDismiss: @escaping () -> Void,
        onError: @escaping (Error) -> Void
    ) -> [ChannelAction] {
        var defaultActions = ChannelAction.defaultActions(
            for: channel,
            chatClient: chatClient,
            onDismiss: onDismiss,
            onError: onError
        )
        
        let freeze = {
            let controller = self.chatClient.channelController(for: channel.cid)
            controller.freezeChannel { error in
                if let error = error {
                    onError(error)
                } else {
                    onDismiss()
                }
            }
        }
        
        let confirmationPopup = ConfirmationPopup(
            title: "Freeze channel",
            message: "Are you sure you want to freeze this channel?",
            buttonTitle: "Freeze"
        )
        
        let channelAction = ChannelAction(
            title: "Freeze channel",
            iconName: "person.crop.circle.badge.minus",
            action: freeze,
            confirmationPopup: confirmationPopup,
            isDestructive: false
        )
        
        defaultActions.insert(channelAction, at: 0)
        return defaultActions
    }
    
    func makeMoreChannelActionsView(
        for channel: ChatChannel,
        onDismiss: @escaping () -> Void,
        onError: @escaping (Error) -> Void
    ) -> some View {
        VStack {
            Text("This is our custom view")
            Spacer()
            HStack {
                Button {
                    onDismiss()
                } label: {
                    Text("Action")
                }
            }
            .padding()
        }
    }
    
    func makeMessageTextView(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat
    ) -> some View {
        CustomMessageTextView(
            message: message,
            isFirst: isFirst
        )
    }
    
    func makeCustomAttachmentViewType(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat
    ) -> some View {
        CustomAttachmentView(
            message: message,
            width: availableWidth,
            isFirst: isFirst
        )
    }
}
