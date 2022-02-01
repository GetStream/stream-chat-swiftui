//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View providing support for deeplinking.
public struct ChannelDeepLink<ChannelDestination: View>: View {
    private var channelDestination: (ChannelSelectionInfo) -> ChannelDestination
    @Binding var deeplinkChannel: ChannelSelectionInfo?
    
    public init(
        deeplinkChannel: Binding<ChannelSelectionInfo?>,
        channelDestination: @escaping (ChannelSelectionInfo) -> ChannelDestination
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
