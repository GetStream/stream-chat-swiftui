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
                    Spacer()
                }
                
                HStack {
                    Text(subtitleText)
                        .font(fonts.caption1)
                        .foregroundColor(Color(colors.textLowEmphasis))
                    Spacer()
                }
            }
            
            ForEach(options.prefix(10)) { option in
                PollOptionView(
                    viewModel: viewModel,
                    option: option,
                    optionVotes: poll.voteCountsByOption?[option.id],
                    maxVotes: poll.voteCountsByOption?.values.max()
                )
            }
            
            if options.count > 10 {
                Button {
                    viewModel.allOptionsShown = true
                } label: {
                    Text(L10n.Message.Polls.Button.seeMoreOptions(options.count - 10))
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
                    viewModel.showsEndVoteConfirmation = true
                } label: {
                    Text(L10n.Message.Polls.Button.endVote)
                }
                .actionSheet(isPresented: $viewModel.showsEndVoteConfirmation) {
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
            return L10n.Message.Polls.Subtitle.selectUpTo(maxVotes)
        } else {
            return L10n.Message.Polls.Subtitle.selectOneOrMore
        }
    }
}

extension PollOption: Identifiable {}

struct PollOptionView: View {
    
    @ObservedObject var viewModel: PollAttachmentViewModel
    
    var option: PollOption
    var optionFont: Font = InjectedValues[\.fonts].body
    var optionVotes: Int?
    var maxVotes: Int?
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(alignment: .top) {
                if !viewModel.poll.isClosed {
                    Button {
                        if viewModel.optionVotedByCurrentUser(option) {
                            viewModel.removePollVote(for: option)
                        } else {
                            viewModel.castPollVote(for: option)
                        }
                    } label: {
                        if viewModel.optionVotedByCurrentUser(option) {
                            Image(systemName: "checkmark.circle.fill")
                        } else {
                            Image(systemName: "circle")
                        }
                    }
                }

                Text(option.text)
                    .font(optionFont)
                Spacer()
                if viewModel.showVoterAvatars {
                    HStack(spacing: -4) {
                        ForEach(
                            option.latestVotes.sorted(by: { $0.createdAt > $1.createdAt }).suffix(2)
                        ) { vote in
                            MessageAvatarView(
                                avatarURL: vote.user?.imageURL,
                                size: .init(width: 20, height: 20)
                            )
                        }
                    }
                }
                Text("\(viewModel.poll.voteCountsByOption?[option.id] ?? 0)")
            }
            
            PollVotesIndicatorView(
                alternativeStyle: viewModel.poll.isClosed && viewModel.hasMostVotes(for: option),
                optionVotes: optionVotes ?? 0,
                maxVotes: maxVotes ?? 0
            )
            .padding(.leading, 24)
        }
    }
}

struct PollVotesIndicatorView: View {
    
    @Injected(\.colors) var colors
    
    let alternativeStyle: Bool
    var optionVotes: Int
    var maxVotes: Int
    
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
