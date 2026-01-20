//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatSwiftUI
import SwiftUI

class DemoAppFactory: ViewFactory {
    @Injected(\.chatClient) public var chatClient

    private init() {}
    
    private var mentionsHandler = MentionsHandler()

    public static let shared = DemoAppFactory()
    
    public var styles = RegularStyles()

    func makeChannelListHeaderViewModifier(options: ChannelListHeaderViewModifierOptions) -> some ChannelListHeaderViewModifier {
        CustomChannelModifier(title: options.title)
    }
    
    func supportedMoreChannelActions(
        options: SupportedMoreChannelActionsOptions
    ) -> [ChannelAction] {
        let channel = options.channel
        let onDismiss = options.onDismiss
        let onError = options.onError
        
        var actions = ChannelAction.defaultActions(
            for: .init(channel: channel, onDismiss: onDismiss, onError: onError)
        )
        let archiveChannel = archiveChannelAction(for: channel, onDismiss: onDismiss, onError: onError)
        actions.insert(archiveChannel, at: actions.count - 2)

        if AppConfiguration.default.isChannelPinningFeatureEnabled {
            let pinChannel = pinChannelAction(for: channel, onDismiss: onDismiss, onError: onError)
            actions.insert(pinChannel, at: actions.count - 2)
        }

        return actions
    }
    
    func makeChannelListItem(
        options: ChannelListItemOptions<ChannelDestination>
    ) -> some View {
        let channel = options.channel
        let channelName = options.channelName
        let disabled = options.disabled
        let selectedChannel = options.selectedChannel
        let swipedChannelId = options.swipedChannelId
        let channelDestination = options.channelDestination
        let onItemTap = options.onItemTap
        let trailingSwipeRightButtonTapped = options.trailingSwipeRightButtonTapped
        let trailingSwipeLeftButtonTapped = options.trailingSwipeLeftButtonTapped
        let leadingSwipeButtonTapped = options.leadingSwipeButtonTapped
        let listItem = DemoAppChatChannelNavigatableListItem(
            channel: channel,
            channelName: channelName,
            disabled: disabled,
            selectedChannel: selectedChannel,
            channelDestination: channelDestination,
            onItemTap: onItemTap
        )
        return ChatChannelSwipeableListItem(
            factory: self,
            channelListItem: listItem,
            swipedChannelId: swipedChannelId,
            channel: channel,
            numberOfTrailingItems: channel.ownCapabilities.contains(.deleteChannel) ? 2 : 1,
            trailingRightButtonTapped: trailingSwipeRightButtonTapped,
            trailingLeftButtonTapped: trailingSwipeLeftButtonTapped,
            leadingSwipeButtonTapped: leadingSwipeButtonTapped
        )
    }
    
    public func makeMessageViewModifier(for messageModifierInfo: MessageModifierInfo) -> some ViewModifier {
        ShowProfileModifier(messageModifierInfo: messageModifierInfo, mentionsHandler: mentionsHandler)
    }
    
    private func archiveChannelAction(
        for channel: ChatChannel,
        onDismiss: @escaping @MainActor () -> Void,
        onError: @escaping @MainActor (Error) -> Void
    ) -> ChannelAction {
        ChannelAction(
            title: channel.isArchived ? "Unarchive Channel" : "Archive Channel",
            iconName: "archivebox",
            action: { [weak self] in
                guard let self else { return }
                let channelController = chatClient.channelController(for: channel.cid)
                if channel.isArchived {
                    channelController.unarchive { error in
                        if let error {
                            onError(error)
                        } else {
                            onDismiss()
                        }
                    }
                } else {
                    channelController.archive { error in
                        if let error {
                            onError(error)
                        } else {
                            onDismiss()
                        }
                    }
                }
            },
            confirmationPopup: nil,
            isDestructive: false
        )
    }
    
    private func pinChannelAction(
        for channel: ChatChannel,
        onDismiss: @escaping @MainActor () -> Void,
        onError: @escaping @MainActor (Error) -> Void
    ) -> ChannelAction {
        let pinChannel = ChannelAction(
            title: channel.isPinned ? "Unpin Channel" : "Pin Channel",
            iconName: "pin.fill",
            action: { [weak self] in
                guard let self else { return }
                let channelController = chatClient.channelController(for: channel.cid)
                if channel.isPinned {
                    channelController.unpin { error in
                        if let error {
                            onError(error)
                        } else {
                            onDismiss()
                        }
                    }
                } else {
                    channelController.pin { error in
                        if let error {
                            onError(error)
                        } else {
                            onDismiss()
                        }
                    }
                }
            },
            confirmationPopup: nil,
            isDestructive: false
        )
        return pinChannel
    }
}

