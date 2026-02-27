//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// An annotation view displaying translation information above the message bubble.
public struct MessageTranslationView: View {
    @ObservedObject var messageViewModel: MessageViewModel

    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images
    @Injected(\.tokens) private var tokens
    @Injected(\.utils) private var utils

    /// When true, the `textOnAccent` color is used instead of the default darker text color.
    var usesInvertedStyle: Bool

    public init(messageViewModel: MessageViewModel, usesInvertedStyle: Bool = false) {
        self.messageViewModel = messageViewModel
        self.usesInvertedStyle = usesInvertedStyle
    }

    private var resolvedTextColor: Color {
        usesInvertedStyle ? colors.textOnAccent.toColor : colors.textPrimary.toColor
    }

    public var body: some View {
        if utils.messageListConfig.messageDisplayOptions.showOriginalTranslatedButton {
            HStack(spacing: tokens.spacingXxs) {
                Image(uiImage: images.annotationTranslation)
                    .customizable()
                    .frame(width: 16, height: 16)
                if !messageViewModel.originalTextShown {
                    Text(L10n.Message.Annotation.translated)
                        .font(fonts.footnote.weight(.semibold))
                        .lineLimit(1)
                    Text("•")
                        .font(fonts.footnote)
                }
                showOriginalButton
            }
            .foregroundColor(resolvedTextColor)
            .frame(height: 24)
        } else {
            HStack(spacing: tokens.spacingXxs) {
                Image(uiImage: images.annotationTranslation)
                    .customizable()
                    .frame(width: 16, height: 16)
                Text(messageViewModel.translatedLanguageText ?? "")
                    .font(fonts.footnote.weight(.semibold))
                    .lineLimit(1)
            }
            .foregroundColor(resolvedTextColor)
            .frame(height: 24)
        }
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
                Text(messageViewModel.originalTextShown ? L10n.Message.showTranslation : L10n.Message.showOriginal)
                    .font(fonts.footnote)
                    .foregroundColor(Color(colors.accentPrimary))
            }
        )
    }
}
