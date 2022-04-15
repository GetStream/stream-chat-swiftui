//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat
import SwiftUI

class FileAttachmentsViewModel: ObservableObject {
    
    private let channel: ChatChannel
    
    init(channel: ChatChannel) {
        self.channel = channel
    }
}
