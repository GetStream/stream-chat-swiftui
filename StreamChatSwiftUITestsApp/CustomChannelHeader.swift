//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatSwiftUI
import SwiftUI

public struct CustomChannelHeader: ToolbarContent {
    @Injected(\.fonts) var fonts
    @Injected(\.images) var images
    @Injected(\.colors) var colors

    var title: String
    var connectionStatus: String
    var currentUserController: CurrentChatUserController
    @Binding var isNewChatShown: Bool
    @Binding var logoutAlertShown: Bool
    @Binding var threadListShown: Bool

    @MainActor
    public var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(title)
                .font(fonts.bodyBold)
                .accessibilityIdentifier(connectionStatus)
        }
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                logoutAlertShown = true
            } label: {
                if let user = currentUserController.currentUser {
                    UserAvatar(user: user, size: 36)
                } else {
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 36, height: 36)
                }
            }
            .accessibilityAddTraits(.isButton)
            .accessibilityIdentifier("LogoutButton")
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                threadListShown = true
            } label: {
                Image(systemName: "text.bubble")
            }
            .accessibilityLabel("Threads")
            .accessibilityIdentifier("ThreadListButton")
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            ConnectivitySwitch()
        }
    }
}

struct CustomChannelModifier: ChannelListHeaderViewModifier {
    @Injected(\.chatClient) var chatClient

    var title: String

    @StateObject private var connectionStatus = ConnectionStatusObserver(client: InjectedValues[\.chatClient])
    @State var isNewChatShown = false
    @State var logoutAlertShown = false
    @State var threadListShown = false

    func body(content: Content) -> some View {
        ZStack {
            content.toolbar {
                CustomChannelHeader(
                    title: title,
                    connectionStatus: connectionStatus.status.testIdentifier,
                    currentUserController: chatClient.currentUserController(),
                    isNewChatShown: $isNewChatShown,
                    logoutAlertShown: $logoutAlertShown,
                    threadListShown: $threadListShown
                )
            }
            .background(
                NavigationLink(isActive: $threadListShown) {
                    LazyView(ChatThreadListView(viewFactory: DemoAppFactory.shared, embedInNavigationView: false))
                } label: {
                    EmptyView()
                }
            )
            // Attached to its own view: a second `alert` on the same view would replace the channel list alerts.
            .background(
                Color.clear.alert(isPresented: $logoutAlertShown) {
                    Alert(
                        title: Text("Sign out"),
                        message: Text("Are you sure you want to sign out?"),
                        primaryButton: .destructive(Text("Sign out")) {
                            withAnimation {
                                chatClient.disconnect {}
                                AppState.shared.userState = .notLoggedIn
                            }
                        },
                        secondaryButton: .cancel()
                    )
                }
            )
        }
    }
}
