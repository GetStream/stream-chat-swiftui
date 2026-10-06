//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatSwiftUI
import SwiftUI

struct StartPage: View {
    @State var streamChat: StreamChat?
    @State var chatShown = false
    @ObservedObject var appState = AppState.shared
    @ObservedObject var notificationsHandler = NotificationsHandler.shared
    @ObservedObject var settings = TestAppSettings.shared

    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 32) {
                    SettingsView()
                    Button {
                        connectUser(withCredentials: UserCredentials.mock)
                        appState.userState = .loggedIn
                    } label: {
                        Text("Start Chat")
                    }
                    .accessibilityIdentifier("TestApp.Start")
                    Button {
                        connectUser(withCredentials: UserCredentials.secondUser)
                        appState.userState = .loggedIn
                    } label: {
                        Text("Start Chat as Han Solo")
                    }
                    .accessibilityIdentifier("TestApp.StartAsSecondUser")
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
                        LazyView(
                            ChatChannelListView(
                                viewFactory: DemoAppFactory.shared,
                                searchType: ProcessInfo.processInfo.arguments.contains("USE_CHANNEL_SEARCH") ? .channels : .messages
                            ).navigationBarHidden(true)
                        )
                    }, label: {
                        EmptyView()
                    })
                }
            }
            .navigationTitle("Test UI App")
            .navigationBarHidden(true)
            .onReceive(appState.$userState, perform: { value in
                chatShown = value == .loggedIn
            })
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func connectUser(withCredentials credentials: UserCredentials) {
        LogConfig.level = .debug

        var config = ChatClientConfig(apiKey: .init(apiKeyString))
        config.isLocalStorageEnabled = settings.isLocalStorageEnabled
        config.staysConnectedInBackground = settings.staysConnectedInBackground
        let chatClient = ChatClient(config: config)
        
        let utils = Utils(
            channelListConfig: ChannelListConfig(
                channelItemMutedStyle: .afterChannelName
            ),
            messageListConfig: MessageListConfig(
                messageDisplayOptions: .init(showOriginalTranslatedButton: true),
                dateIndicatorPlacement: .messageList,
                userBlockingEnabled: true,
                bouncedMessagesAlertActionsEnabled: true,
                skipEditedMessageLabel: { message in
                    message.extraData["ai_generated"]?.boolValue == true
                },
                draftMessagesEnabled: true,
                supportedMessageActions: { [chatClient] options in
                    var actions = MessageAction.defaultActions(for: options)
                    if options.message.isSentByCurrentUser {
                        actions.append(hardDeleteMessageAction(options: options, chatClient: chatClient))
                    }
                    return actions
                }
            ),
            composerConfig: ComposerConfig(isVoiceRecordingEnabled: true)
        )
        streamChat = StreamChat(chatClient: chatClient, utils: utils)

        let connect = {
            chatClient.connectUser(
                userInfo: .init(id: credentials.id, name: credentials.name, imageURL: credentials.avatarURL),
                tokenProvider: mockTokenProvider(for: credentials)
            ) { error in
                if let error = error {
                    log.error("connecting the user failed \(error)")
                    return
                }
            }
        }
        // Logging out wipes the local storage, which tests that relaunch the app need to keep.
        if ProcessInfo.processInfo.arguments.contains("KEEP_LOCAL_STORAGE") {
            connect()
        } else {
            chatClient.logout { connect() }
        }

        if settings.setConnectivity {
            StreamChatWrapper.shared.mockConnection(isConnected: settings.isConnected)
        }
    }

    /// Fetches the token from the mock server when `MOCK_JWT` is set, so the tests can control its validity.
    private func mockTokenProvider(for credentials: UserCredentials) -> TokenProvider {
        let staticToken = credentials.token
        return { completion in
            guard ProcessInfo.processInfo.arguments.contains("MOCK_JWT"),
                  let port = ProcessInfo.processInfo.environment["MOCK_SERVER_PORT"],
                  let url = URL(string: "http://localhost:\(port)/jwt/get?platform=ios") else {
                completion(Result { try Token(rawValue: staticToken) })
                return
            }

            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error {
                    completion(.failure(error))
                    return
                }
                guard let response = response as? HTTPURLResponse,
                      (200...299).contains(response.statusCode),
                      let data,
                      let body = String(data: data, encoding: .utf8) else {
                    completion(.failure(URLError(.badServerResponse)))
                    return
                }
                completion(.success(Token(stringLiteral: body)))
            }
            .resume()
        }
    }
}

@MainActor private func hardDeleteMessageAction(
    options: SupportedMessageActionsOptions,
    chatClient: ChatClient
) -> MessageAction {
    let messageController = chatClient.messageController(cid: options.channel.cid, messageId: options.message.id)
    return MessageAction(
        id: "hard_delete_message_action",
        title: "Hard Delete Message",
        iconName: "trash",
        action: {
            messageController.deleteMessage(hard: true) { error in
                if let error {
                    options.onError(error)
                } else {
                    options.onFinish(MessageActionInfo(message: options.message, identifier: "hard_delete"))
                }
            }
        },
        confirmationPopup: ConfirmationPopup(
            title: "Delete Message",
            message: "Are you sure you want to permanently delete this message?",
            buttonTitle: "Delete Message"
        ),
        isDestructive: true
    )
}

class DemoAppFactory: ViewFactory {
    @Injected(\.chatClient) public var chatClient

    private init() {}
    
    public var styles = RegularStyles()

    public static let shared = DemoAppFactory()

    func makeChannelListHeaderViewModifier(options: ChannelListHeaderViewModifierOptions) -> some ChannelListHeaderViewModifier {
        CustomChannelModifier(title: options.title)
    }

    func makeChannelHeaderViewModifier(options: ChannelHeaderViewModifierOptions) -> some ChatChannelHeaderViewModifier {
        ConnectivityChannelHeaderModifier(
            factory: self,
            channel: options.channel,
            shouldShowTypingIndicator: options.shouldShowTypingIndicator
        )
    }
}
