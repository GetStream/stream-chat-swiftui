//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct PollCommentsView: View {
    
    @Injected(\.colors) var colors
    
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject var viewModel: PollCommentsViewModel
    
    init(poll: Poll, pollController: PollController) {
        _viewModel = StateObject(
            wrappedValue: PollCommentsViewModel(
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
                                    MessageAvatarView(avatarURL: comment.user?.imageURL)
                                    Text(comment.user?.name ?? "")
                                    Spacer()
                                    PollDateIndicatorView(date: comment.createdAt)
                                }
                            }
                            .withPollsBackground()
                        }
                    }
                    
                    Button(action: {
                        viewModel.addCommentShown = true
                    }, label: {
                        Text(L10n.Message.Polls.Button.addComment)
                            .bold()
                            .foregroundColor(colors.tintColor)
                    })
                        .frame(maxWidth: .infinity)
                        .withPollsBackground()
                        .uiAlert(
                            title: L10n.Alert.Title.addComment,
                            isPresented: $viewModel.addCommentShown,
                            text: $viewModel.newCommentText,
                            accept: L10n.Alert.Actions.send,
                            action: { viewModel.add(comment: viewModel.newCommentText) }
                        )
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(L10n.Message.Polls.Toolbar.commentsTitle)
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
}
