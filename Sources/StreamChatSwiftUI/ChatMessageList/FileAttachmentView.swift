//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

public struct FileAttachmentsContainer<Factory: ViewFactory>: View {
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
        let attachments = message.fileAttachments
        VStack(spacing: tokens.spacingXxs) {
            ForEach(attachments) { attachment in
                FileAttachmentView(
                    attachment: attachment,
                    width: width,
                    isFirst: isFirst
                )
                .modifier(
                    factory.styles.makeMessageAttachmentItemViewModifier(
                        options: MessageAttachmentItemViewModifierOptions(
                            message: message,
                            isFirst: isFirst,
                            attachmentType: .file
                        )
                    )
                )
            }
        }
        .accessibilityIdentifier("FileAttachmentsContainer")
    }
}

public struct FileAttachmentView: View {
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
                sizeString: attachment.file.sizeString,
                uploadingState: attachment.uploadingState,
                onRetry: { retryUpload() }
            )
            .onTapGesture {
                if attachment.uploadingState?.state != .uploadingFailed {
                    fullScreenShown = true
                }
            }
            .accessibilityAction {
                if attachment.uploadingState?.state != .uploadingFailed {
                    fullScreenShown = true
                }
            }

            Spacer()
        }
        .padding(.all, tokens.spacingSm)
        .frame(width: width)
        .sheet(isPresented: $fullScreenShown) {
            FileAttachmentPreview(attachment: attachment)
        }
        .accessibilityIdentifier("FileAttachmentView")
    }

    private func retryUpload() {
        let messageId = attachment.id.messageId
        let cid = attachment.id.cid
        let controller = chatClient.messageController(cid: cid, messageId: messageId)
        controller.resendMessage()
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
    var uploadingState: AttachmentUploadingState?
    var onRetry: (() -> Void)?

    public init(
        url: URL,
        title: String,
        sizeString: String,
        uploadingState: AttachmentUploadingState? = nil,
        onRetry: (() -> Void)? = nil
    ) {
        self.url = url
        self.title = title
        self.sizeString = sizeString
        self.uploadingState = uploadingState
        self.onRetry = onRetry
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
                subtitleContent
            }
            Spacer()
        }
        .accessibilityElement(children: .combine)
    }

    // MARK: - Private

    @ViewBuilder
    private var subtitleContent: some View {
        if let uploadingState {
            switch uploadingState.state {
            case let .uploading(progress):
                uploadingSubtitle(progress: progress, file: uploadingState.file)
            case .uploadingFailed:
                uploadFailedSubtitle
            default:
                fileSizeText
            }
        } else {
            fileSizeText
        }
    }

    private func uploadingSubtitle(progress: Double, file: AttachmentFile) -> some View {
        HStack(spacing: tokens.spacingXxs) {
            LoadingSpinnerView(
                size: LoadingSpinnerSize.extraSmall,
                progress: Double(progress)
            )
            Text(Self.uploadProgressText(progress: progress, file: file))
                .font(fonts.subheadline)
                .lineLimit(1)
                .foregroundColor(Color(colors.textSecondary))
        }
    }

    private var uploadFailedSubtitle: some View {
        VStack(alignment: .leading, spacing: tokens.spacingXxxs) {
            HStack(spacing: tokens.spacingXxs) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: tokens.iconSizeSm, height: tokens.iconSizeSm)
                    .foregroundColor(Color(colors.accentError))
                Text(L10n.Message.Sending.attachmentUploadFailed)
                    .font(fonts.subheadline)
                    .lineLimit(1)
                    .foregroundColor(Color(colors.textSecondary))
            }
            if let onRetry {
                Button(action: onRetry) {
                    Text(L10n.Message.Sending.attachmentRetryUpload)
                        .font(fonts.subheadline)
                        .foregroundColor(Color(colors.textLink))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var fileSizeText: some View {
        Text(sizeString)
            .font(fonts.subheadline)
            .lineLimit(1)
            .foregroundColor(Color(colors.textTertiary))
    }

    private var previewImage: UIImage {
        let iconName = url.pathExtension
        return images.fileIconPreviews[iconName] ?? images.iconOther
    }

    static func uploadProgressText(progress: Double, file: AttachmentFile) -> String {
        let formatter = AttachmentFile.sizeFormatter
        let uploaded = Int64(progress * Double(file.size))
        let uploadedText = formatter.string(fromByteCount: uploaded)
        let totalText = formatter.string(fromByteCount: file.size)
        return "\(uploadedText) / \(totalText)"
    }
}

struct DownloadShareAttachmentView<Payload: DownloadableAttachmentPayload>: View {
    @Injected(\.colors) var colors
    @Injected(\.images) var images

    @StateObject private var viewModel: ViewModel
    private let onShare: (URL) -> Void

    init(attachment: ChatMessageAttachment<Payload>, onShare: @escaping (URL) -> Void) {
        _viewModel = StateObject(wrappedValue: ViewModel(attachment: attachment))
        self.onShare = onShare
    }

    var body: some View {
        Group {
            if viewModel.localFileURL != nil {
                shareButton
            } else if viewModel.downloadButtonShown {
                downloadButton
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
    }

    private var downloadButton: some View {
        Button(action: { viewModel.downloadAttachment() }) {
            if viewModel.isDownloading {
                LoadingSpinnerView(size: LoadingSpinnerSize.medium, progress: viewModel.downloadProgress)
            } else {
                Image(uiImage: images.download)
                    .renderingMode(.template)
                    .foregroundColor(Color(colors.textPrimary))
                    .frame(width: 24, height: 24)
            }
        }
        .disabled(viewModel.isDownloading)
        .accessibilityLabel("Download")
        .accessibilityValue(viewModel.downloadProgress.map { "\(Int($0 * 100))%" } ?? "")
    }

    private var shareButton: some View {
        Button(action: {
            if let localFileURL = viewModel.localFileURL {
                onShare(localFileURL)
            }
        }) {
            Image(uiImage: images.share)
                .renderingMode(.template)
                .foregroundColor(Color(colors.textPrimary))
                .frame(width: 24, height: 24)
        }
        .accessibilityLabel("Share")
    }
}

extension DownloadShareAttachmentView {
    @MainActor final class ViewModel: ObservableObject, ChatMessageControllerDelegate {
        @Injected(\.chatClient) private var chatClient

        let attachment: ChatMessageAttachment<Payload>
        let downloadButtonShown: Bool

        @Published private(set) var downloadingState: AttachmentDownloadingState?
        @Published private(set) var isDownloadRequested = false

        private var messageController: ChatMessageController?

        init(attachment: ChatMessageAttachment<Payload>) {
            self.attachment = attachment
            downloadButtonShown = attachment.uploadingState == nil || attachment.uploadingState?.state == .uploaded
            downloadingState = attachment.downloadingState
        }

        var isDownloading: Bool {
            if isDownloadRequested {
                return true
            }
            if case .downloading = downloadingState?.state {
                return true
            }
            return false
        }

        var downloadProgress: Double? {
            guard case let .downloading(progress)? = downloadingState?.state else { return nil }
            return progress
        }

        var localFileURL: URL? {
            guard downloadingState?.state == .downloaded else { return nil }
            guard let url = downloadingState?.localFileURL, FileManager.default.fileExists(atPath: url.path) else { return nil }
            return url
        }

        func onAppear() {
            guard isDownloading, messageController == nil else { return }
            startObservingDownload(
                with: chatClient.messageController(
                    cid: attachment.id.cid,
                    messageId: attachment.id.messageId
                )
            )
        }

        func downloadAttachment() {
            isDownloadRequested = true
            let controller = chatClient.messageController(
                cid: attachment.id.cid,
                messageId: attachment.id.messageId
            )
            startObservingDownload(with: controller)
            let mediaLoader = InjectedValues[\.utils].mediaLoader
            mediaLoader.loadFileRequest(for: attachment.remoteURL) { [weak self] result in
                guard let self else { return }
                switch result {
                case let .success(fileRequest):
                    controller.downloadAttachment(self.attachment, request: fileRequest.urlRequest) { [weak self] result in
                        switch result {
                        case let .success(downloadedAttachment):
                            self?.finishDownload(with: downloadedAttachment.downloadingState)
                        case let .failure(error):
                            self?.finishDownload(with: nil)
                            log.error("Error downloading attachment: \(error.localizedDescription)")
                        }
                    }
                case let .failure(error):
                    self.finishDownload(with: nil)
                    log.error("Error resolving CDN URL: \(error.localizedDescription)")
                }
            }
        }

        func messageController(_ controller: ChatMessageController, didChangeMessage change: EntityChange<ChatMessage>) {
            let downloadingState = controller.message?.attachment(with: attachment.id)?.downloadingState
            switch downloadingState?.state {
            case .downloading:
                self.downloadingState = downloadingState
            case .downloaded, .downloadingFailed:
                finishDownload(with: downloadingState)
            case nil:
                break
            }
        }

        private func startObservingDownload(with controller: ChatMessageController) {
            messageController = controller
            controller.delegate = self
        }

        private func finishDownload(with downloadingState: AttachmentDownloadingState?) {
            self.downloadingState = downloadingState
            isDownloadRequested = false
            messageController = nil
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let files: [SharedFile]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: files.map(\.url), applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

extension ShareSheet {
    final class SharedFile: Identifiable {
        let url: URL
        
        init(url: URL) {
            self.url = url
            _ = url.startAccessingSecurityScopedResource()
        }
        
        deinit {
            url.stopAccessingSecurityScopedResource()
        }
        
        var id: URL { url }
    }
}
