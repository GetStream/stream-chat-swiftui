//
// Copyright © 2022 Stream.io Inc. All rights reserved.
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
