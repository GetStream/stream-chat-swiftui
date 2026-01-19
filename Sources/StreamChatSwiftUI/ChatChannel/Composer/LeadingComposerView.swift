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
                    Image(uiImage: images.composerAdd)
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
                    Image(uiImage: images.composerAdd)
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

// TODO: Move to Common Module

import StreamChatCommonUI
import UIKit

extension Appearance.Images {
    var composerAdd: UIImage {
        UIImage(
            systemName: "plus",
            withConfiguration: UIImage.SymbolConfiguration(
                weight: .light
            )
        )!
    }
}
