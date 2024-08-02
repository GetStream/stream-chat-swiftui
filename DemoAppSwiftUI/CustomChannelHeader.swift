//
// Copyright © 2024 Stream.io Inc. All rights reserved.
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
                    .foregroundColor(Color.white)
                    .padding(.all, 8)
                    .background(colors.tintColor)
                    .clipShape(Circle())
            }
        }
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                actionsPopupShown = true
            } label: {
                StreamLazyImage(url: currentUserController.currentUser?.imageURL)
            }
        }
    }
}

struct CustomChannelModifier: ChannelListHeaderViewModifier {

    @Injected(\.chatClient) var chatClient

    var title: String

    @State var isNewChatShown = false
    @State var logoutAlertShown = false
    @State var actionsPopupShown = false
    @State var blockedUsersShown = false

    func body(content: Content) -> some View {
        ZStack {
            content.toolbar {
                CustomChannelHeader(
                    title: title,
                    currentUserController: chatClient.currentUserController(),
                    isNewChatShown: $isNewChatShown,
                    actionsPopupShown: $actionsPopupShown
                )
            }
            
            NavigationLink(isActive: $blockedUsersShown) {
                BlockedUsersView()
            } label: {
                EmptyView()
            }

            NavigationLink(isActive: $isNewChatShown) {
                NewChatView(isNewChatShown: $isNewChatShown)
            } label: {
                EmptyView()
            }
            .isDetailLink(UIDevice.current.userInterfaceIdiom == .pad)
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
                Button("Blocked users") {
                    blockedUsersShown = true
                }
                
                Button("Logout") {
                    logoutAlertShown = true
                }
                
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Select an action")
            }
        }
    }
}
