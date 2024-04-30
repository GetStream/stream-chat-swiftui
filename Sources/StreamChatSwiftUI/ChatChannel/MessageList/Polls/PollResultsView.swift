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
        NavigationView {
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.poll.options) { option in
                        VStack {
                            HStack {
                                Text(option.text)
                                Spacer()
                                Text("\(viewModel.poll.voteCountsByOption?[option.id] ?? 0) votes")
                            }
                            
                            let loaded = viewModel.votesForOption[option.id]
                            let votes = loaded != nil ? loaded! : option.latestVotes
                            ForEach(votes, id: \.displayId) { vote in
                                HStack {
                                    MessageAvatarView(
                                        avatarURL: vote.user?.imageURL,
                                        size: .init(width: 20, height: 20)
                                    )
                                    Text(vote.user?.name ?? (vote.user?.id ?? ""))
                                    Spacer()
                                    Text(viewModel.dateString(from: vote.createdAt))
                                }
                            }
                            
                            if option.latestVotes.count < (viewModel.poll.voteCountsByOption?[option.id] ?? 0) {
                                Button {
                                    viewModel.loadMoreVotes(for: option)
                                } label: {
                                    Text("Show more")
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
                    Spacer()
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Poll results")
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }

                }
            }
        }
    }
}

extension PollVote: Identifiable {
    var displayId: String {
        "\(id)-\(optionId)-\(pollId)"
    }
}
