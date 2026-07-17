//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Combine
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
                    TopAlignedProtoPicker(channelListController: channelListController)
                        .tabItem { Label("Proto", systemImage: "flask") }
                }
                .id(appState.contentIdentifier)
            }
        }
        .onChange(of: appState.userState) { newValue in
            if newValue == .loggedIn {
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

@MainActor class AppState: ObservableObject, CurrentChatUserControllerDelegate {
    @Injected(\.chatClient) var chatClient: ChatClient

    // Recreate the content view when channel query changes.
    @Published private(set) var contentIdentifier: String = ""
    
    @Published var userState: UserState = .launchAnimation
    @Published var unreadCount: UnreadCount = .noUnread

    private(set) var channelListController: ChatChannelListController?
    private(set) var currentUserController: CurrentChatUserController?
    private var cancellables = Set<AnyCancellable>()

    static let shared = AppState()

    private init() {
        $userState
            .removeDuplicates()
            .filter { $0 == .notLoggedIn }
            .sink { [weak self] _ in
                self?.didLogout()
            }
            .store(in: &cancellables)
        $userState
            .removeDuplicates()
            .filter { $0 == .loggedIn }
            .sink { [weak self] _ in
                self?.didLogin()
            }
            .store(in: &cancellables)
    }
    
    private func didLogout() {
        channelListController = nil
        currentUserController = nil
    }
    
    private func didLogin() {
        setChannelQueryIdentifier(.initial)
        
        currentUserController = chatClient.currentUserController()
        currentUserController?.delegate = self
        currentUserController?.synchronize()
    }
    
    func setChannelQueryIdentifier(_ identifier: ChannelListQueryIdentifier) {
        let query = AppState.channelListQuery(forIdentifier: identifier, chatClient: chatClient)
        channelListController = chatClient.channelListController(query: query)
        contentIdentifier = identifier.rawValue
    }

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

extension AppState {
    private static func channelListQuery(
        forIdentifier identifier: ChannelListQueryIdentifier,
        chatClient: ChatClient
    ) -> ChannelListQuery {
        guard let currentUserId = chatClient.currentUserId else { fatalError("Not logged in") }
        switch identifier {
        case .initial:
            var sort: [Sorting<ChannelListSortingKey>] = [Sorting(key: .default)]
            if AppConfiguration.default.isChannelPinningFeatureEnabled {
                sort.insert(Sorting(key: .pinnedAt), at: 0)
            }
            return ChannelListQuery(
                filter: .containMembers(userIds: [currentUserId]),
                sort: sort
            )
        case .archived:
            return ChannelListQuery(
                filter: .and([
                    .containMembers(userIds: [currentUserId]),
                    .equal(.archived, to: true)
                ])
            )
        case .pinned:
            return ChannelListQuery(
                filter: .and([
                    .containMembers(userIds: [currentUserId]),
                    .equal(.pinned, to: true)
                ])
            )
        }
    }
}

// MARK: - TEMPORARY prototype: non-inverted top-aligned message list

/// Lets you pick a channel to open in the non-inverted prototype below.
struct TopAlignedProtoPicker: View {
    var channelListController: ChatChannelListController?

    private var channels: [ChatChannel] {
        guard let channelListController else { return [] }
        return Array(channelListController.channels)
    }

    var body: some View {
        NavigationView {
            List(channels, id: \.cid) { channel in
                NavigationLink {
                    TopAlignedProtoView(cid: channel.cid)
                } label: {
                    VStack(alignment: .leading) {
                        Text(channel.name ?? channel.cid.rawValue)
                        Text(channel.latestMessages.first?.text ?? "")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            .navigationTitle("Proto — pick a channel")
        }
    }
}

/// Milestone 2 harness: renders the real `TopAlignedChatChannelView` (non-inverted
/// list + composer + navigation header) so the composer / keyboard adjustment can
/// be tested before wiring into `ChatChannelView`.
struct TopAlignedProtoView: View {
    let cid: ChannelId

    var body: some View {
        TopAlignedChatChannelView(
            channelController: InjectedValues[\.chatClient].channelController(for: cid)
        )
    }
}
