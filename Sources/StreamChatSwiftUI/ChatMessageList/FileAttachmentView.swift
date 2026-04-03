//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

public struct FileAttachmentsContainer<Factory: ViewFactory>: View {
    @Injected(\.colors) var colors
    @Injected(\.tokens) var tokens
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
        VStack(spacing: tokens.spacingXxs) {
            ForEach(message.fileAttachments) { attachment in
                FileAttachmentView(
                    attachment: attachment,
                    width: width,
                    isFirst: isFirst
                )
                .background(MessageAttachmentsBubbleConfiguration.attachmentBackgroundColor(for: message))
                .roundWithBorder(cornerRadius: tokens.messageBubbleRadiusAttachment)
            }
        }
        .accessibilityIdentifier("FileAttachmentsContainer")
    }
}

public struct FileAttachmentView: View {
    @Injected(\.utils) private var utils
    @Injected(\.images) private var images
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.tokens) private var tokens
    @Injected(\.chatClient) private var chatClient

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
            .accessibilityAction {
                fullScreenShown = true
            }

            Spacer()
        }
        .padding(.all, tokens.spacingSm)
        .frame(width: width)
        .withUploadingStateIndicator(for: attachment.uploadingState, url: attachment.assetURL)
        .withDownloadingStateIndicator(for: attachment.downloadingState, url: attachment.assetURL)
        .sheet(isPresented: $fullScreenShown) {
            FileAttachmentPreview(attachment: attachment)
        }
        .accessibilityIdentifier("FileAttachmentView")
    }
}

public struct FileAttachmentDisplayView: View {
    @Injected(\.images) private var images
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    @Injected(\.tokens) private var tokens

    var url: URL
    var title: String
    var sizeString: String

    public init(url: URL, title: String, sizeString: String) {
        self.url = url
        self.title = title
        self.sizeString = sizeString
    }

    public var body: some View {
        HStack(spacing: tokens.spacingSm) {
            Image(uiImage: previewImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 40)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: tokens.spacingXxs) {
                Text(title)
                    .font(fonts.body)
                    .lineLimit(1)
                    .foregroundColor(Color(colors.textPrimary))
                Text(sizeString)
                    .font(fonts.subheadline)
                    .lineLimit(1)
                    .foregroundColor(Color(colors.textTertiary))
            }
            Spacer()
        }
        .accessibilityElement(children: .combine)
    }

    private var previewImage: UIImage {
        let iconName = url.pathExtension
        return images.fileIconPreviews[iconName] ?? images.iconOther
    }
}

struct DownloadShareAttachmentView<Payload: DownloadableAttachmentPayload>: View {
    @Injected(\.colors) var colors
    @Injected(\.images) var images
    @Injected(\.chatClient) var chatClient

    @State private var shareSheetShown = false
    @State private var downloadButtonShown: Bool
    @State private var shareButtonShown: Bool

    var attachment: ChatMessageAttachment<Payload>
    
    init(attachment: ChatMessageAttachment<Payload>) {
        self.attachment = attachment
        let downloadButtonShown: Bool = (attachment.uploadingState == nil || attachment.uploadingState?.state == .uploaded) && attachment.downloadingState == nil
        _downloadButtonShown = .init(initialValue: downloadButtonShown)
        _shareButtonShown = .init(initialValue: attachment.downloadingState?.state == .downloaded)
    }

    var body: some View {
        Group {
            if downloadButtonShown {
                downloadButton
            } else if shareButtonShown {
                shareButton
            }
        }
        .sheet(isPresented: $shareSheetShown) {
            if let shareURL = attachment.downloadingState?.localFileURL {
                ShareSheet(activityItems: [shareURL])
            }
        }
    }

    private var downloadButton: some View {
        Button(action: { downloadAttachment() }) {
            Image(uiImage: images.download)
                .renderingMode(.template)
                .foregroundColor(Color(colors.textPrimary))
                .frame(width: 24, height: 24)
        }
        .accessibilityLabel("Download")
    }

    private var shareButton: some View {
        Button(action: { shareSheetShown = true }) {
            Image(uiImage: images.share)
                .renderingMode(.template)
                .foregroundColor(Color(colors.textPrimary))
                .frame(width: 24, height: 24)
        }
        .accessibilityLabel("Share")
    }

    private func downloadAttachment() {
        let messageId = attachment.id.messageId
        let cid = attachment.id.cid
        let messageController = chatClient.messageController(cid: cid, messageId: messageId)
        messageController.downloadAttachment(attachment) { result in
            if case .failure(let error) = result {
                log.error("Error downloading attachment \(error.localizedDescription)")
            } else {
                downloadButtonShown = false
                shareButtonShown = true
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
