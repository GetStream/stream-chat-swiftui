//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatSwiftUI
import SwiftUI

public struct CustomChannelHeader: ToolbarContent {
    @Injected(\.fonts) var fonts
    @Injected(\.images) var images
    @Injected(\.colors) var colors

    var title: String
    var currentUserController: CurrentChatUserController
    @Binding var isNewChatShown: Bool
    @Binding var actionsPopupShown: Bool

    @MainActor
    public var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(title)
                .font(fonts.bodyBold)
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                isNewChatShown = true
                notifyHideTabBar()
            } label: {
                Image(uiImage: images.messageActionEdit)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(Color(colors.navigationBarGlyph))
                    .padding(.all, 8)
                    .background(colors.navigationBarTintColor)
                    .clipShape(Circle())
            }
            .accessibilityLabel(Text("New Channel"))
        }
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                actionsPopupShown = true
            } label: {
                StreamLazyImage(
                    url: currentUserController.currentUser?.imageURL,
                    size: CGSize(width: 36, height: 36)
                )
                .accessibilityLabel("Account Actions")
                .accessibilityAddTraits(.isButton)
            }
        }
    }
}

struct CustomChannelModifier: ChannelListHeaderViewModifier {
    @Injected(\.chatClient) var chatClient

    var title: String

    @State var isChooseChannelQueryShown = false
    @State var isNewChatShown = false
    @State var logoutAlertShown = false
    @State var actionsPopupShown = false
    @State var blockedUsersShown = false

    func body(content: Content) -> some View {
        ZStack {
            if #available(iOS 26, *) {
                content.toolbarThemed {
                    CustomChannelHeader(
                        title: title,
                        currentUserController: chatClient.currentUserController(),
                        isNewChatShown: $isNewChatShown,
                        actionsPopupShown: $actionsPopupShown
                    )
                    #if compiler(>=6.2)
                    .sharedBackgroundVisibility(.hidden)
                    #endif
                }
            } else {
                content.toolbarThemed {
                    CustomChannelHeader(
                        title: title,
                        currentUserController: chatClient.currentUserController(),
                        isNewChatShown: $isNewChatShown,
                        actionsPopupShown: $actionsPopupShown
                    )
                }
            }
            
            NavigationLink(isActive: $blockedUsersShown) {
                BlockedUsersView()
            } label: {
                EmptyView()
            }
            .opacity(0) // Fixes showing accessibility button shape

            NavigationLink(isActive: $isNewChatShown) {
                NewChatView(isNewChatShown: $isNewChatShown)
            } label: {
                EmptyView()
            }
            .isDetailLink(UIDevice.current.userInterfaceIdiom == .pad)
            .opacity(0) // Fixes showing accessibility button shape
            .alert(isPresented: $logoutAlertShown) {
                Alert(
                    title: Text("Sign out"),
                    message: Text("Are you sure you want to sign out?"),
                    primaryButton: .destructive(Text("Sign out")) {
                        withAnimation {
                            chatClient.logout {
                                UnsecureRepository.shared.removeCurrentUser()
                                DispatchQueue.main.async {
                                    AppState.shared.userState = .notLoggedIn
                                }
                            }
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            .confirmationDialog("", isPresented: $actionsPopupShown) {
                Button("Choose Channel Query") {
                    isChooseChannelQueryShown = true
                }
                Button("Show Blocked Users") {
                    blockedUsersShown = true
                }
                
                Button("Logout", role: .destructive) {
                    logoutAlertShown = true
                }
                
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Select an action")
            }
            .confirmationDialog("", isPresented: $isChooseChannelQueryShown) {
                ChooseChannelQueryView()
            } message: {
                Text("Choose a channel query")
            }
        }
    }
}
