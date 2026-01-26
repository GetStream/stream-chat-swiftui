//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChatCommonUI
import SwiftUI

/// The button for sending messages.
public struct ComposerAttachmentPickerButton<Factory: ViewFactory>: View {
    @Injected(\.images) private var images
    @Injected(\.colors) private var colors

    var factory: Factory

    @Binding var pickerTypeState: PickerTypeState

    public init(
        factory: Factory,
        pickerTypeState: Binding<PickerTypeState>
    ) {
        self.factory = factory
        self._pickerTypeState = pickerTypeState
    }

    public var body: some View {
        Button {
            withAnimation {
                if pickerTypeState == .collapsed || pickerTypeState == .expanded(.none) {
                    pickerTypeState = .expanded(.media)
                } else {
                    pickerTypeState = .expanded(.none)
                }
            }
        } label: {
            Image(uiImage: image)
                .renderingMode(.template)
                .foregroundColor(Color(colors.buttonSecondaryText))
        }
        .padding(DesignSystemTokens.buttonPaddingYLg)
        .foregroundColor(Color(colors.buttonSecondaryText))
        .modifier(factory.styles.makeComposerButtonViewModifier(options: .init()))
    }

    var image: UIImage {
        switch pickerTypeState {
        case .collapsed, .expanded(.none):
            return images.composerAdd
        case .expanded:
            return images.composerClose
        }
    }
}
