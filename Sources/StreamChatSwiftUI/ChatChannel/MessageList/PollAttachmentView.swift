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
    private let poll: Poll
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
        self.poll = poll
        self.isFirst = isFirst
        _viewModel = StateObject(
            wrappedValue: PollAttachmentViewModel(
                message: message,
                poll: poll
            )
        )
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
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
            
            ForEach(poll.options) { option in
                HStack {
                    Button {
                        if optionVotedByCurrentUser(option) {
                            
                        } else {
                            
                        }
                    } label: {
                        if optionVotedByCurrentUser(option) {
                            Image(systemName: "checkmark.circle.fill")
                        } else {
                            Image(systemName: "circle")
                        }
                    }
                    Text(option.text ?? "")
                    Spacer()
                    Text("\(poll.voteCountsByOption?[option.id] ?? 0)")
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
    
    private var subtitleText: String {
        if poll.isClosed == true {
            return "Vote ended"
        } else if poll.enforceUniqueVote == true {
            return "Select one"
        } else {
            return "Select one or more"
        }
    }
    
    private func optionVotedByCurrentUser(_ option: PollOption) -> Bool {
        //TODO: query all votes.
        for vote in poll.latestAnswers {
            if option.id == vote.id 
                && vote.user?.id == chatClient.currentUserId {
                return true
            }
        }
        return false
    }
}

extension PollOption: Identifiable {}
