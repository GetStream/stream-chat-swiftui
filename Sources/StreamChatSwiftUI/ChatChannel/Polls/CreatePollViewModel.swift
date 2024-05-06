//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat

class CreatePollViewModel: ObservableObject {
    
    @Published var question = ""
    
    @Published var options: [String] = []
    
    @Published var blankOption = ""
    
    @Published var suggestAnOption = true
    
    @Published var anonymousPoll = false
    
    @Published var multipleAnswers = false
    
    @Published var maxVotesEnabled = false
    
    @Published var maxVotes: String = ""
    
    @Published var allowComments: Bool = false
    
    var chatController: ChatChannelController? = {
        InjectedValues[\.utils.channelControllerFactory].currentChannelController
    }()
    
    func createPoll(completion: @escaping () -> ()) {
        guard let chatController else { return }
        let pollOptions = options.map { PollOption(text: $0) }
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
            case .success(let messageId):
                log.debug("Created poll in message with id \(messageId)")
                completion()
            case .failure(let error):
                //TODO: show alert
                log.error("Error creating a poll: \(error.localizedDescription)")
            }
        }
    }
}
