//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// A vertical stack that renders all applicable annotation rows above the message bubble.
struct MessageTopView: View {
    @Injected(\.images) private var images
    @Injected(\.tokens) private var tokens
    @Injected(\.utils) private var utils

    let message: ChatMessage
    let channel: ChatChannel
    @ObservedObject var messageViewModel: MessageViewModel
    /// When true, the `textOnAccent` color is used instead of the default darker text color.
    var usesInvertedStyle: Bool = false

    var body: some View {
        VStack(alignment: messageViewModel.isRightAligned ? .trailing : .leading, spacing: tokens.spacingXxs) {
            if messageViewModel.isPinned {
                MessageAnnotationView(
                    icon: images.pin,
                    title: messageViewModel.pinnedByText,
                    usesInvertedStyle: usesInvertedStyle
                )
                .accessibilityIdentifier("MessagePinDetailsView")
            }

            if messageViewModel.sentInChannelShown {
                MessageAnnotationView(
                    icon: images.annotationThread,
                    title: L10n.Message.Annotation.sentInChannel,
                    buttonTitle: L10n.Message.Annotation.view,
                    buttonAction: { navigateToSentInChannel() },
                    usesInvertedStyle: usesInvertedStyle
                )
                .accessibilityIdentifier("SentInChannelAnnotation")
            }

            if messageViewModel.repliedToThreadShown {
                MessageAnnotationView(
                    icon: images.annotationThread,
                    title: L10n.Message.Annotation.repliedToThread,
                    buttonTitle: L10n.Message.Annotation.view,
                    buttonAction: { navigateToThread() },
                    usesInvertedStyle: usesInvertedStyle
                )
                .accessibilityIdentifier("RepliedToThreadAnnotation")
            }

            if messageViewModel.hasReminder {
                MessageAnnotationView(
                    icon: images.annotationReminder,
                    title: L10n.Message.Annotation.reminderSet,
                    subtitle: messageViewModel.reminderTimeText,
                    usesInvertedStyle: usesInvertedStyle
                )
                .accessibilityIdentifier("ReminderAnnotation")
            }

            if messageViewModel.translatedText != nil {
                translationAnnotation
            }
        }
        .padding(.vertical, tokens.spacingXxs)
    }

    // MARK: - Translation

    @ViewBuilder
    private var translationAnnotation: some View {
        if utils.messageListConfig.messageDisplayOptions.showOriginalTranslatedButton {
            MessageAnnotationView(
                icon: images.annotationTranslation,
                title: messageViewModel.originalTextShown ? nil : L10n.Message.Annotation.translated,
                buttonTitle: messageViewModel.originalTextShown ? L10n.Message.showTranslation : L10n.Message.showOriginal,
                buttonAction: {
                    if messageViewModel.originalTextShown {
                        messageViewModel.hideOriginalText()
                    } else {
                        messageViewModel.showOriginalText()
                    }
                },
                usesInvertedStyle: usesInvertedStyle
            )
        } else {
            MessageAnnotationView(
                icon: images.annotationTranslation,
                title: messageViewModel.translatedLanguageText ?? "",
                usesInvertedStyle: usesInvertedStyle
            )
        }
    }

    // MARK: - Navigation

    private func navigateToSentInChannel() {
        NotificationCenter.default.post(
            name: MessageRepliesConstants.channelMessageNavigationNotification,
            object: nil,
            userInfo: [MessageRepliesConstants.channelMessageMessageId: message.messageId]
        )
    }

    private func navigateToThread() {
        guard let parentMessageId = message.parentMessageId else { return }
        NotificationCenter.default.post(
            name: MessageRepliesConstants.threadMessageNavigationNotification,
            object: nil,
            userInfo: [
                MessageRepliesConstants.threadMessageParentId: parentMessageId,
                MessageRepliesConstants.threadMessageReplyId: message.messageId
            ]
        )
    }
}
