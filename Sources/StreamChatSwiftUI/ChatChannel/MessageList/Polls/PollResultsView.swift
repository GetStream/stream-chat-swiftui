//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct PollResultsView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var viewModel: PollAttachmentViewModel
    
    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts
    
    private let numberOfItemsShown = 5
    
    var body: some View {
        if #available(iOS 16, *) {
            NavigationStack {
                content
            }
        } else {
            NavigationView {
                content
            }
        }
    }
    
    var content: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                HStack {
                    Text(viewModel.poll.name)
                        .bold()
                    Spacer()
                }
                .withPollsBackground()
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                ForEach(viewModel.poll.options) { option in
                    PollOptionResultsView(
                        poll: viewModel.poll,
                        option: option,
                        votes: Array(
                            option.latestVotes
                                .prefix(numberOfItemsShown)
                        ),
                        hasMostVotes: viewModel.hasMostVotes(for: option),
                        allButtonShown: option.latestVotes.count > numberOfItemsShown
                    )
                }
                Spacer()
            }
        }
        .background(Color(colors.background).ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(L10n.Message.Polls.Toolbar.resultsTitle)
                    .bold()
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PollOptionResultsView: View {
    
    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts
    
    var poll: Poll
    var option: PollOption
    var votes: [PollVote]
    var hasMostVotes: Bool = false
    var allButtonShown = false
    var onVoteAppear: ((PollVote) -> Void)?
    
    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Text(option.text)
                    .font(fonts.bodyBold)
                Spacer()
                if hasMostVotes {
                    Image(systemName: "trophy")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 16)
                }
                Text(L10n.Message.Polls.votes(poll.voteCountsByOption?[option.id] ?? 0))
            }
            
            ForEach(votes, id: \.displayId) { vote in
                HStack {
                    if poll.votingVisibility != .anonymous {
                        MessageAvatarView(
                            avatarURL: vote.user?.imageURL,
                            size: .init(width: 20, height: 20)
                        )
                    }
                    Text(vote.user?.name ?? (vote.user?.id ?? L10n.Message.Polls.unknownVoteAuthor))
                    Spacer()
                    PollDateIndicatorView(date: vote.createdAt)
                }
                .onAppear {
                    onVoteAppear?(vote)
                }
            }
            
            if allButtonShown {
                NavigationLink {
                    PollOptionAllVotesView(poll: poll, option: option)
                } label: {
                    Text(L10n.Message.Polls.Button.showAll)
                }
            }
        }
        .withPollsBackground()
        .padding(.horizontal)
    }
}

extension PollVote: Identifiable {
    var displayId: String {
        "\(id)-\(optionId ?? user?.id ?? "")-\(pollId)"
    }
}
