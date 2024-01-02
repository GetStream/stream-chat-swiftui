//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View for the add users popup.
struct AddUsersView: View {

    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors

    private static let columnCount = 4
    private static let itemSize: CGFloat = 64

    private let columns = Array(
        repeating:
        GridItem(
            .adaptive(minimum: itemSize),
            alignment: .top
        ),
        count: columnCount
    )

    @StateObject private var viewModel: AddUsersViewModel
    var onUserTap: (ChatUser) -> Void

    init(
        loadedUserIds: [String],
        onUserTap: @escaping (ChatUser) -> Void
    ) {
        _viewModel = StateObject(
            wrappedValue: AddUsersViewModel(loadedUserIds: loadedUserIds)
        )
        self.onUserTap = onUserTap
    }

    init(
        viewModel: AddUsersViewModel,
        onUserTap: @escaping (ChatUser) -> Void
    ) {
        _viewModel = StateObject(
            wrappedValue: viewModel
        )
        self.onUserTap = onUserTap
    }

    var body: some View {
        VStack {
            SearchBar(text: $viewModel.searchText)

            ScrollView {
                LazyVGrid(columns: columns, alignment: .center, spacing: 0) {
                    ForEach(viewModel.users) { user in
                        Button {
                            onUserTap(user)
                        } label: {
                            VStack {
                                MessageAvatarView(
                                    avatarURL: user.imageURL,
                                    size: CGSize(width: Self.itemSize, height: Self.itemSize),
                                    showOnlineIndicator: false
                                )

                                Text(user.name ?? user.id)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                    .font(fonts.footnoteBold)
                                    .frame(width: Self.itemSize)
                                    .foregroundColor(Color(colors.text))
                            }
                            .padding(.all, 8)
                        }
                        .onAppear {
                            viewModel.onUserAppear(user)
                        }
                    }
                }
            }
            .frame(maxHeight: 240)
        }
        .standardPadding()
        .background(Color(colors.background))
        .cornerRadius(16)
        .padding()
    }
}