struct ShowProfileModifier: ViewModifier {
    let messageModifierInfo: MessageModifierInfo
    
    @ObservedObject var mentionsHandler: MentionsHandler
    
    func body(content: Content) -> some View {
        content
            .modifier(
                DefaultViewFactory.shared.styles.makeMessageViewModifier(for: messageModifierInfo)
            )
            .modifier(
                ProfileURLModifier(
                    mentionsHandler: mentionsHandler,
                    messageModifierInfo: messageModifierInfo
                )
            )
    }
}

class MentionsHandler: ObservableObject {
    @Published var selectedUser: ChatUser?
}

struct ProfileURLModifier: ViewModifier {
    @ObservedObject var mentionsHandler: MentionsHandler
    var messageModifierInfo: MessageModifierInfo
    
    @State var showProfile = false
    
    func body(content: Content) -> some View {
        if !messageModifierInfo.message.mentionedUsers.isEmpty {
            content
                .onOpenURL(perform: { url in
                    if url.absoluteString.contains("getstream://mention")
                        && url.pathComponents.count > 2
                        && messageModifierInfo.message.scrollMessageId == url.pathComponents[1]
                        && (mentionsHandler.selectedUser?.id != url.pathComponents[2] || !showProfile) {
                        let userId = url.pathComponents[2]
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            if mentionsHandler.selectedUser == nil {
                                let user = messageModifierInfo.message.mentionedUsers.first(where: { $0.id == userId })
                                mentionsHandler.selectedUser = user
                                showProfile = true
                            }
                        }
                    }
                })
                .sheet(isPresented: $showProfile, onDismiss: {
                    mentionsHandler.selectedUser = nil
                }, content: {
                    if let user = mentionsHandler.selectedUser {
                        VStack {
                            UserAvatar(user: user, size: .md)
                            Text(user.name ?? user.id)
                        }
                    }
                })
        } else {
            content
        }
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

    public var styles = LiquidGlassStyles()
    
    private init() {}

    public static let shared = CustomFactory()

    func makeGiphyBadgeViewType(options: GiphyBadgeViewTypeOptions) -> some View {
        EmptyView()
    }

    func makeLoadingView(options: LoadingViewOptions) -> some View {
        VStack {
            Text("This is custom loading view")
            ProgressView()
        }
    }

    func makeNoChannelsView(options: NoChannelsViewOptions) -> some View {
        VStack {
            Spacer()
            Text("This is our own custom no channels view.")
            Spacer()
        }
    }

    func makeChannelListHeaderViewModifier(options: ChannelListHeaderViewModifierOptions) -> some ChannelListHeaderViewModifier {
        CustomChannelModifier(title: options.title)
    }

    // Example for an injected action. Uncomment to see it in action.
    func supportedMoreChannelActions(
        options: SupportedMoreChannelActionsOptions
    ) -> [ChannelAction] {
        let channel = options.channel
        let onDismiss = options.onDismiss
        let onError = options.onError
        
        var defaultActions = ChannelAction.defaultActions(
            for: .init(channel: channel, onDismiss: onDismiss, onError: onError)
        )
        let freeze: @MainActor () -> Void = {
            let controller = self.chatClient.channelController(for: channel.cid)
            controller.freezeChannel { error in
                if let error {
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
        options: MoreChannelActionsViewOptions
    ) -> some View {
        VStack {
            Text("This is our custom view")
            Spacer()
            HStack {
                Button {
                    options.onDismiss()
                } label: {
                    Text("Action")
                }
            }
            .padding()
        }
    }

    func makeMessageTextView(
        options: MessageTextViewOptions
    ) -> some View {
        let message = options.message
        let isFirst = options.isFirst
        return CustomMessageTextView(
            message: message,
            isFirst: isFirst
        )
    }

    func makeCustomAttachmentViewType(
        options: CustomAttachmentViewTypeOptions
    ) -> some View {
        let message = options.message
        let isFirst = options.isFirst
        let availableWidth = options.availableWidth
        return CustomAttachmentView(
            message: message,
            width: availableWidth,
            isFirst: isFirst
        )
    }
}
