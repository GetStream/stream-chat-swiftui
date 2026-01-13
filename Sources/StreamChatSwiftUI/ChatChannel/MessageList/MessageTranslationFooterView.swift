//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

public struct MessageTranslationFooterView: View {
    @ObservedObject var messageViewModel: MessageViewModel

    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.utils) private var utils

    public init(
        messageViewModel: MessageViewModel
    ) {
        self.messageViewModel = messageViewModel
    }

    public var body: some View {
        if utils.messageListConfig.messageDisplayOptions.showOriginalTranslatedButton {
            HStack(spacing: 4) {
                if !messageViewModel.originalTextShown {
                    translatedToView
                    separatorView
                }
                showOriginalButton
            }
        } else {
            translatedToView
        }
    }

    private var translatedToView: some View {
        Text(messageViewModel.translatedLanguageText ?? "")
            .font(fonts.footnote)
            .foregroundColor(Color(colors.subtitleText))
    }

    private var separatorView: some View {
        Text("•")
            .font(fonts.footnote)
            .foregroundColor(Color(colors.subtitleText))
    }

    private var showOriginalButton: some View {
        Button(
            action: {
                if messageViewModel.originalTextShown {
                    messageViewModel.hideOriginalText()
                } else {
                    messageViewModel.showOriginalText()
                }
            },
            label: {
                Text(messageViewModel.originalTranslationButtonText)
                    .font(fonts.footnote)
                    .foregroundColor(Color(colors.subtitleText))
            }
        )
    }
}
