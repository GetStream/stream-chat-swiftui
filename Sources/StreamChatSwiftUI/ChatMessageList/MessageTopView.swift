//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// A vertical stack that renders all applicable annotation rows above the message bubble.
struct MessageTopView<Factory: ViewFactory>: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images
    @Injected(\.tokens) private var tokens
    @Injected(\.utils) private var utils

    let factory: Factory
    let message: ChatMessage
    let channel: ChatChannel
    @ObservedObject var messageViewModel: MessageViewModel
    /// When true, the `textOnAccent` color is used instead of the default darker text color.
    var usesInvertedStyle: Bool = false

    private var resolvedTextColor: Color {
        usesInvertedStyle ? colors.textOnAccent.toColor : colors.textPrimary.toColor
    }

    var body: some View {
        VStack(alignment: messageViewModel.isRightAligned ? .trailing : .leading, spacing: 0) {
            if messageViewModel.isPinned {
                MessagePinDetailsView(message: message, usesInvertedStyle: usesInvertedStyle)
            }

            if messageViewModel.sentInChannelShown {
                sentInChannelAnnotation
            }

            if messageViewModel.repliedToThreadShown {
                repliedToThreadAnnotation
            }

            if messageViewModel.hasReminder {
                reminderAnnotation
            }

            if messageViewModel.translatedText != nil {
                factory.makeMessageTranslationView(
                    options: MessageTranslationViewOptions(
                        messageViewModel: messageViewModel,
                        usesInvertedStyle: usesInvertedStyle
                    )
                )
            }
        }
    }

    // MARK: - Annotations

    private var sentInChannelAnnotation: some View {
        Button {
            navigateToSentInChannel()
        } label: {
            HStack(spacing: tokens.spacingXxs) {
                Image(uiImage: images.annotationThread)
                    .customizable()
                    .padding(2)
                    .frame(width: 16, height: 16)
                Text(L10n.Message.Annotation.sentInChannel)
                    .font(fonts.metadataEmphasis)
                    .lineLimit(1)
                Text("•")
                    .font(fonts.metadataDefault)
                Text(L10n.Message.Annotation.view)
                    .font(fonts.metadataDefault)
                    .foregroundColor(Color(colors.accentPrimary))
            }
            .foregroundColor(resolvedTextColor)
            .frame(height: 24)
        }
        .accessibilityIdentifier("SentInChannelAnnotation")
    }

    private var repliedToThreadAnnotation: some View {
        Button {
            navigateToThread()
        } label: {
            HStack(spacing: tokens.spacingXxs) {
                Image(uiImage: images.annotationThread)
                    .customizable()
                    .padding(2)
                    .frame(width: 16, height: 16)
                Text(L10n.Message.Annotation.repliedToThread)
                    .font(fonts.metadataEmphasis)
                    .lineLimit(1)
                Text("•")
                    .font(fonts.metadataDefault)
                Text(L10n.Message.Annotation.view)
                    .font(fonts.metadataDefault)
                    .foregroundColor(Color(colors.accentPrimary))
            }
            .foregroundColor(resolvedTextColor)
            .frame(height: 24)
        }
        .accessibilityIdentifier("RepliedToThreadAnnotation")
    }

    private var reminderAnnotation: some View {
        HStack(spacing: tokens.spacingXxs) {
            Image(uiImage: images.annotationReminder)
                .customizable()
                .frame(width: 16, height: 16)
            Text(L10n.Message.Annotation.reminderSet)
                .font(fonts.metadataEmphasis)
                .lineLimit(1)
            if let timeText = messageViewModel.reminderTimeText {
                Text("•")
                    .font(fonts.metadataDefault)
                Text(timeText)
                    .font(fonts.metadataDefault)
            }
        }
        .foregroundColor(resolvedTextColor)
        .frame(height: 24)
        .accessibilityIdentifier("ReminderAnnotation")
    }

    // MARK: - Navigation

    private func navigateToSentInChannel() {
        // NOTE: Needed because of a bug in iOS 16.
        resignFirstResponder()
        NotificationCenter.default.post(
            name: NSNotification.Name(MessageRepliesConstants.selectedMessage),
            object: nil,
            userInfo: [MessageRepliesConstants.selectedMessage: message]
        )
    }
    
    private func navigateToThread() {
        // NOTE: Needed because of a bug in iOS 16.
        resignFirstResponder()
        Task {
            guard let parentMessage = await messageViewModel.parentMessage() else { return }
            NotificationCenter.default.post(
                name: NSNotification.Name(MessageRepliesConstants.selectedMessageThread),
                object: nil,
                userInfo: [
                    MessageRepliesConstants.selectedMessage: parentMessage,
                    MessageRepliesConstants.threadReplyMessage: message
                ]
            )
        }
    }
}
