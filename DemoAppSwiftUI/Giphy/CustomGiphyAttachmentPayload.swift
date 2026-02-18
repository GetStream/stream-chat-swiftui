//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat
import StreamChatSwiftUI
import SwiftUI
import WebKit

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
        AnimatedGifMessageView(gifURL: payload.previewURL)
            .frame(width: width, height: width * Self.aspectRatio)
            .clipped()
    }
}

/// Displays an animated GIF in the message list (reuses same approach as grid).
private struct AnimatedGifMessageView: UIViewRepresentable {
    let gifURL: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.isUserInteractionEnabled = false
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.backgroundColor = .clear
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let html = """
        <html><head><meta name="viewport" content="width=device-width,initial-scale=1"/></head>
        <body style="margin:0;background:transparent;width:100%;height:100%;">
        <img src="\(gifURL.absoluteString)" style="width:100%;height:100%;object-fit:cover;display:block;" />
        </body></html>
        """
        webView.loadHTMLString(html, baseURL: gifURL)
    }
}
