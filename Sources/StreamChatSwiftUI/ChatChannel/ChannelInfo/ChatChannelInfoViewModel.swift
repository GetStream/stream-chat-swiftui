//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat
import SwiftUI

public class ChatChannelInfoViewModel: ObservableObject {
    
    @Published var users = [ChatUser]()
    
    let channel: ChatChannel
    
    public init(channel: ChatChannel) {
        self.channel = channel
    }
}
