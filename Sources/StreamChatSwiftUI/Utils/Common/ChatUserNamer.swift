//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat

public protocol ChatUserNamer {
    /// Creates the user name string representation from a ChatUser object.
    /// - Parameter user: The chat user from which the name will be generated from.
    /// - Returns: A string value that represents the name of the user.
    func name(forUser user: ChatUser) -> String?
}

/// Default implementation of the `ChatUserNamer` protocol.
public class DefaultChatUserNamer: ChatUserNamer {
    public init() {
        // Public init.
    }

    public func name(forUser user: ChatUser) -> String? {
        user.name
    }
}
