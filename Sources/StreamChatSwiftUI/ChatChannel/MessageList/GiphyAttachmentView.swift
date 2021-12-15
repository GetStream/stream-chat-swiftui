//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import Nuke
import NukeUI
import StreamChat
import SwiftUI

/// View for the giphy attachments.
public struct GiphyAttachmentView: View {
    let message: ChatMessage
    let width: CGFloat
    let isFirst: Bool
    @Binding var scrolledId: String?
                
    public var body: some View {
        VStack(
            alignment: message.alignmentInBubble,
            spacing: 0
        ) {
            if let quotedMessage = message.quotedMessage {
                QuotedMessageViewContainer(
                    quotedMessage: quotedMessage,
                    fillAvailableSpace: !message.attachmentCounts.isEmpty,
                    scrolledId: $scrolledId
                )
            }
            
            LazyGiphyView(
                source: message.giphyAttachments[0].previewURL,
                width: width
            )

            if !message.text.isEmpty {
                HStack {
                    Text(message.text)
                        .standardPadding()
                    Spacer()
                }
            }
        }
        .messageBubble(for: message, isFirst: isFirst)
        .frame(maxWidth: width)
    }
}

struct LazyGiphyView: View {
    let source: URL
    let width: CGFloat
    
    var body: some View {
        LazyImage(source: source) { state in
            if let imageContainer = state.imageContainer {
                Image(imageContainer)
            } else if state.error != nil {
                Color(.secondarySystemBackground)
            } else {
                ZStack {
                    Color(.secondarySystemBackground)
                    ProgressView()
                }
            }
        }
        .onDisappear(.reset)
        .processors([ImageProcessors.Resize(width: width)])
        .priority(.high)
        .aspectRatio(contentMode: .fit)
    }
}
