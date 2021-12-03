//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// View modifier for customizing the channel list header.
public protocol ChannelListHeaderViewModifier: ViewModifier {
    var title: String { get }
}

/// The default channel list header.
public struct DefaultChatChannelListHeader: ToolbarContent {
    @Injected(\.fonts) private var fonts
    @Injected(\.images) private var images
    
    public var title: String
    
    public var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(title)
                .font(fonts.bodyBold)
        }
    }
}

/// The default channel list header modifier.
public struct DefaultChannelListHeaderModifier: ChannelListHeaderViewModifier {
    public var title: String
    
    public func body(content: Content) -> some View {
        content.toolbar {
            DefaultChatChannelListHeader(title: title)
        }
    }
}
