//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat
import SwiftUI

public class ChatChannelInfoViewModel: ObservableObject {
    
    @Injected(\.chatClient) private var chatClient
    
    @Published var users = [ChatUser]()
    @Published var muted: Bool {
        didSet {
            if muted {
                channelController.muteChannel()
            } else {
                channelController.unmuteChannel()
            }
        }
    }
    
    var mutedText: String {
        let isGroup = channel.memberCount > 2
        return isGroup ? L10n.ChatInfo.Mute.group : L10n.ChatInfo.Mute.user
    }
    
    let channel: ChatChannel
    var channelController: ChatChannelController!
    
    public init(channel: ChatChannel) {
        self.channel = channel
        muted = channel.isMuted
        channelController = chatClient.channelController(for: channel.cid)
    }
}
