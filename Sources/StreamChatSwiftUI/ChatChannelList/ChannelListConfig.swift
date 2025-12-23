//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import Foundation
import SwiftUI

/// A configuration for channel lists.
public struct ChannelListConfig {
    public init(
        channelItemMutedStyle: ChannelItemMutedLayoutStyle = .default,
        messageRelativeDateFormatEnabled: Bool = false,
        navigationBarDisplayMode: NavigationBarItem.TitleDisplayMode = .inline,
        showChannelListDividerOnLastItem: Bool = true,
        supportedMoreChannelActions: @escaping @MainActor (SupportedMoreChannelActionsOptions) -> [ChannelAction] = ChannelAction.defaultActions(for:)
    ) {
        self.channelItemMutedStyle = channelItemMutedStyle
        self.messageRelativeDateFormatEnabled = messageRelativeDateFormatEnabled
        self.navigationBarDisplayMode = navigationBarDisplayMode
        self.showChannelListDividerOnLastItem = showChannelListDividerOnLastItem
        self.supportedMoreChannelActions = supportedMoreChannelActions
    }

    /// If true, the timestamp format depends on the time passed.
    ///
    /// Different date formats are used for today, yesterday, last 7 days, and older dates.
    public var messageRelativeDateFormatEnabled: Bool
    
    /// A style for displaying the title of a navigation bar.
    public var navigationBarDisplayMode: NavigationBarItem.TitleDisplayMode

    /// A boolean indicating whether the channel list should show a divider
    /// on the last item.
    ///
    /// By default, all items in the channel list have a divider, including the last item.
    public var showChannelListDividerOnLastItem: Bool

    /// The style for the channel item when it is muted.
    public var channelItemMutedStyle: ChannelItemMutedLayoutStyle = .default
    
    /// Returns the supported channel actions.
    /// - Parameter options: the options for getting supported channel actions.
    /// - Returns: list of `ChannelAction` items.
    public var supportedMoreChannelActions: @MainActor (SupportedMoreChannelActionsOptions) -> [ChannelAction]
}
