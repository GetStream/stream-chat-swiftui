//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChatCommonUI
import SwiftUI

/// The button for opening and closing the attachment picker in the message composer.
public struct ComposerAttachmentPickerButton<Factory: ViewFactory>: View, KeyboardReadable {
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
            withAnimation(.easeInOut(duration: 0.25)) {
                if pickerTypeState == .expanded(.none) {
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
        .onChange(of: pickerTypeState) { newValue in
            triggerHapticFeedback(style: .soft)
        }
        .onReceive(keyboardWillChangePublisher) { shown in
            if shown {
                triggerHapticFeedback(style: .soft)
            }
        }
    }

    private var isExpanded: Bool {
        switch pickerTypeState {
        case .expanded(.none):
            return false
        case .expanded:
            return true
        }
    }
}
