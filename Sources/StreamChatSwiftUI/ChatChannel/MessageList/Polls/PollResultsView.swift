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
                        votes: Array(option.latestVotes.sorted(by: { $0.createdAt > $1.createdAt })
                            .prefix(numberOfItemsShown)),
                        allButtonShown: option.latestVotes.count > numberOfItemsShown
                    )
                }
                Spacer()
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Poll results")
                    .bold()
            }
            
            ToolbarItem(placement: .topBarLeading) {
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
    var allButtonShown = false
    var onVoteAppear: ((PollVote) -> Void)?
    
    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Text(option.text)
                    .font(fonts.bodyBold)
                Spacer()
                Image(systemName: "trophy")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 16)
                Text("\(poll.voteCountsByOption?[option.id] ?? 0) votes")
            }
            
            ForEach(votes, id: \.displayId) { vote in
                HStack {
                    MessageAvatarView(
                        avatarURL: vote.user?.imageURL,
                        size: .init(width: 20, height: 20)
                    )
                    Text(vote.user?.name ?? (vote.user?.id ?? "Anonymous"))
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
                    Text("Show all")
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
