//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

class PollAttachmentViewModel: ObservableObject {
    
    let message: ChatMessage
    let poll: Poll
    
    init(message: ChatMessage, poll: Poll) {
        self.message = message
        self.poll = poll
    }
}
