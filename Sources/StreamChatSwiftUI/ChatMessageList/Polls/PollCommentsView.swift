//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct PollCommentsView<Factory: ViewFactory>: View {
    @Injected(\.chatClient) var chatClient
    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts
    @Injected(\.tokens) var tokens

    @Environment(\.presentationMode) var presentationMode

    @StateObject var viewModel: PollCommentsViewModel
    let factory: Factory

    init(
        factory: Factory,
        poll: Poll,
        pollController: PollController,
        viewModel: PollCommentsViewModel? = nil
    ) {
        self.factory = factory
        _viewModel = StateObject(
            wrappedValue: viewModel ?? PollCommentsViewModel(
                poll: poll,
                pollController: pollController
            )
        )
    }

    var body: some View {
        NavigationContainerView(embedInNavigationView: true) {
            content
        }
    }

    private var content: some View {
        ScrollView {
            LazyVStack(spacing: tokens.spacingMd) {
                ForEach(viewModel.comments) { comment in
                    if let answer = comment.answerText {
                        commentCard(comment: comment, text: answer)
                            .onAppear { viewModel.onAppear(comment: comment) }
                    }
                }
            }
            .padding(.horizontal, tokens.spacingMd)
            .padding(.top, tokens.spacingMd)
            .padding(.bottom, tokens.spacing3xl)
        }
        .uiAlert(
            title: commentAlertTitle,
            isPresented: $viewModel.addCommentShown,
            text: $viewModel.newCommentText,
            accept: commentAlertAcceptAction,
            action: { viewModel.add(comment: viewModel.newCommentText) }
        )
        .background(Color(colors.background).ignoresSafeArea())
        .alertBanner(
            isPresented: $viewModel.errorShown,
            action: viewModel.refresh
        )
        .toolbarThemed {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
            }

            ToolbarItem(placement: .principal) {
                Text(L10n.Message.Polls.Toolbar.commentsTitle)
                    .font(fonts.bodyBold)
                    .foregroundColor(Color(colors.navigationBarTitle))
            }

            ToolbarItem(placement: .confirmationAction) {
                if viewModel.showsAddCommentButton && !viewModel.currentUserAddedComment {
                    addCommentButton
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Comment Card

    private func commentCard(comment: PollVote, text: String) -> some View {
        let isOwnComment = comment.user?.id == chatClient.currentUserId

        return VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: tokens.spacingXs) {
                Text(text)
                    .font(fonts.body)
                    .foregroundColor(Color(colors.textPrimary))
                    .frame(maxWidth: .infinity, alignment: .leading)

                commentMetaData(for: comment)
            }
            .padding(tokens.spacingMd)

            if isOwnComment && viewModel.showsAddCommentButton {
                updateCommentButton
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color(colors.backgroundCoreSurfaceCard))
        .cornerRadius(tokens.radiusLg)
    }

    private func commentMetaData(for comment: PollVote) -> some View {
        HStack(spacing: tokens.spacingXs) {
            if viewModel.pollController.poll?.votingVisibility != .anonymous,
               let user = comment.user {
                factory.makeUserAvatarView(
                    options: UserAvatarViewOptions(
                        user: user,
                        size: AvatarSize.small,
                        showsIndicator: false
                    )
                )
            }

            HStack(spacing: tokens.spacingXs) {
                Text(authorTitle(for: comment))
                    .font(fonts.subheadlineBold)
                    .foregroundColor(Color(colors.textSecondary))

                Text(timestampText(for: comment.createdAt))
                    .font(fonts.subheadline)
                    .foregroundColor(Color(colors.textTertiary))
                    .lineLimit(1)
            }
        }
    }

    // MARK: - Update / Add Comment Buttons

    private var updateCommentButton: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color(colors.borderCoreDefault))
            Button {
                viewModel.addCommentShown = true
            } label: {
                Text(L10n.Message.Polls.Button.updateComment)
                    .font(fonts.bodyBold)
                    .foregroundColor(Color(colors.buttonSecondaryText))
                    .frame(maxWidth: .infinity)
                    .frame(height: tokens.buttonHitTargetMinHeight)
            }
        }
        .padding(.horizontal, tokens.spacingMd)
    }

    @ViewBuilder
    private var addCommentButton: some View {
        if #available(iOS 26, *) {
            Button(L10n.Message.Polls.Button.addComment, systemImage: "pencil") {
                viewModel.addCommentShown = true
            }
            .tint(Color(colors.accentPrimary))
        } else {
            Button {
                viewModel.addCommentShown = true
            } label: {
                Image(systemName: "pencil")
                    .font(.system(size: tokens.iconSizeMd, weight: .medium))
                    .foregroundColor(Color(colors.buttonPrimaryTextOnAccent))
                    .frame(width: tokens.buttonVisualHeightMd, height: tokens.buttonVisualHeightMd)
                    .background(Color(colors.accentPrimary))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Helpers

    private var commentAlertTitle: String {
        viewModel.currentUserAddedComment
            ? L10n.Message.Polls.Button.updateComment
            : L10n.Message.Polls.Button.addComment
    }

    private var commentAlertAcceptAction: String {
        viewModel.currentUserAddedComment
            ? L10n.Alert.Actions.update
            : L10n.Alert.Actions.send
    }

    private func authorTitle(for comment: PollVote) -> String {
        if viewModel.pollController.poll?.votingVisibility == .anonymous {
            return L10n.Message.Polls.unknownVoteAuthor
        }
        if comment.user?.id == chatClient.currentUserId {
            return L10n.Message.Reactions.currentUser
        }
        return comment.user?.name ?? L10n.Message.Polls.unknownVoteAuthor
    }

    private func timestampText(for date: Date) -> String {
        let formatter = InjectedValues[\.utils].pollsDateFormatter
        let day = formatter.formatDay(date)
        let time = formatter.formatTime(date)
        return [day, time].joined(separator: " ")
    }
}
