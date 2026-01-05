//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View for the mentioned users.
public struct MentionUsersView<Factory: ViewFactory>: View {
    @Injected(\.colors) private var colors

    var factory: Factory
    private let itemHeight: CGFloat = 60

    var users: [ChatUser]
    var userSelected: (ChatUser) -> Void

    public init(
        factory: Factory = DefaultViewFactory.shared,
        users: [ChatUser],
        userSelected: @escaping (ChatUser) -> Void
    ) {
        self.factory = factory
        self.users = users
        self.userSelected = userSelected
    }

    public var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(users) { user in
                    MentionUserView(
                        factory: factory,
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
            return 3 * itemHeight
        } else {
            return CGFloat(users.count) * itemHeight
        }
    }
}

/// View for one user that can be mentioned.
public struct MentionUserView<Factory: ViewFactory>: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.utils) private var utils

    var factory: Factory
    var user: ChatUser
    var userSelected: (ChatUser) -> Void

    public init(
        factory: Factory = DefaultViewFactory.shared,
        user: ChatUser,
        userSelected: @escaping (ChatUser) -> Void
    ) {
        self.factory = factory
        self.user = user
        self.userSelected = userSelected
    }

    public var body: some View {
        HStack {
            let displayInfo = UserDisplayInfo(
                id: user.id,
                name: user.name ?? user.id,
                imageURL: user.imageURL
            )
            factory.makeMessageAvatarView(for: displayInfo)
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
