//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

public struct MessageTranslationFooterView: View {
    @ObservedObject var channelViewModel: ChatChannelViewModel
    @ObservedObject var messageViewModel: MessageViewModel

    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.utils) private var utils

    public init(
        channelViewModel: ChatChannelViewModel,
        messageViewModel: MessageViewModel
    ) {
        self.channelViewModel = channelViewModel
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
                    channelViewModel.showTranslatedText(for: messageViewModel.message)
                } else {
                    channelViewModel.showOriginalText(for: messageViewModel.message)
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
