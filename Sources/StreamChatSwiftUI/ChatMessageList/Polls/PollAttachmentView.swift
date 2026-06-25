//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

public struct PollAttachmentView<Factory: ViewFactory>: View {
    @Injected(\.chatClient) var chatClient
    @Injected(\.fonts) var fonts
    @Injected(\.colors) var colors
    @Injected(\.tokens) var tokens
    @Injected(\.utils) var utils

    private let factory: Factory
    private let message: ChatMessage
    private let isFirst: Bool
    private let width: CGFloat

    @StateObject var viewModel: PollAttachmentViewModel

    public init(
        factory: Factory,
        message: ChatMessage,
        poll: Poll,
        isFirst: Bool,
        width: CGFloat
    ) {
        self.factory = factory
        self.message = message
        self.isFirst = isFirst
        self.width = width
        _viewModel = StateObject(
            wrappedValue: PollAttachmentViewModel(
                message: message,
                poll: poll
            )
        )
    }

    public var body: some View {
        VStack(spacing: tokens.spacingLg) {
            VStack(alignment: .leading, spacing: tokens.spacingXxs) {
                HStack {
                    Text(poll.name)
                        .font(fonts.bodyBold)
                        .foregroundColor(textColor(for: message))
                    Spacer()
                }

                HStack {
                    Text(subtitleText)
                        .font(fonts.subheadline)
                        .foregroundColor(textColor(for: message))
                    Spacer()
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(headerAccessibilityLabel)
            .accessibilityAddTraits(.isHeader)

            VStack(spacing: tokens.spacingMd) {
                ForEach(
                    Array(options.prefix(PollAttachmentViewModel.numberOfVisibleOptionsShown).enumerated()),
                    id: \.element.id
                ) { index, option in
                    PollOptionView(
                        viewModel: viewModel,
                        factory: factory,
                        option: option,
                        optionVotes: poll.voteCount(for: option),
                        maxVotes: poll.currentMaximumVoteCount,
                        message: message,
                        optionIndex: index + 1,
                        optionsCount: options.count
                    )
                    .layoutPriority(1) // do not compress long text
                }
            }

            VStack(spacing: tokens.spacingXs) {
                if options.count > PollAttachmentViewModel.numberOfVisibleOptionsShown {
                    StreamTextButton(role: .secondary, style: .ghost, size: .small) {
                        viewModel.allOptionsShown = true
                    } text: {
                        Text(
                            L10n.Message.Polls.Button
                                .seeMoreOptions(options.count - PollAttachmentViewModel.numberOfVisibleOptionsShown)
                        )
                        .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                    .fullScreenCover(isPresented: $viewModel.allOptionsShown) {
                        PollAllOptionsView(viewModel: viewModel, factory: factory)
                    }
                }

                StreamTextButton(role: outlineButtonRole, style: .outline, size: .small) {
                    viewModel.pollResultsShown = true
                } text: {
                    Text(L10n.Message.Polls.Button.viewResults)
                        .foregroundColor(Color(colors.buttonSecondaryText))
                        .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
                .fullScreenCover(isPresented: $viewModel.pollResultsShown) {
                    PollResultsView(viewModel: viewModel, factory: factory)
                }

                if viewModel.showEndVoteButton {
                    StreamTextButton(role: outlineButtonRole, style: .outline, size: .small) {
                        viewModel.endVoteConfirmationShown = true
                    } text: {
                        Text(L10n.Message.Polls.Button.endVote)
                            .foregroundColor(Color(colors.buttonSecondaryText))
                            .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                    .alert(isPresented: $viewModel.endVoteConfirmationShown) {
                        Alert(
                            title: Text(L10n.Alert.Title.endPoll),
                            message: Text(L10n.Alert.Message.endPoll),
                            primaryButton: .destructive(Text(L10n.Alert.Actions.endPoll)) {
                                viewModel.endVote()
                            },
                            secondaryButton: .cancel(Text(L10n.Alert.Actions.cancel))
                        )
                    }
                }

                if viewModel.showSuggestOptionButton {
                    StreamTextButton(role: .secondary, style: .ghost, size: .small) {
                        viewModel.suggestOptionShown = true
                    } text: {
                        Text(L10n.Message.Polls.Button.suggestAnOption)
                            .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                    .uiAlert(
                        title: L10n.Alert.Title.suggestAnOption,
                        isPresented: $viewModel.suggestOptionShown,
                        text: $viewModel.suggestOptionText,
                        placeholder: L10n.Alert.TextField.pollsNewOption,
                        accept: L10n.Alert.Actions.send,
                        action: { viewModel.suggest(option: viewModel.suggestOptionText) }
                    )
                }

                if viewModel.showAddCommentButton {
                    StreamTextButton(role: .secondary, style: .ghost, size: .small) {
                        viewModel.addCommentShown = true
                    } text: {
                        Text(L10n.Message.Polls.Button.addComment)
                            .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                    .uiAlert(
                        title: L10n.Alert.Title.addComment,
                        isPresented: $viewModel.addCommentShown,
                        text: $viewModel.commentText,
                        placeholder: L10n.Alert.TextField.pollAddComment,
                        accept: L10n.Alert.Actions.send,
                        action: { viewModel.add(comment: viewModel.commentText) }
                    )
                }

                if viewModel.poll.answersCount > 0 {
                    StreamTextButton(role: .secondary, style: .ghost, size: .small) {
                        viewModel.allCommentsShown = true
                    } text: {
                        Text(L10n.Message.Polls.Button.viewNumberOfComments(viewModel.poll.answersCount))
                            .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                    .fullScreenCover(isPresented: $viewModel.allCommentsShown) {
                        PollCommentsView(factory: factory, poll: viewModel.poll, pollController: viewModel.pollController)
                    }
                }
            }
        }
        .disabled(!viewModel.canInteract)
        .padding(.horizontal, tokens.spacingMd)
        .padding(.top, tokens.spacingMd)
        .padding(.bottom, tokens.spacingLg)
        .modifier(
            factory.styles.makeMessageViewModifier(
                for: MessageModifierInfo(
                    message: message,
                    isFirst: isFirst
                )
            )
        )
        .frame(width: width)
    }

    private var outlineButtonRole: StreamButtonRole {
        message.isSentByCurrentUser ? .primary : .secondary
    }

    private var poll: Poll {
        viewModel.poll
    }

    private var options: [PollOption] {
        poll.options
    }

    private var headerAccessibilityLabel: String {
        L10n.Message.Polls.Accessibility.pollHeader(poll.name, subtitleText, options.count)
    }

    private var subtitleText: String {
        if poll.isClosed == true {
            L10n.Message.Polls.Subtitle.voteEnded
        } else if poll.enforceUniqueVote == true {
            L10n.Message.Polls.Subtitle.selectOne
        } else if let maxVotes = poll.maxVotesAllowed, maxVotes > 0 {
            L10n.Message.Polls.Subtitle.selectUpTo(min(maxVotes, poll.options.count))
        } else {
            L10n.Message.Polls.Subtitle.selectOneOrMore
        }
    }
}

struct PollOptionView<Factory: ViewFactory>: View {
    @Injected(\.colors) var colors
    @Injected(\.tokens) var tokens
    @Injected(\.fonts) var fonts

    @ObservedObject var viewModel: PollAttachmentViewModel

    let factory: Factory
    let option: PollOption
    var optionFont: Font = InjectedValues[\.fonts].subheadline
    var optionVotes: Int?
    var maxVotes: Int?
    var message: ChatMessage
    /// If true, forces incoming color style for the radio button border and progress track,
    /// regardless of whether the message was sent by the current user.
    var forceIncomingStyle: Bool = false
    /// The 1-based position of this option, used for the VoiceOver announcement.
    var optionIndex: Int?
    /// The total number of options, used for the VoiceOver announcement.
    var optionsCount: Int?

    var body: some View {
        HStack(alignment: .top, spacing: tokens.spacingSm) {
            if !viewModel.poll.isClosed {
                Button {
                    togglePollVote()
                } label: {
                    RadioCheckView(
                        isSelected: viewModel.optionVotedByCurrentUser(option),
                        borderColorOverride: (!forceIncomingStyle && message.isSentByCurrentUser)
                            ? colors.chatBorderOnChatOutgoing
                            : colors.chatBorderOnChatIncoming
                    )
                }
                .padding(.top, tokens.spacingXxs)
            }
            VStack(spacing: tokens.spacingXxs) {
                HStack(alignment: .top, spacing: tokens.spacingXs) {
                    Text(option.text)
                        .font(optionFont)
                        .foregroundColor(textColor(for: message))
                        .padding(.top, tokens.spacingXxxs)
                    Spacer()
                    HStack(spacing: tokens.spacingXs) {
                        if viewModel.showVoterAvatars {
                            HStack(spacing: -4) {
                                ForEach(
                                    option.latestVotes.compactMap(\.user).prefix(2)
                                ) { user in
                                    factory.makeUserAvatarView(
                                        options: UserAvatarViewOptions(
                                            user: user,
                                            size: AvatarSize.extraSmall,
                                            showsIndicator: false
                                        )
                                    )
                                }
                            }
                            .frame(height: AvatarSize.extraSmall)
                        }
                        Text("\(viewModel.poll.voteCountsByOption?[option.id] ?? 0)")
                            .font(fonts.footnote)
                            .foregroundColor(textColor(for: message))
                    }
                }
                
                PollVotesIndicatorView(
                    optionVotes: optionVotes ?? 0,
                    maxVotes: maxVotes ?? 0,
                    isOutgoing: forceIncomingStyle ? false : message.isSentByCurrentUser
                )
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            togglePollVote()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(viewModel.poll.isClosed ? [] : .isButton)
        .accessibilityAction {
            guard !viewModel.poll.isClosed else { return }
            togglePollVote()
        }
    }

    private var accessibilityLabel: String {
        let isSelected = viewModel.optionVotedByCurrentUser(option)
        let stateText = isSelected
            ? L10n.Message.Polls.Accessibility.selected
            : L10n.Message.Polls.Accessibility.notSelected
        let count = viewModel.poll.voteCountsByOption?[option.id] ?? 0
        let votesText: String
        if isSelected, count > 1 {
            votesText = L10n.Message.Polls.Accessibility.votesIncludingYours(count)
        } else if count == 1 {
            votesText = L10n.Message.Polls.voteSingular(count)
        } else {
            votesText = L10n.Message.Polls.votes(count)
        }
        var label = L10n.Message.Polls.Accessibility.option(option.text, stateText, votesText)
        if let optionIndex, let optionsCount {
            label += ". " + L10n.Message.Polls.Accessibility.optionPosition(optionIndex, optionsCount)
        }
        return label
    }

    func togglePollVote() {
        if viewModel.optionVotedByCurrentUser(option) {
            viewModel.removePollVote(for: option)
        } else {
            viewModel.castPollVote(for: option)
        }
    }
}

struct PollVotesIndicatorView: View {
    @Injected(\.colors) var colors
    @Injected(\.tokens) var tokens

    let optionVotes: Int
    let maxVotes: Int
    var isOutgoing: Bool = false

    private let height: CGFloat = 8

    var body: some View {
        Capsule()
            .fill(Color(trackColor))
            .overlay(
                GeometryReader { reader in
                    HStack(spacing: 0) {
                        Capsule()
                            .fill(Color(fillColor))
                            .frame(width: reader.size.width * ratio)
                        Spacer(minLength: 0)
                    }
                }
            )
            .frame(height: height)
    }

    private var trackColor: UIColor {
        isOutgoing ? colors.chatPollProgressTrackOutgoing : colors.chatPollProgressTrackIncoming
    }

    private var fillColor: UIColor {
        isOutgoing ? colors.chatPollProgressFillOutgoing : colors.chatPollProgressFillIncoming
    }

    var ratio: CGFloat {
        CGFloat(optionVotes) / CGFloat(max(maxVotes, 1))
    }
}
