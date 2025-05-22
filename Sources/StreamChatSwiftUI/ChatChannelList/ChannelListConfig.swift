//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import Foundation

/// A configuration for channel lists.
public struct ChannelListConfig {
    public init(messageRelativeDateFormatEnabled: Bool = false) {
        self.messageRelativeDateFormatEnabled = messageRelativeDateFormatEnabled
    }

    /// If true, the timestamp format depends on the time passed.
    ///
    /// Different date formats are used for today, yesterday, last 7 days, and older dates.
    public var messageRelativeDateFormatEnabled: Bool
}
