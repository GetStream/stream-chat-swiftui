//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatSwiftUI
import SwiftUI

@main
struct DemoAppSwiftUIApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Injected(\.chatClient) public var chatClient: ChatClient
    
    @ObservedObject var appState = AppState.shared
    
    var body: some Scene {
        WindowGroup {
            switch appState.userState {
            case .launchAnimation:
                StreamLogoLaunch()
            case .notLoggedIn:
                LoginView()
            case .loggedIn:
                ChatChannelListView(viewFactory: DemoAppFactory.shared)
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
