//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChatSwiftUI
import SwiftUI

@main
struct StreamChatSwiftUITestsAppApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            StartPage()
        }
    }
}

class AppState: ObservableObject, Equatable {

    static func == (lhs: AppState, rhs: AppState) -> Bool {
        lhs.userState == rhs.userState
    }

    @Published var userState: UserState = .notLoggedIn

    static let shared = AppState()

    private init() {}
}

enum UserState {
    case notLoggedIn
    case loggedIn
}
