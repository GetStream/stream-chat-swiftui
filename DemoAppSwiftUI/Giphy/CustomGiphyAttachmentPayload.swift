//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat
import StreamChatSwiftUI
import SwiftUI

/// Custom attachment type for GIFs picked from the demo's Giphy grid (keeps built-in .giphy untouched).
extension AttachmentType {
    static let customGiphy = Self(rawValue: "custom_giphy")
}

struct CustomGiphyAttachmentPayload: AttachmentPayload {
    static let type: AttachmentType = .customGiphy

    let title: String
    let previewURL: URL
}

/// Resolver so messages with custom_giphy attachments use the custom attachment view.
struct DemoAppMessageTypeResolver: MessageTypeResolving {
    func hasCustomAttachment(message: ChatMessage) -> Bool {
        !message.attachments(payloadType: CustomGiphyAttachmentPayload.self).isEmpty
    }
}

/// Renders a message that contains custom_giphy attachments (animated GIF in bubble).
struct CustomGiphyMessageView: View {
    let message: ChatMessage
    let isFirst: Bool
    let availableWidth: CGFloat
    @Binding var scrolledId: String?

    var body: some View {
        let attachments = message.attachments(payloadType: CustomGiphyAttachmentPayload.self)
        VStack(alignment: message.isSentByCurrentUser ? .trailing : .leading, spacing: 0) {
            ForEach(Array(attachments.enumerated()), id: \.offset) { _, attachment in
                CustomGiphyAttachmentMessageCell(payload: attachment.payload, width: availableWidth)
            }
        }
        .messageBubble(for: message, isFirst: isFirst)
    }
}

private struct CustomGiphyAttachmentMessageCell: View {
    let payload: CustomGiphyAttachmentPayload
    let width: CGFloat

    /// Use a fixed aspect ratio so the cell has a defined size; avoids grey gap from WKWebView's unreliable intrinsic size.
    private static let aspectRatio: CGFloat = 1

    var body: some View {
        AnimatedGifView(gifURL: payload.previewURL)
            .frame(width: width, height: width * Self.aspectRatio)
            .clipped()
    }
}
