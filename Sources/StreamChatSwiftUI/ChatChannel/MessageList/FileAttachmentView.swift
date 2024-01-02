//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

public struct FileAttachmentsContainer<Factory: ViewFactory>: View {

    @Injected(\.utils) private var utils

    var factory: Factory
    var message: ChatMessage
    var width: CGFloat
    var isFirst: Bool
    @Binding var scrolledId: String?

    public init(
        factory: Factory,
        message: ChatMessage,
        width: CGFloat,
        isFirst: Bool,
        scrolledId: Binding<String?>
    ) {
        self.factory = factory
        self.message = message
        self.width = width
        self.isFirst = isFirst
        _scrolledId = scrolledId
    }

    public var body: some View {
        VStack(alignment: message.alignmentInBubble) {
            if let quotedMessage = utils.messageCachingUtils.quotedMessage(for: message) {
                factory.makeQuotedMessageView(
                    quotedMessage: quotedMessage,
                    fillAvailableSpace: !message.attachmentCounts.isEmpty,
                    isInComposer: false,
                    scrolledId: $scrolledId
                )
            }

            VStack(spacing: 0) {
                VStack(spacing: 4) {
                    ForEach(message.fileAttachments, id: \.self) { attachment in
                        FileAttachmentView(
                            attachment: attachment,
                            width: width,
                            isFirst: isFirst
                        )
                    }
                }
                if !message.text.isEmpty {
                    HStack {
                        Text(message.adjustedText)
                            .foregroundColor(textColor(for: message))
                            .standardPadding()
                        Spacer()
                    }
                }
            }
            .padding(.all, 4)
        }
        .modifier(
            factory.makeMessageViewModifier(
                for: MessageModifierInfo(
                    message: message,
                    isFirst: isFirst
                )
            )
        )
        .accessibilityIdentifier("FileAttachmentsContainer")
    }
}

public struct FileAttachmentView: View {
    @Injected(\.images) private var images
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors

    @State private var fullScreenShown = false

    var attachment: ChatMessageFileAttachment
    var width: CGFloat
    var isFirst: Bool

    public init(attachment: ChatMessageFileAttachment, width: CGFloat, isFirst: Bool) {
        self.attachment = attachment
        self.width = width
        self.isFirst = isFirst
    }

    public var body: some View {
        HStack {
            FileAttachmentDisplayView(
                url: attachment.assetURL,
                title: attachment.title ?? "",
                sizeString: attachment.file.sizeString
            )
            .onTapGesture {
                fullScreenShown = true
            }

            Spacer()
        }
        .padding(.all, 8)
        .background(Color(colors.background))
        .frame(width: width)
        .roundWithBorder()
        .withUploadingStateIndicator(for: attachment.uploadingState, url: attachment.assetURL)
        .sheet(isPresented: $fullScreenShown) {
            FileAttachmentPreview(url: attachment.assetURL)
        }
        .accessibilityIdentifier("FileAttachmentView")
    }
}

public struct FileAttachmentDisplayView: View {

    @Injected(\.images) private var images
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors

    var url: URL
    var title: String
    var sizeString: String

    public init(url: URL, title: String, sizeString: String) {
        self.url = url
        self.title = title
        self.sizeString = sizeString
    }

    public var body: some View {
        HStack {
            Image(uiImage: previewImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 34, height: 40)
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(fonts.bodyBold)
                    .lineLimit(1)
                    .foregroundColor(Color(colors.text))
                Text(sizeString)
                    .font(fonts.footnote)
                    .lineLimit(1)
                    .foregroundColor(Color(colors.textLowEmphasis))
            }
            Spacer()
        }
    }

    private var previewImage: UIImage {
        let iconName = url.pathExtension
        return images.documentPreviews[iconName] ?? images.fileFallback
    }
}
