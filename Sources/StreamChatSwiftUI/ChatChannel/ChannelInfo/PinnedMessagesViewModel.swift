//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat
import SwiftUI

public class PinnedMessagesViewModel: ObservableObject {
    
    private let channel: ChatChannel
    
    @Published var pinnedMessages: [ChatMessage]
    
    public init(channel: ChatChannel) {
        self.channel = channel
        pinnedMessages = channel.pinnedMessages
    }
}
