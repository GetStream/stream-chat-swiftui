//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct ReactionsDetailView: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens
    @Injected(\.images) private var images

    @StateObject var viewModel: ReactionsDetailViewModel

    @Environment(\.presentationMode) var presentationMode

    init(message: ChatMessage) {
        _viewModel = StateObject(wrappedValue: .init(message: message))
    }

    init(viewModel: ReactionsDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            Text(L10n.Reaction.Authors.numberOfReactions(viewModel.totalReactionsCount))
                .font(fonts.bodyBold)
                .foregroundColor(Color(colors.text))
                .padding(.vertical, tokens.spacingXl)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: tokens.spacingXs) {
                    addReactionChip
                    ForEach(viewModel.reactionTypes) { type in
                        reactionTypeChip(type: type)
                    }
                }
                .padding(.horizontal, tokens.spacingMd)
            }
            .padding(.bottom, tokens.spacingSm)

            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.filteredReactions) { reaction in
                        VStack(spacing: 0) {
                            reactionRow(reaction: reaction)
                        }
                        .onAppear {
                            viewModel.onReactionAppear(reaction)
                        }
                    }
                }
            }
        }
        .background(Color(colors.background).edgesIgnoringSafeArea(.bottom))
        .sheet(isPresented: $viewModel.moreReactionsPickerShown) {
            MoreReactionsView { emoji in
                let reaction = MessageReactionType(rawValue: emoji)
                withAnimation {
                    viewModel.reactionTapped(reaction)
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .modifier(PresentationDetentsModifier(sheetSizes: [.medium, .large]))
        }
    }

    // MARK: - Filter Chips

    private var addReactionChip: some View {
        Button {
            withAnimation {
                viewModel.moreReactionsPickerShown = true
            }
        } label: {
            Image(uiImage: images.reactionDetailsShowPicker)
                .renderingMode(.template)
                .font(fonts.body)
                .foregroundColor(Color(colors.textPrimary))
                .padding(.horizontal, tokens.spacingSm)
                .padding(.vertical, tokens.spacingXs)
                .background(
                    Capsule()
                        .fill(Color(colors.background))
                )
                .overlay(
                    Capsule()
                        .strokeBorder(Color(colors.borderCoreDefault), lineWidth: 1)
                )
        }
    }

    private func reactionTypeChip(type: MessageReactionType) -> some View {
        Button {
            withAnimation {
                if viewModel.selectedReactionType == type {
                    viewModel.selectedReactionType = nil
                } else {
                    viewModel.selectedReactionType = type
                }
            }
        } label: {
            HStack(spacing: tokens.spacingXxs) {
                if let image = ReactionsIconProvider.icon(for: type, useLargeIcons: false) {
                    ReactionIcon(icon: image, color: nil)
                        .frame(width: 20, height: 20)
                }
                Text("\(viewModel.reactionCount(for: type))")
                    .font(fonts.footnoteBold)
                    .foregroundColor(Color(colors.chipText))
            }
            .padding(.horizontal, tokens.spacingSm)
            .padding(.vertical, tokens.spacingXs)
            .background(
                Capsule()
                    .fill(viewModel.selectedReactionType == type ? Color(colors.backgroundCoreSelected) : Color(colors.background))
            )
            .overlay(
                Capsule()
                    .strokeBorder(Color(colors.borderCoreDefault), lineWidth: 1)
            )
        }
    }

    // MARK: - Reaction Row

    private func reactionRow(reaction: ChatMessageReaction) -> some View {
        let isCurrentUser = viewModel.isCurrentUser(reaction)
        return HStack(spacing: tokens.spacingSm) {
            UserAvatar(
                user: reaction.author,
                size: AvatarSize.large,
                showsIndicator: false,
                showsBorder: false
            )

            Button {
                withAnimation {
                    viewModel.remove(reaction: reaction)
                }
            } label: {
                VStack(alignment: .leading, spacing: tokens.spacingXxxs) {
                    Text(viewModel.authorName(for: reaction))
                        .lineLimit(1)
                        .font(fonts.bodyBold)
                        .foregroundColor(Color(colors.textPrimary))

                    if isCurrentUser {
                        Text(L10n.Message.Reactions.tapToRemove)
                            .font(fonts.footnote)
                            .foregroundColor(Color(colors.textTertiary))
                    }
                }
            }
            .disabled(!isCurrentUser)

            Spacer()

            if let image = ReactionsIconProvider.icon(for: reaction.type, useLargeIcons: true) {
                ReactionIcon(icon: image, color: nil)
                    .frame(width: 28, height: 28)
            }
        }
        .padding(.horizontal, tokens.spacingMd)
        .padding(.vertical, tokens.spacingSm)
    }
}
