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
            triggerHapticFeedback(style: .soft)
            withAnimation(.easeInOut(duration: 0.25)) {
                if pickerTypeState == .collapsed || pickerTypeState == .expanded(.none) {
                    pickerTypeState = .expanded(.media)
                } else {
                    pickerTypeState = .expanded(.none)
                }
            }
        } label: {
            Image(uiImage: images.composerAdd)
                .renderingMode(.template)
                .foregroundColor(Color(colors.buttonSecondaryText))
                .rotationEffect(.degrees(isExpanded ? 45 : 0))
        }
        .padding(DesignSystemTokens.buttonPaddingYLg)
        .foregroundColor(Color(colors.buttonSecondaryText))
        .modifier(factory.styles.makeComposerButtonViewModifier(options: .init()))
    }

    private var isExpanded: Bool {
        switch pickerTypeState {
        case .collapsed, .expanded(.none):
            return false
        case .expanded:
            return true
        }
    }
}
