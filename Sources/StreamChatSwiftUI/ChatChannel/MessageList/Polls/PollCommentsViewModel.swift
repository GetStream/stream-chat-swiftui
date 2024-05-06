//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

class PollCommentsViewModel: ObservableObject {
    
    let pollController: PollController
    
    @Published var comments = [PollVote]()
    
    init(pollController: PollController) {
        self.pollController = pollController
        comments = pollController.poll?.latestAnswers ?? []
    }
}
