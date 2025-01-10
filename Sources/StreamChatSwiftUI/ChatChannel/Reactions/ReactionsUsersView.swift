//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View displaying users who have reacted to a message.
struct ReactionsUsersView: View {
    @StateObject private var viewModel: ReactionsUsersViewModel
    
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors

    var maxHeight: CGFloat

    private static let columnCount = 4
    private static let itemSize: CGFloat = 64

    private let columns = Array(
        repeating: GridItem(.adaptive(minimum: itemSize), alignment: .top),
        count: columnCount
    )
    
    init(message: ChatMessage, maxHeight: CGFloat) {
        self.maxHeight = maxHeight
        _viewModel = StateObject(wrappedValue: ReactionsUsersViewModel(message: message))
    }

    init(viewModel: ReactionsUsersViewModel, maxHeight: CGFloat) {
        self.maxHeight = maxHeight
        _viewModel = StateObject(wrappedValue: viewModel)
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

                if viewModel.reactions.count > Self.columnCount {
                    ScrollView {
                        LazyVGrid(columns: columns, alignment: .center, spacing: 8) {
                            ForEach(viewModel.reactions) { reaction in
                                ReactionUserView(
                                    reaction: reaction,
                                    imageSize: Self.itemSize
                                )
                            }
                        }
                    }
                    .frame(maxHeight: maxHeight)
                } else {
                    HStack(alignment: .top, spacing: 0) {
                        ForEach(viewModel.reactions) { reaction in
                            ReactionUserView(
                                reaction: reaction,
                                imageSize: Self.itemSize
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

class ReactionsUsersViewModel: ObservableObject, ChatMessageControllerDelegate {
    @Published var reactions: [ChatMessageReaction] = []

    var totalReactionsCount: Int {
        messageController?.message?.totalReactionsCount ?? 0
    }

    var isRightAligned: Bool {
        messageController?.message?.isRightAligned == true
    }

    private var isLoading = false
    private let messageController: ChatMessageController?
    
    init(message: ChatMessage) {
        if let cid = message.cid {
            messageController = InjectedValues[\.chatClient].messageController(
                cid: cid,
                messageId: message.id
            )
        } else {
            messageController = nil
        }
        messageController?.delegate = self
        loadMoreReactions()
    }

    func loadMoreReactions() {
        guard let messageController = self.messageController else {
            return
        }
        guard !isLoading && messageController.hasLoadedAllReactions == false else {
            return
        }

        isLoading = true
        messageController.loadNextReactions { [weak self] _ in
            self?.isLoading = false
        }
    }

    func messageController(_ controller: ChatMessageController, didChangeReactions reactions: [ChatMessageReaction]) {
        self.reactions = reactions
    }
}

extension ChatMessageReaction: Identifiable {

    public var id: String {
        "\(author.id)-\(type.rawValue)"
    }
}
