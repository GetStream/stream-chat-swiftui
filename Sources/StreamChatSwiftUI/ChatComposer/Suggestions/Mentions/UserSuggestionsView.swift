//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View for the user suggestions.
public struct UserSuggestionsView<Factory: ViewFactory>: View {
    @Injected(\.tokens) private var tokens

    var factory: Factory
    private let itemHeight: CGFloat = 40

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
            LazyVStack(spacing: 0) {
                ForEach(users) { user in
                    UserSuggestionView(
                        factory: factory,
                        user: user,
                        userSelected: userSelected
                    )
                }
            }
        }
        .padding(.vertical, tokens.spacingXs)
        .frame(height: viewHeight)
        .animation(.easeInOut, value: users.count)
    }

    private var viewHeight: CGFloat {
        let verticalPadding = tokens.spacingXs * 2
        let maxVisible: CGFloat = 4
        let contentHeight = CGFloat(users.count) * itemHeight + verticalPadding
        let maxHeight = maxVisible * itemHeight + verticalPadding
        let minHeight = itemHeight + verticalPadding
        return max(minHeight, min(contentHeight, maxHeight))
    }
}

/// View for a single user suggestion row.
public struct UserSuggestionView<Factory: ViewFactory>: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.tokens) private var tokens

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
        Button {
            userSelected(user)
        } label: {
            HStack(spacing: tokens.spacingSm) {
                factory.makeUserAvatarView(
                    options: .init(
                        user: user,
                        size: AvatarSize.medium,
                        showsIndicator: false
                    )
                )

                Text(user.name ?? user.id)
                    .lineLimit(1)
                    .font(fonts.body)
                    .foregroundColor(Color(colors.textPrimary))

                Spacer()
            }
            .padding(.horizontal, tokens.spacingMd)
            .padding(.vertical, tokens.spacingXxs)
        }
    }
}
