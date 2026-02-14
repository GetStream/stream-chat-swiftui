//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

public protocol MessageIdBuilder {
    /// Creates a message id for the provided message.
    func makeMessageId(for message: ChatMessage) -> String
}

public class DefaultMessageIdBuilder: MessageIdBuilder {
    public init() { /* Public init. */ }

    public func makeMessageId(for message: ChatMessage) -> String {
        message.id
    }
}
