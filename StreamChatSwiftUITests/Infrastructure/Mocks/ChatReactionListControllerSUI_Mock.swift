//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
@testable import StreamChat
@testable import StreamChatTestTools

class ChatReactionListControllerSUI_Mock: ChatReactionListController, @unchecked Sendable {
    var synchronize_called = false

    var reactions_simulated: [ChatMessageReaction] = []
    override var reactions: [ChatMessageReaction] {
        reactions_simulated
    }

    var state_simulated: DataController.State?
    override var state: DataController.State {
        get { state_simulated ?? super.state }
        set { super.state = newValue }
    }

    override func synchronize(_ completion: (@MainActor (Error?) -> Void)? = nil) {
        synchronize_called = true
    }
}
