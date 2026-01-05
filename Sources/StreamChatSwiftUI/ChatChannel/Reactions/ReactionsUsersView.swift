//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View displaying users who have reacted to a message.
struct ReactionsUsersView<Factory: ViewFactory>: View {
    @StateObject private var viewModel: ReactionsUsersViewModel
    
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors

    var factory: Factory
    var maxHeight: CGFloat

    let columnCount = 4
    let itemSize: CGFloat = 64

    private let columns: [GridItem]

    init(
        factory: Factory = DefaultViewFactory.shared,
        message: ChatMessage,
        maxHeight: CGFloat
    ) {
        self.factory = factory
        self.maxHeight = maxHeight
        _viewModel = StateObject(wrappedValue: ReactionsUsersViewModel(message: message))
        self.columns = Array(
            repeating: GridItem(.adaptive(minimum: itemSize), alignment: .top),
            count: columnCount
        )
    }

    init(
        factory: Factory = DefaultViewFactory.shared,
        viewModel: ReactionsUsersViewModel,
        maxHeight: CGFloat
    ) {
        self.factory = factory
        self.maxHeight = maxHeight
        _viewModel = StateObject(wrappedValue: viewModel)
        self.columns = Array(
            repeating: GridItem(.adaptive(minimum: itemSize), alignment: .top),
            count: columnCount
        )
    }

    var body: some View {
        HStack {
            if viewModel.isRightAligned {
                Spacer()
            }

            VStack(alignment: .center) {
                Text(L10n.Reaction.Authors.numberOfReactions(viewModel.totalReactionsCount))
                    .foregroundColor(Color(colors.text))
                    .font(fonts.title3)
                    .fontWeight(.bold)
                    .padding()

                if viewModel.reactions.count > columnCount {
                    ScrollView {
                        LazyVGrid(columns: columns, alignment: .center, spacing: 8) {
                            ForEach(viewModel.reactions) { reaction in
                                ReactionUserView(
                                    factory: factory,
                                    reaction: reaction,
                                    imageSize: itemSize
                                )
                            }
                        }
                    }
                    .frame(maxHeight: maxHeight)
                } else {
                    HStack(alignment: .top, spacing: 0) {
                        ForEach(viewModel.reactions) { reaction in
                            ReactionUserView(
                                factory: factory,
                                reaction: reaction,
                                imageSize: itemSize
                            )
                        }
                    }
                    .padding(.horizontal, 8)
                }
            }
            .background(Color(colors.background))
            .cornerRadius(16)

            if !viewModel.isRightAligned {
                Spacer()
            }
        }
        .accessibilityIdentifier("ReactionsUsersView")
    }
}

extension ChatMessageReaction: Identifiable {
    public var id: String {
        "\(author.id)-\(type.rawValue)"
    }
}
