//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

public struct PollAttachmentView<Factory: ViewFactory>: View {
    
    @Injected(\.chatClient) var chatClient
    @Injected(\.fonts) var fonts
    @Injected(\.colors) var colors
    
    private let factory: Factory
    private let message: ChatMessage
    private let isFirst: Bool
    
    @StateObject var viewModel: PollAttachmentViewModel
    
    public init(
        factory: Factory,
        message: ChatMessage,
        poll: Poll,
        isFirst: Bool
    ) {
        self.factory = factory
        self.message = message
        self.isFirst = isFirst
        _viewModel = StateObject(
            wrappedValue: PollAttachmentViewModel(
                message: message,
                poll: poll
            )
        )
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(poll.name)
                        .font(fonts.bodyBold)
                        .foregroundColor(textColor(for: message))
                    Spacer()
                }
                
                HStack {
                    Text(subtitleText)
                        .font(fonts.caption1)
                        .foregroundColor(Color(colors.textLowEmphasis))
                    Spacer()
                }
            }
            
            ForEach(options.prefix(PollAttachmentViewModel.numberOfVisibleOptionsShown)) { option in
                PollOptionView(
                    viewModel: viewModel,
                    option: option,
                    optionVotes: poll.voteCount(for: option),
                    maxVotes: poll.currentMaximumVoteCount,
                    textColor: textColor(for: message)
                )
                .layoutPriority(1) // do not compress long text
            }
            
            if options.count > PollAttachmentViewModel.numberOfVisibleOptionsShown {
                Button {
                    viewModel.allOptionsShown = true
                } label: {
                    Text(
                        L10n.Message.Polls.Button
                            .seeMoreOptions(options.count - PollAttachmentViewModel.numberOfVisibleOptionsShown)
                    )
                }
                .fullScreenCover(isPresented: $viewModel.allOptionsShown) {
                    PollAllOptionsView(viewModel: viewModel)
                }
            }
            
            if viewModel.showSuggestOptionButton {
                Button {
                    viewModel.suggestOptionShown = true
                } label: {
                    Text(L10n.Message.Polls.Button.suggestAnOption)
                }
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
                Button {
                    viewModel.addCommentShown = true
                } label: {
                    Text(L10n.Message.Polls.Button.addComment)
                }
                .uiAlert(
                    title: L10n.Alert.Title.addComment,
                    isPresented: $viewModel.addCommentShown,
                    text: $viewModel.commentText,
                    accept: L10n.Alert.Actions.send,
                    action: { viewModel.add(comment: viewModel.commentText) }
                )
            }
            
            if viewModel.poll.answersCount > 0 {
                Button {
                    viewModel.allCommentsShown = true
                } label: {
                    Text(L10n.Message.Polls.Button.viewNumberOfComments(viewModel.poll.answersCount))
                }
                .fullScreenCover(isPresented: $viewModel.allCommentsShown) {
                    PollCommentsView(poll: viewModel.poll, pollController: viewModel.pollController)
                }
            }
            
            Button {
                viewModel.pollResultsShown = true
            } label: {
                Text(L10n.Message.Polls.Button.viewResults)
            }
            .fullScreenCover(isPresented: $viewModel.pollResultsShown) {
                PollResultsView(viewModel: viewModel)
            }
            
            if viewModel.showEndVoteButton {
                Button {
                    viewModel.endVoteConfirmationShown = true
                } label: {
                    Text(L10n.Message.Polls.Button.endVote)
                }
                .actionSheet(isPresented: $viewModel.endVoteConfirmationShown) {
                    ActionSheet(
                        title: Text(L10n.Alert.Title.endPoll),
                        buttons: [
                            .destructive(Text(L10n.Alert.Actions.end)) {
                                viewModel.endVote()
                            },
                            .cancel(Text(L10n.Alert.Actions.cancel))
                        ]
                    )
                }
            }
        }
        .disabled(!viewModel.canInteract)
        .padding()
        .modifier(
            factory.makeMessageViewModifier(
                for: MessageModifierInfo(
                    message: message,
                    isFirst: isFirst
                )
            )
        )
    }
    
    private var poll: Poll {
        viewModel.poll
    }
    
    private var options: [PollOption] {
        poll.options
    }
    
    private var subtitleText: String {
        if poll.isClosed == true {
            return L10n.Message.Polls.Subtitle.voteEnded
        } else if poll.enforceUniqueVote == true {
            return L10n.Message.Polls.Subtitle.selectOne
        } else if let maxVotes = poll.maxVotesAllowed, maxVotes > 0 {
            return L10n.Message.Polls.Subtitle.selectUpTo(min(maxVotes, poll.options.count))
        } else {
            return L10n.Message.Polls.Subtitle.selectOneOrMore
        }
    }
}

extension PollOption: Identifiable {}

struct PollOptionView: View {
    
    @ObservedObject var viewModel: PollAttachmentViewModel
    
    let option: PollOption
    var optionFont: Font = InjectedValues[\.fonts].body
    var optionVotes: Int?
    var maxVotes: Int?
    var textColor: Color
    /// If true, only option name and vote count is shown, otherwise votes indicator and avatars appear as well.
    var alternativeStyle: Bool = false
    /// The spacing between the checkbox and the option name.
    /// By default it is 4. For All Options View is 8.
    var checkboxButtonSpacing: CGFloat = 4

    var body: some View {
        HStack(alignment: .top, spacing: checkboxButtonSpacing) {
            if !viewModel.poll.isClosed {
                Button {
                    togglePollVote()
                } label: {
                    if viewModel.optionVotedByCurrentUser(option) {
                        Image(systemName: "checkmark.circle.fill")
                    } else {
                        Image(systemName: "circle")
                    }
                }
            }
            VStack(spacing: 4) {
                HStack(alignment: .top) {
                    Text(option.text)
                        .font(optionFont)
                        .foregroundColor(textColor)
                    Spacer()
                    if !alternativeStyle, viewModel.showVoterAvatars {
                        HStack(spacing: -4) {
                            ForEach(
                                option.latestVotes.prefix(2)
                            ) { vote in
                                MessageAvatarView(
                                    avatarURL: vote.user?.imageURL,
                                    size: .init(width: 20, height: 20)
                                )
                            }
                        }
                    }
                    Text("\(viewModel.poll.voteCountsByOption?[option.id] ?? 0)")
                        .foregroundColor(textColor)
                }
                if !alternativeStyle {
                    PollVotesIndicatorView(
                        alternativeStyle: viewModel.poll.isClosed && viewModel.hasMostVotes(for: option),
                        optionVotes: optionVotes ?? 0,
                        maxVotes: maxVotes ?? 0
                    )
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            togglePollVote()
        }
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
    
    let alternativeStyle: Bool
    let optionVotes: Int
    let maxVotes: Int
    
    private let height: CGFloat = 4
    
    var body: some View {
        GeometryReader { reader in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(colors.background2))
                    .frame(width: reader.size.width, height: height)

                RoundedRectangle(cornerRadius: 8)
                    .fill(alternativeStyle ? Color(colors.alternativeActiveTint) : colors.tintColor)
                    .frame(width: reader.size.width * ratio, height: height)
            }
        }
        .frame(height: height)
    }
    
    var ratio: CGFloat {
        CGFloat(optionVotes) / CGFloat(max(maxVotes, 1))
    }
}
