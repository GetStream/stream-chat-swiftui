//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View providing support for deeplinking.
public struct ChannelDeepLink<ChannelDestination: View>: View {
    private var channelDestination: (ChatChannel) -> ChannelDestination
    @Binding var deeplinkChannel: ChatChannel?
    
    public init(
        deeplinkChannel: Binding<ChatChannel?>,
        channelDestination: @escaping (ChatChannel) -> ChannelDestination
    ) {
        self.channelDestination = channelDestination
        _deeplinkChannel = deeplinkChannel
    }
    
    public var body: some View {
        if let deeplinkChannel = deeplinkChannel {
            NavigationLink(tag: deeplinkChannel, selection: $deeplinkChannel) {
                channelDestination(deeplinkChannel)
            } label: {
                EmptyView()
            }
        }
    }
}
