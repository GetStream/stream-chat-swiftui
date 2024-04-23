//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat

class CreatePollViewModel: ObservableObject {
    
    @Published var question = ""
    
    @Published var options: [String] = []
    
    @Published var blankOption = ""
    
    var chatController: ChatChannelController? = {
        InjectedValues[\.utils.channelControllerFactory].currentChannelController
    }()
    
    func createPoll(completion: @escaping () -> ()) {
        guard let chatController else { return }
        chatController.createPoll(name: question) { result in
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
