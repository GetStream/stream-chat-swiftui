//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View for the add users popup.
struct AddUsersView<Factory: ViewFactory>: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors

    private let columns = Array(
        repeating:
        GridItem(
            .adaptive(minimum: 64),
            alignment: .top
        ),
        count: 4
    )
    
    private let factory: Factory

    @StateObject private var viewModel: AddUsersViewModel
    var onUserTap: (ChatUser) -> Void

    init(
        factory: Factory = DefaultViewFactory.shared,
        loadedUserIds: [String],
        onUserTap: @escaping (ChatUser) -> Void
    ) {
        _viewModel = StateObject(
            wrappedValue: AddUsersViewModel(loadedUserIds: loadedUserIds)
        )
        self.onUserTap = onUserTap
        self.factory = factory
    }

    init(
        factory: Factory = DefaultViewFactory.shared,
        viewModel: AddUsersViewModel,
        onUserTap: @escaping (ChatUser) -> Void
    ) {
        _viewModel = StateObject(
            wrappedValue: viewModel
        )
        self.onUserTap = onUserTap
        self.factory = factory
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
                                let itemSize: CGFloat = 64
                                let userDisplayInfo = UserDisplayInfo(
                                    id: user.id,
                                    name: user.name ?? "",
                                    imageURL: user.imageURL,
                                    size: CGSize(width: itemSize, height: itemSize),
                                    extraData: user.extraData
                                )
                                factory.makeMessageAvatarView(for: userDisplayInfo)

                                Text(user.name ?? user.id)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                    .font(fonts.footnoteBold)
                                    .frame(width: itemSize)
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
