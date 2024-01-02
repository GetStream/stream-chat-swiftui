//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import SwiftUI
import StreamChat
import StreamChatSwiftUI

struct StartPage: View {

    @State var streamChat: StreamChat?
    @State var chatShown = false
    @ObservedObject var appState = AppState.shared
    @ObservedObject var notificationsHandler = NotificationsHandler.shared

    var chatClient: ChatClient = {
        var config = ChatClientConfig(apiKey: .init(apiKeyString))
        let client = ChatClient(config: config)
        return client
    }()

    var body: some View {
        NavigationView {
            ZStack {
                Button {
                    connectUser(withCredentials: UserCredentials.mock)
                    appState.userState = .loggedIn
                } label: {
                    Text("Start Chat")
                }

                if notificationsHandler.notificationChannelId != nil {
                    NavigationLink(isActive: .constant(true), destination: {
                        LazyView(
                            ChatChannelListView(
                                viewFactory: DemoAppFactory.shared,
                                selectedChannelId: notificationsHandler.notificationChannelId
                            )
                        ).navigationBarHidden(true)
                    }, label: {
                        EmptyView()
                    })
                } else {
                    NavigationLink(isActive: $chatShown, destination: {
                        LazyView(ChatChannelListView(viewFactory: DemoAppFactory.shared).navigationBarHidden(true))
                    }, label: {
                        EmptyView()
                    })
                }
            }
            .accessibilityIdentifier("TestApp.Start")
            .navigationTitle("Test UI App")
            .navigationBarHidden(true)
            .onReceive(appState.$userState, perform: { value in
                chatShown = value == .loggedIn
            })
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func connectUser(withCredentials credentials: UserCredentials) {
        chatClient.logout {}

        let token = try! Token(rawValue: credentials.token)
        LogConfig.level = .debug

        streamChat = StreamChat(chatClient: chatClient)

        chatClient.connectUser(
                userInfo: .init(id: credentials.id, name: credentials.name, imageURL: credentials.avatarURL),
                token: token
        ) { error in
            if let error = error {
                log.error("connecting the user failed \(error)")
                return
            }
        }
    }
}

class DemoAppFactory: ViewFactory {

    @Injected(\.chatClient) public var chatClient

    private init() {}

    public static let shared = DemoAppFactory()

    func makeChannelListHeaderViewModifier(title: String) -> some ChannelListHeaderViewModifier {
        CustomChannelModifier(title: title)
    }
}
