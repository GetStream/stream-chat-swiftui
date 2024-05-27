//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Combine
import Foundation
import StreamChat
import SwiftUI

class CreatePollViewModel: ObservableObject {
    
    @Published var question = ""
    
    @Published var options: [String] = [""]
        
    @Published var suggestAnOption = true
    
    @Published var anonymousPoll = false
    
    @Published var multipleAnswers = false
    
    @Published var maxVotesEnabled = false
    
    @Published var maxVotes: String = ""
    @Published var showsMaxVotesError = false
    
    @Published var allowComments: Bool = false
    
    private var cancellables = [AnyCancellable]()
    
    init() {
        $maxVotes
            .map { text in
                guard !text.isEmpty else { return false }
                let intValue = Int(text) ?? 0
                return intValue < 1 || intValue > 10
            }
            .combineLatest($maxVotesEnabled)
            .map { $0 && $1 }
            .removeDuplicates()
            .assignWeakly(to: \.showsMaxVotesError, on: self)
            .store(in: &cancellables)
    }
    
    var chatController: ChatChannelController? = {
        InjectedValues[\.utils.channelControllerFactory].currentChannelController
    }()
    
    func createPoll(completion: @escaping () -> Void) {
        guard let chatController else { return }
        let pollOptions = options
            .filter { !$0.isEmpty }
            .map { PollOption(text: $0) }
        chatController.createPoll(
            name: question,
            allowAnswers: allowComments,
            allowUserSuggestedOptions: suggestAnOption,
            enforceUniqueVote: !multipleAnswers,
            maxVotesAllowed: Int(maxVotes),
            votingVisibility: anonymousPoll ? .anonymous : .public,
            options: pollOptions
        ) { result in
            switch result {
            case let .success(messageId):
                log.debug("Created poll in message with id \(messageId)")
                completion()
            case let .failure(error):
                // TODO: show alert
                log.error("Error creating a poll: \(error.localizedDescription)")
            }
        }
    }
}
