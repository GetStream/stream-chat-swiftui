//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import NukeUI
import StreamChat
import StreamChatSwiftUI
import SwiftUI

public struct CustomChannelHeader: ToolbarContent {
    
    @Injected(\.fonts) var fonts
    @Injected(\.images) var images
    
    var title: String
    var currentUserController: CurrentChatUserController
    @Binding var isNewChatShown: Bool
    @Binding var logoutAlertShown: Bool
    
    public var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(title)
                .font(fonts.bodyBold)
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                isNewChatShown = true
            } label: {
                Image(uiImage: images.messageActionEdit)
                    .resizable()
            }
        }
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                logoutAlertShown = true
            } label: {
                LazyImage(source: currentUserController.currentUser?.imageURL)
                    .onDisappear(.reset)
                    .clipShape(Circle())
                    .frame(
                        width: 30,
                        height: 30
                    )
            }
        }
    }
}

struct CustomChannelModifier: ChannelListHeaderViewModifier {
    
    @Injected(\.chatClient) var chatClient
    
    var title: String
    
    @State var isNewChatShown = false
    @State var logoutAlertShown = false
    
    func body(content: Content) -> some View {
        ZStack {
            content.toolbar {
                CustomChannelHeader(
                    title: title,
                    currentUserController: chatClient.currentUserController(),
                    isNewChatShown: $isNewChatShown,
                    logoutAlertShown: $logoutAlertShown
                )
            }
            
            NavigationLink(isActive: $isNewChatShown) {
                NewChatView(isNewChatShown: $isNewChatShown)
            } label: {
                EmptyView()
            }
            .isDetailLink(false)
            .alert(isPresented: $logoutAlertShown) {
                Alert(
                    title: Text("Sign out"),
                    message: Text("Are you sure you want to sign out?"),
                    primaryButton: .destructive(Text("Sign out")) {
                        withAnimation {
                            AppState.shared.userState = .notLoggedIn
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}
