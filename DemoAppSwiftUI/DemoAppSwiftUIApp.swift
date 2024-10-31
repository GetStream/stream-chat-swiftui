//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatSwiftUI
import SwiftUI

@main
struct DemoAppSwiftUIApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Injected(\.chatClient) public var chatClient: ChatClient

    @ObservedObject var appState = AppState.shared
    @ObservedObject var notificationsHandler = NotificationsHandler.shared

    var channelListController: ChatChannelListController? {
        appState.channelListController
    }

    var channelListSearchType: ChannelListSearchType {
        .messages
    }

    var body: some Scene {
        WindowGroup {
            switch appState.userState {
            case .launchAnimation:
                StreamLogoLaunch()
            case .notLoggedIn:
                LoginView()
            case .loggedIn:
                TabView {
                    channelListView()
                        .tabItem { Label("Chat", systemImage: "message") }
                        .badge(appState.unreadCount.channels)
                    threadListView()
                        .tabItem { Label("Threads", systemImage: "text.bubble") }
                        .badge(appState.unreadCount.threads)
                }
            }
        }
        .onChange(of: appState.userState) { newValue in
            if newValue == .loggedIn {
                /*
                 if let currentUserId = chatClient.currentUserId {
                 let pinnedByKey = ChatChannel.isPinnedBy(keyForUserId: currentUserId)
                 let channelListQuery = ChannelListQuery(
                 filter: .containMembers(userIds: [currentUserId]),
                 sort: [
                 .init(key: .custom(keyPath: \.isPinned, key: pinnedByKey), isAscending: true),
                 .init(key: .lastMessageAt),
                 .init(key: .updatedAt)
                 ]
                 )
                 appState.channelListController = chatClient.channelListController(query: channelListQuery)
                 }
                 */
                appState.currentUserController = chatClient.currentUserController()
                notificationsHandler.setupRemoteNotifications()
            }
        }
    }

    func channelListView() -> ChatChannelListView<DemoAppFactory> {
        if notificationsHandler.notificationChannelId != nil {
            ChatChannelListView(
                viewFactory: DemoAppFactory.shared,
                channelListController: channelListController,
                selectedChannelId: notificationsHandler.notificationChannelId,
                searchType: channelListSearchType
            )
        } else {
            ChatChannelListView(
                viewFactory: DemoAppFactory.shared,
                channelListController: channelListController,
                searchType: channelListSearchType
            )
        }
    }

    func threadListView() -> ChatThreadListView<DemoAppFactory> {
        ChatThreadListView(viewFactory: DemoAppFactory.shared)
    }
}

class AppState: ObservableObject, CurrentChatUserControllerDelegate {

    @Published var userState: UserState = .launchAnimation {
        willSet {
            if newValue == .notLoggedIn && userState == .loggedIn {
                channelListController = nil
            }
        }
    }

    @Published var unreadCount: UnreadCount = .noUnread

    var channelListController: ChatChannelListController?
    var currentUserController: CurrentChatUserController? {
        didSet {
            currentUserController?.delegate = self
            currentUserController?.synchronize()
        }
    }

    static let shared = AppState()

    private init() {}

    func currentUserController(_ controller: CurrentChatUserController, didChangeCurrentUserUnreadCount: UnreadCount) {
        unreadCount = didChangeCurrentUserUnreadCount
        let totalUnreadBadge = unreadCount.channels + unreadCount.threads
        if #available(iOS 16.0, *) {
            UNUserNotificationCenter.current().setBadgeCount(totalUnreadBadge)
        } else {
            UIApplication.shared.applicationIconBadgeNumber = totalUnreadBadge
        }
    }
}

enum UserState {
    case launchAnimation
    case notLoggedIn
    case loggedIn
}
