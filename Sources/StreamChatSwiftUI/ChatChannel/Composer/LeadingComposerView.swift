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
                    .foregroundColor(Color(colors.buttonSecondaryText))
            }
            .frame(width: buttonSize, height: buttonSize)
            .foregroundColor(Color(colors.buttonSecondaryText))
            .modifier(factory.styles.makeComposerButtonViewModifier(options: .init()))
        }
    }

    private var buttonSize: CGFloat {
        DesignSystemTokens.buttonVisualHeightLg
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
                pointSize: DesignSystemTokens.iconSizeMd,
                weight: .light
            )
        )!
    }

    var composerSend: UIImage {
        UIImage(
            systemName: "paperplane",
            withConfiguration: UIImage.SymbolConfiguration(
                weight: .regular
            )
        )!
    }

    var composerMic: UIImage {
        UIImage(
            systemName: "mic",
            withConfiguration: UIImage.SymbolConfiguration(
                pointSize: DesignSystemTokens.iconSizeSm,
                weight: .regular
            )
        )!
    }
}
