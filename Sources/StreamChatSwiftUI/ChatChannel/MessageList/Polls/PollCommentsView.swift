//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct PollCommentsView: View {
    
    @Injected(\.colors) var colors
    
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject var viewModel: PollCommentsViewModel
    
    init(poll: Poll, pollController: PollController, viewModel: PollCommentsViewModel? = nil) {
        _viewModel = StateObject(
            wrappedValue: viewModel ?? PollCommentsViewModel(
                poll: poll,
                pollController: pollController
            )
        )
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(viewModel.comments) { comment in
                        if let answer = comment.answerText {
                            VStack(alignment: .leading) {
                                Text(answer)
                                    .bold()
                                HStack {
                                    if viewModel.pollController.poll?.votingVisibility != .anonymous {
                                        MessageAvatarView(avatarURL: comment.user?.imageURL)
                                    }
                                    Text(authorTitle(for: comment))
                                    Spacer()
                                    PollDateIndicatorView(date: comment.createdAt)
                                }
                            }
                            .withPollsBackground()
                            .onAppear { viewModel.onAppear(comment: comment) }
                        }
                    }
                    if viewModel.showsAddCommentButton {
                        Button(action: {
                            viewModel.addCommentShown = true
                        }, label: {
                            Text(commentButtonTitle)
                                .bold()
                                .foregroundColor(colors.tintColor)
                        })
                            .frame(maxWidth: .infinity)
                            .withPollsBackground()
                            .uiAlert(
                                title: commentButtonTitle,
                                isPresented: $viewModel.addCommentShown,
                                text: $viewModel.newCommentText,
                                accept: L10n.Alert.Actions.send,
                                action: { viewModel.add(comment: viewModel.newCommentText) }
                            )
                    }
                }
                .padding()
            }
            .alertBanner(
                isPresented: $viewModel.errorShown,
                action: viewModel.refresh
            )
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(L10n.Message.Polls.Toolbar.commentsTitle)
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
    
    private var commentButtonTitle: String {
        viewModel.currentUserAddedComment
            ? L10n.Message.Polls.Button.updateComment
            : L10n.Message.Polls.Button.addComment
    }
    
    private func authorTitle(for comment: PollVote) -> String {
        if viewModel.pollController.poll?.votingVisibility == .anonymous {
            return L10n.Message.Polls.unknownVoteAuthor
        }
        return comment.user?.name ?? L10n.Message.Polls.unknownVoteAuthor
    }
}
