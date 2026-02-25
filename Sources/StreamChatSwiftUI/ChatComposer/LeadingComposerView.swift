//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct LeadingComposerView<Factory: ViewFactory>: View {
    @Injected(\.colors) var colors
    @Injected(\.images) var images

    var factory: Factory
    
    @Binding var pickerTypeState: PickerTypeState
    public let channelConfig: ChannelConfig?
    var isCommandActive: Bool
    
    var body: some View {
        if !isCommandActive {
            ComposerAttachmentPickerButton(
                factory: factory,
                pickerTypeState: $pickerTypeState
            )
        }
    }
}
