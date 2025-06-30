//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import Foundation

/// A configuration for channel lists.
public struct ChannelListConfig {
    public init(
        messageRelativeDateFormatEnabled: Bool = false,
        showChannelListDividerOnLastItem: Bool = true
    ) {
        self.messageRelativeDateFormatEnabled = messageRelativeDateFormatEnabled
        self.showChannelListDividerOnLastItem = showChannelListDividerOnLastItem
    }

    /// If true, the timestamp format depends on the time passed.
    ///
    /// Different date formats are used for today, yesterday, last 7 days, and older dates.
    public var messageRelativeDateFormatEnabled: Bool

    /// A boolean indicating whether the channel list should show a divider
    /// on the last item.
    ///
    /// By default, all items in the channel list have a divider, including the last item.
    public var showChannelListDividerOnLastItem: Bool
}
