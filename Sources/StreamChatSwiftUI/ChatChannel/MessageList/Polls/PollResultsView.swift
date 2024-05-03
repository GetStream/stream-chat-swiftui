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
            LazyVStack {
                ForEach(viewModel.poll.options) { option in
                    PollOptionResultsView(
                        poll: viewModel.poll,
                        option: option,
                        votes: Array(option.latestVotes.prefix(10)),
                        allButtonShown: option.latestVotes.count < (viewModel.poll.voteCountsByOption?[option.id] ?? 0),
                        dateFormatter: viewModel.dateString(from:)
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
    
    var poll: Poll
    var option: PollOption
    var votes: [PollVote]
    var allButtonShown = false
    var dateFormatter: (Date) -> String
    var onVoteAppear: ((PollVote) -> Void)?
    
    var body: some View {
        VStack {
            HStack {
                Text(option.text)
                Spacer()
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
                    Text(dateFormatter(vote.createdAt))
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
        .padding()
        .background(
            Color(colors.background6)
        )
        .cornerRadius(16)
        .padding()
    }
}

extension PollVote: Identifiable {
    var displayId: String {
        "\(id)-\(optionId)-\(pollId)"
    }
}
