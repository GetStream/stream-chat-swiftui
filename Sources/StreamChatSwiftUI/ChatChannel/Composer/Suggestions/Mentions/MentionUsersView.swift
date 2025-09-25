//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View for the mentioned users.
public struct MentionUsersView: View {
    @Injected(\.colors) private var colors

    private let itemHeight: CGFloat = 60

    var users: [ChatUser]
    var userSelected: (ChatUser) -> Void

    public var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(users) { user in
                    MentionUserView(
                        user: user,
                        userSelected: userSelected
                    )
                }
            }
            .animation(nil)
        }
        .frame(height: viewHeight)
        .background(Color(colors.background))
        .modifier(ShadowViewModifier())
        .padding(.all, 8)
        .animation(.spring())
    }

    private var viewHeight: CGFloat {
        if users.count > 3 {
            3 * itemHeight
        } else {
            CGFloat(users.count) * itemHeight
        }
    }
}

/// View for one user that can be mentioned.
public struct MentionUserView: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.utils) private var utils

    var user: ChatUser
    var userSelected: (ChatUser) -> Void

    public var body: some View {
        HStack {
            MessageAvatarView(
                avatarURL: user.imageURL,
                showOnlineIndicator: true
            )
            Text(user.name ?? user.id)
                .lineLimit(1)
                .font(fonts.bodyBold)
            Spacer()
            Text(utils.commandsConfig.mentionsSymbol)
                .font(fonts.title)
                .foregroundColor(colors.tintColor)
        }
        .standardPadding()
        .highPriorityGesture(
            TapGesture()
                .onEnded { _ in
                    userSelected(user)
                }
        )
    }
}
