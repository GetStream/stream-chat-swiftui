//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct PollResultsView<Factory: ViewFactory>: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var viewModel: PollAttachmentViewModel
    
    let factory: Factory
    
    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts
    
    private let numberOfItemsShown = 5
    
    var body: some View {
        NavigationContainerView(embedInNavigationView: true) {
            content
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
                        factory: factory,
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
        .toolbarThemed {
            ToolbarItem(placement: .principal) {
                Text(L10n.Message.Polls.Toolbar.resultsTitle)
                    .bold()
                    .foregroundColor(Color(colors.navigationBarTitle))
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

struct PollOptionResultsView<Factory: ViewFactory>: View {
    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts
    
    let factory: Factory
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
                        factory.makeMessageAvatarView(
                            for: UserDisplayInfo(
                                id: vote.user?.id ?? "",
                                name: vote.user?.name ?? "",
                                imageURL: vote.user?.imageURL,
                                size: .init(width: 20, height: 20),
                                extraData: vote.user?.extraData ?? [:]
                            )
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
                    PollOptionAllVotesView(factory: factory, poll: poll, option: option)
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
