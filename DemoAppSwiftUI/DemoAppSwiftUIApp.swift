//
// Copyright © 2022 Stream.io Inc. All rights reserved.
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
    
    var body: some Scene {
        WindowGroup {
            switch appState.userState {
            case .launchAnimation:
                StreamLogoLaunch()
            case .notLoggedIn:
                LoginView()
            case .loggedIn:
                if notificationsHandler.notificationChannelId != nil {
                    ChatChannelListView(
                        viewFactory: DemoAppFactory.shared,
                        selectedChannelId: notificationsHandler.notificationChannelId
                    )
                } else {
                    ChatChannelListView(
                        viewFactory: DemoAppFactory.shared
                    )
                }
            }
        }
        .onChange(of: appState.userState) { newValue in
            if newValue == .loggedIn {
                notificationsHandler.setupRemoteNotifications()
            }
        }
    }
}

class AppState: ObservableObject {
    
    @Published var userState: UserState = .launchAnimation
    
    static let shared = AppState()
    
    private init() {}
}

enum UserState {
    case launchAnimation
    case notLoggedIn
    case loggedIn
}
