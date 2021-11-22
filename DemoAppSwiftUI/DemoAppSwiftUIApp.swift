//
//  Copyright © 2021 Stream.io Inc. All rights reserved.
//

import SwiftUI
import StreamChat
import StreamChatSwiftUI

@main
struct DemoAppSwiftUIApp: App {
    
//    @StateObject var launchAnimationState = LaunchAnimationState()
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Injected(\.chatClient) public var chatClient: ChatClient
    
    var body: some Scene {
        WindowGroup {
//            if launchAnimationState.showAnimation {
//                StreamLogoLaunch()
//            } else {
//                ChatChannelListView()
//            }
            ChatChannelListView(viewFactory: DemoAppFactory.shared)
            /*
            //Example of custom query filters.
            ChatChannelListView(
                viewFactory: CustomFactory.shared,
                channelListController: customChannelListController
            )
            */
            /*
            // Example for the channel list screen.
            ChatChannelListScreen()
            */
            
        }
    }
    
    private var customChannelListController: ChatChannelListController {
        let controller = chatClient.channelListController(
            query: .init(
                filter: .and([.equal(.type, to: .messaging), .containMembers(userIds: [chatClient.currentUserId!])]),
                sort: [.init(key: .lastMessageAt, isAscending: true)],
                pageSize: 10
            )
        )
        return controller
    }
}
