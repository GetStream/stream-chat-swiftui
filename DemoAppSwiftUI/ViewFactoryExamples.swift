//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatSwiftUI
import SwiftUI

class DemoAppFactory: ViewFactory {

    @Injected(\.chatClient) public var chatClient

    private init() {}
    
    private var mentionsHandler = MentionsHandler()

    public static let shared = DemoAppFactory()

    func makeChannelListHeaderViewModifier(title: String) -> some ChannelListHeaderViewModifier {
        STNavigationView(title: "test", onTapArchives: {
            
        }, showArchive: false)

    }
    
    func supportedMoreChannelActions(
        for channel: ChatChannel,
        onDismiss: @escaping () -> Void,
        onError: @escaping (Error) -> Void
    ) -> [ChannelAction] {
        var actions = ChannelAction.defaultActions(
            for: channel,
            chatClient: chatClient,
            onDismiss: onDismiss,
            onError: onError
        )
        let archiveChannel = archiveChannelAction(for: channel, onDismiss: onDismiss, onError: onError)
        let pinChannel = pinChannelAction(for: channel, onDismiss: onDismiss, onError: onError)
        actions.insert(archiveChannel, at: actions.count - 2)
        actions.insert(pinChannel, at: actions.count - 2)
        return actions
    }
    
    func makeChannelListItem(
        channel: ChatChannel,
        channelName: String,
        avatar: UIImage,
        onlineIndicatorShown: Bool,
        disabled: Bool,
        selectedChannel: Binding<ChannelSelectionInfo?>,
        swipedChannelId: Binding<String?>,
        channelDestination: @escaping (ChannelSelectionInfo) -> ChatChannelView<DemoAppFactory>,
        onItemTap: @escaping (ChatChannel) -> Void,
        trailingSwipeRightButtonTapped: @escaping (ChatChannel) -> Void,
        trailingSwipeLeftButtonTapped: @escaping (ChatChannel) -> Void,
        leadingSwipeButtonTapped: @escaping (ChatChannel) -> Void
    ) -> some View {
        let listItem = DemoAppChatChannelNavigatableListItem(
            channel: channel,
            channelName: channelName,
            avatar: avatar,
            onlineIndicatorShown: onlineIndicatorShown,
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
    
    func makeChannelListTopView(searchText: Binding<String>) -> some View {
        STSearchView(searchText: searchText, appliedButtonClicked: false, selectedFilterType: .all, filterValues: { _, _ in })
    }
    
    public func makeMessageViewModifier(for messageModifierInfo: MessageModifierInfo) -> some ViewModifier {
        ShowProfileModifier(messageModifierInfo: messageModifierInfo, mentionsHandler: mentionsHandler)
    }
    
    private func archiveChannelAction(
        for channel: ChatChannel,
        onDismiss: @escaping () -> Void,
        onError: @escaping (Error) -> Void
    ) -> ChannelAction {
        ChannelAction(
            title: channel.isArchived ? "Unarchive Channel" : "Archive Channel",
            iconName: "archivebox",
            action: { [weak self] in
                guard let self else { return }
                let channelController = self.chatClient.channelController(for: channel.cid)
                if channel.isArchived {
                    channelController.unarchive { error in
                        if let error = error {
                            onError(error)
                        } else {
                            onDismiss()
                        }
                    }
                } else {
                    channelController.archive { error in
                        if let error = error {
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
        onDismiss: @escaping () -> Void,
        onError: @escaping (Error) -> Void
    ) -> ChannelAction {
        let pinChannel = ChannelAction(
            title: channel.isPinned ? "Unpin Channel" : "Pin Channel",
            iconName: "pin.fill",
            action: { [weak self] in
                guard let self else { return }
                let channelController = self.chatClient.channelController(for: channel.cid)
                if channel.isPinned {
                    channelController.unpin { error in
                        if let error = error {
                            onError(error)
                        } else {
                            onDismiss()
                        }
                    }
                } else {
                    channelController.pin { error in
                        if let error = error {
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

enum STFilterType: String {
    case all = "All"
    case unread = "Unread"
}

public struct STSearchView: View {
    internal init(searchText: Binding<String>, appliedButtonClicked: Bool, showBottomSheet: Bool = false, filterOption: [String] = ["All", "Unread"], selectedFilterType: STFilterType, resultCount: Int = 0, viewFactory: DemoAppFactory = DemoAppFactory.shared, filterValues: @escaping (STFilterType, Bool) -> Void) {
        _searchText = searchText
        self.appliedButtonClicked = appliedButtonClicked
        self.showBottomSheet = showBottomSheet
        self.filterOption = filterOption
        self.selectedFilterType = selectedFilterType
        self.resultCount = resultCount
        self.viewFactory = viewFactory
        self.filterValues = filterValues
    }
    
  @Binding var searchText: String
  @State var appliedButtonClicked: Bool
  @State var showBottomSheet: Bool = false
  @State var filterOption: [String] = ["All", "Unread"]
  @State var selectedFilterType: STFilterType
  @State var resultCount: Int = 0
  private var viewFactory = DemoAppFactory.shared

  var filterValues: (_ selectedType: STFilterType, _ filterButtonClicked: Bool) -> Void
   
  public var body: some View {
    VStack(spacing: 0) {
      HStack {
        HStack {
            Image(systemName: "xmark")
            .foregroundColor(.gray)
            .padding(.leading, 8)
         
          ZStack(alignment: .leading) {
            if searchText.isEmpty {
              Text("Search messages")
                .foregroundColor(.gray)
                .font(.body)
            }
             
            TextField("", text: $searchText)
              .textFieldStyle(PlainTextFieldStyle())
          }
           
          if !searchText.isEmpty {
            Button(action: {
              searchText = ""
            }) {
                Image(systemName: "xmark")
                .foregroundColor(.gray)
            }
            .padding(.trailing, 8)
          }
        }
        .frame(height: 44)
        .overlay(
          RoundedRectangle(cornerRadius: 10)
        )
        .background(Color(.white))
         
        Button(action: {
          showBottomSheet = true
        }) {
            Image(systemName: "xmark")
            .foregroundColor(.gray)
        }
        .padding(.leading, 16)
      }
      .padding([.leading, .trailing], 18)
      .frame(height: 60)
       
      if appliedButtonClicked {
        VStack {
            Text("Test")
          .frame(maxWidth: .infinity, maxHeight: 40)
        }
        .background(.white)
      }
    }
    .onAppear {

    }
    .animation(.easeInOut, value: showBottomSheet)
  }
}


struct STNavigationView: ChannelListHeaderViewModifier {
 var title: String
 public var onTapArchives: () -> Void
 @State private var showArchive: Bool
  
 init(title: String, onTapArchives: @escaping () -> Void, showArchive: Bool) {
  self.title = title
  self.onTapArchives = onTapArchives
  self.showArchive = showArchive
 }
  
 func body(content: Content) -> some View {
  content
   .toolbar {
     STChannelHeaderView(
      title: title,
      showArchive: $showArchive,
      onTapArchives: onTapArchives)

   }
   .navigationBarTitleDisplayMode(.inline)
 }
}

public struct STChannelHeaderView: ToolbarContent {
 @Injected(\.fonts) var fonts
 @Injected(\.images) var images
  
 var title: String
 @Binding var showArchive: Bool
 public var onTapArchives: () -> Void
  
 public var body: some ToolbarContent {
  ToolbarItem(placement: .navigationBarLeading) {
   Text(title)
    .font(.system(size: 34, weight: .bold))
    .foregroundColor(.gray)
    .padding(.leading, 16)
     
  }
   
  ToolbarItem(placement: .navigationBarTrailing) {
   HStack {
    if showArchive {
     Button(action: onTapArchives) {
         Image(systemName: "person")
       .resizable()
       .frame(width: 24, height: 24)
     }
     .padding(.trailing, 16)
    }
   }
  }

 }
}

struct ShowProfileModifier: ViewModifier {
    
    let messageModifierInfo: MessageModifierInfo
    
    @ObservedObject var mentionsHandler: MentionsHandler
    
    func body(content: Content) -> some View {
        content
            .modifier(
                DefaultViewFactory.shared.makeMessageViewModifier(for: messageModifierInfo)
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
                            MessageAvatarView(avatarURL: user.imageURL)
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
