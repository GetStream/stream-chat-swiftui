//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct LeadingComposerView<Factory: ViewFactory>: View {
    @Injected(\.colors) var colors
    
    var factory: Factory
    
    @Binding var pickerTypeState: PickerTypeState
    public let channelConfig: ChannelConfig?
    
    var body: some View {
        HStack {
            if #available(iOS 26.0, *) {
                Button {
                    withAnimation {
                        if pickerTypeState == .collapsed || pickerTypeState == .expanded(.none) {
                            pickerTypeState = .expanded(.media)
                        } else {
                            pickerTypeState = .expanded(.none)
                        }
                    }
                } label: {
                    Image(systemName: "plus")
                        .fontWeight(.semibold)
                }
                .padding(.all, 12)
                .modifier(factory.styles.makeComposerButtonViewModifier(options: .init()))
                .foregroundStyle(.primary)
                .contentShape(.rect)
            } else {
                Button {
                    withAnimation {
                        if pickerTypeState == .collapsed || pickerTypeState == .expanded(.none) {
                            pickerTypeState = .expanded(.media)
                        } else {
                            pickerTypeState = .expanded(.none)
                        }
                    }
                } label: {
                    Image(systemName: "plus")
                }
                .padding(.all, 12)
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(.circle)
                .contentShape(.rect)
            }
        }
        .padding(.leading, 8)
    }
}
